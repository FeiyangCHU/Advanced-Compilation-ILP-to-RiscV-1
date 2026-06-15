open Treelib
open Utils

exception RegallocException of string

type info = { live_in : SSet.t; live_out : SSet.t }

(*use extrait l'ensemble des variables temporaires lues (utilisées) dans une instruction d'assemblage*)
let use (i : Asm.instr) : SSet.t =
  match i with
  | Oper { dst; src; _ } ->
      let base = SSet.of_list src in
      base
  | Move { src; _ } -> SSet.singleton src
  | Label _ -> SSet.empty

(*def extrait l'ensemble des variables temporaires écrites (définies) dans une instruction d'assemblage*)
let def (i : Asm.instr) : SSet.t =
  match i with
  | Oper { dst; _ } -> SSet.of_list dst
  | Move { dst; _ } -> SSet.singleton dst
  | Label _ -> SSet.empty

(* ---- Liveness analysis (backward dataflow) ---- *)
(* Computes live_in and live_out sets for each instruction using
   backward dataflow iteration until a fixed point.

   For each instruction i:
     live_out[i] = ⋃ live_in[s] for all successors s of i
     live_in[i]  = use[i] ∪ (live_out[i] − def[i])

   Algorithm:
   1. Initialize all live_in/live_out sets to empty.
   2. Repeatedly iterate backward over instructions:
        - Recompute live_out from successors.
        - Recompute live_in from use/def equations.
   3. Stop when no set changes (fixed point reached).
*)
let analyze (instrs : Asm.instr list) : info array =
  let arr = Array.of_list instrs in
  let n = Array.length arr in
  let info = Array.make n { live_in = SSet.empty; live_out = SSet.empty } in
  
  let succ_arr = Asm.build_succ instrs in 

  let changed = ref true in
  while !changed do
    changed := false;
    (*Il faut remonter de la fin du tableau vers le début.*)
    for i = n - 1 downto 0 do
      let old_in = info.(i).live_in in
      let old_out = info.(i).live_out in

      (* live_out[i] = ⋃ live_in[s] for all successors s of i *)
      let new_out =
        List.fold_left (fun acc s_idx ->
          SSet.union acc info.(s_idx).live_in
        ) SSet.empty succ_arr.(i)
      in

      (* live_in[i]  = use[i] ∪ (live_out[i] − def[i]) *)
      let uses = use arr.(i) in
      let defs = def arr.(i) in
      let new_in = SSet.union uses (SSet.diff new_out defs) in

      info.(i) <- { live_in = new_in; live_out = new_out };

      if not (SSet.equal old_in new_in && SSet.equal old_out new_out) then
        changed := true
    done
  done;
  info

(* ---- Interference graph construction ---- *)
(* Builds the integer and float interference graphs from liveness info.
   Returns (integer_graph, float_graph).
   Graph.t is a mutable hashtable, so we mutate both graphs in-place.
*)
let build_interference (instrs : Asm.instr list) (live : info array) :
    Graph.t * Graph.t =
  let is_f = Tree_helper.is_float_temp in

  let ig = Graph.empty () in
  let fg = Graph.empty () in

  (* Register all temps as nodes in the appropriate graph *)
  let all_temps = Asm.collect_temps instrs in
  SSet.iter (fun t ->
    if is_f t then Graph.add_node fg t
    else Graph.add_node ig t
  ) all_temps;

  (* Add interference edges: for each instruction, every temp defined by
     that instruction interferes with every temp live-out (except the
     source of a Move, which is allowed to be coalesced). *)
  List.iteri (fun i instr ->
    let outs = match instr with
      | Asm.Move { src; _ } -> SSet.remove src live.(i).live_out
      | _ -> live.(i).live_out
    in
    SSet.iter (fun d ->
      SSet.iter (fun o ->
        if is_f d && is_f o then Graph.add_edge fg d o
        else if not (is_f d) && not (is_f o) then Graph.add_edge ig d o
        (* cross-type interference: no edge *)
      ) outs
    ) (def instr)
  ) instrs;

  (ig, fg)

(* ---- Simplify phase (graph reduction) ---- *)
(* Implements the simplify phase of graph coloring.

   Repeatedly:
     - Pick a node with degree < k if possible.
     - If none exists, pick an arbitrary node (potential spill).
     - Remove it from the graph and push it onto a stack.

   The resulting stack gives a coloring order: nodes are pushed in
   elimination order and then processed (fold_left) in that order,
   meaning easier (low-degree) nodes get colored first.

   Note: Graph.t is a mutable hashtable. We collect all nodes first,
   then remove them one by one; the original graph is NOT preserved
   after this call.
*)
let simplify ~(k : int) (g : Graph.t) : Asm.temp list =
  let g = Hashtbl.copy g in
  let get_nodes g = Hashtbl.fold (fun t _ acc -> t :: acc) g [] in
  let rec loop stack =
    let nodes = get_nodes g in
    match nodes with
    | [] -> stack
    | _ ->
        let target_node =
          try
            List.find (fun n -> Graph.degree g n < k) nodes
          with Not_found ->
            List.hd nodes
        in
        Graph.remove_node g target_node;
        loop (target_node :: stack)
  in
  loop []

(* ---- Select phase (assign colors) ---- *)
(* Pops nodes from the simplify stack and assigns registers.

   For each temp t:
     - Collect the set of colors already assigned to its neighbors.
     - Choose a register from 'registers' not in that set.
     - If one exists, assign it.
     - Otherwise, mark t as spilled.

   Returns:
     - A mapping temp -> assigned register.
     - A list of spilled temps.
*)

let select ~(registers : Asm.temp list) (g : Graph.t) (stack : Asm.temp list) :
    Asm.temp SMap.t * Asm.temp list =

  List.fold_left (fun (coloring, spills) t ->
    (* Collect the set of colors already assigned to its neighbors. *)
    let neighbors = Graph.neighbors g t in   (* g first, then t *)
    let neighbor_colors =
      SSet.fold (fun neighbor acc ->
        match SMap.find_opt neighbor coloring with
        | Some color -> SSet.add color acc
        | None -> acc
      ) neighbors SSet.empty
    in

    (* Choose a register from 'registers' not in that set *)
    let available_reg =
      List.find_opt (fun reg -> not (SSet.mem reg neighbor_colors)) registers
    in

    match available_reg with
    | Some reg ->
        let new_coloring = SMap.add t reg coloring in
        (new_coloring, spills)

    | None ->
        (coloring, t :: spills)

  ) (SMap.empty, []) stack

(* ---- Full graph coloring driver ---- *)
type colorization = {
  physical_bindings : Asm.temp SMap.t;
  spills : Asm.temp list;
}

(* Steps:
   1. Run simplify to compute elimination stack.
   2. Run select to assign registers and detect spills.
   3. Add precolored temps (fixed hardware registers) to the map.

   k = number of available registers.
   registers = list of allocatable registers.
   precolored = fixed temp -> register bindings.

   Returns:
     - Final temp -> register mapping.
     - List of spills (if any).
 *)
let color ~(registers : Asm.temp list) ~(precolored : (string * string) list)
    (g : Graph.t) : colorization =
  let k = List.length registers in
  let stack = simplify ~k g in
  let colormap, spills = select ~registers g stack in
  let colormap =
    List.fold_left
      (fun acc (ir_arg, assembly_arg) -> SMap.add ir_arg assembly_arg acc)
      colormap precolored
  in
  { physical_bindings = colormap; spills }
