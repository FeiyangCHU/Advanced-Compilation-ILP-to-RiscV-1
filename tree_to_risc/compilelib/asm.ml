open Treelib
open Utils

(* Abstract assembly language *)

type temp = string
type label = string

type instr =
  | Oper of {
      assem : string;
      dst : temp list;
      src : temp list;
      jump : label list option;
      is_call : bool;
    }
    (* an operation reads a set of temporaries, writes into an other set
   and might (or not) jump to a set of labels *)
  | Move of { assem : string; dst : temp; src : temp }
  | Label of { assem : string; lab : label }

let print fmt = function
  | Oper { assem; _ } -> Format.fprintf fmt "%s" assem
  | Move { assem; _ } -> Format.fprintf fmt "%s" assem
  | Label { assem; _ } -> Format.fprintf fmt "%s" assem

type t = instr list

(** helper to collect temporaries that appear in a list of asm instructions *)
let collect_temps (instrs : t) : SSet.t =
  let add_instr acc = function
    | Oper { dst; src; _ } ->
        List.fold_left (fun acc x -> SSet.add x acc) acc (src @ dst)
    | Move { dst; src; _ } -> acc |> SSet.add dst |> SSet.add src
    | Label _ -> acc
  in
  List.fold_left add_instr SSet.empty instrs

(** load immediate: li rd imm *)
let load_immediate ~temp ~imm =
  Oper
    {
      assem = "li `d0, " ^ imm;
      dst = [ temp ];
      src = [];
      jump = None;
      is_call = false;
    }

(** Move instruction: mv rd, rs *)
let move_instr ~dst ~src =
  match (Tree_helper.is_float_temp dst, Tree_helper.is_float_temp src) with
  | true, true -> Move { assem = "fmv.s `d0, `s0"; dst; src }
  | false, false -> Move { assem = "mv `d0, `s0"; dst; src }
  | _ ->
      failwith
        (Format.asprintf
           "move between two temporaries of different types: %s and %s" dst src)

(** Parameter binding to physical register *)
let move_param ~dst ~src =
  Oper
    {
      assem =
        (if Tree_helper.is_float_temp dst then "fmv.s `d0, " ^ src
         else "mv `d0, " ^ src);
      dst = [ dst ];
      src = [];
      jump = None;
      is_call = false;
    }

(** Move instruction: mv rd, rs *)
let return_value ~dst =
  Oper
    {
      assem =
        (if Tree_helper.is_float_temp dst then "fmv.s `d0, fa0"
         else "mv `d0, a0");
      dst = [ dst ];
      src = [];
      jump = None;
      is_call = false;
    }

(** Binary instruction: op rd, rs1, rs2 *)
let binary_instr ~op ~dst ~src1 ~src2 =
  Oper
    {
      assem = op ^ " `d0, `s0, `s1";
      dst = [ dst ];
      src = [ src1; src2 ];
      jump = None;
      is_call = false;
    }

(** Binary instruction with immediate: op rd, rs, imm *)
let binary_instr_i ~op ~dst ~src imm =
  Oper
    {
      assem = op ^ " `d0, `s0, " ^ imm;
      dst = [ dst ];
      src = [ src ];
      jump = None;
      is_call = false;
    }

let label l = Label { assem = l ^ ":"; lab = l }


(* Rewrites an abstract assembly instruction by replacing temporary
   registers with their assigned physical registers.

   The function takes:
     - reg_of_temp : temp -> physical register mapping
     - i           : an abstract assembly instruction

   Assembly templates use placeholders:
     - `d0, `d1, ... for destination operands
     - `s0, `s1, ... for source operands

   For each operand:
     1. The temporary is mapped to its physical register.
     2. The placeholder in the assembly string is replaced.
     3. The dst/src lists are updated to contain physical registers.
*)
let assign_physical_register reg_of_temp i =
  let subst reg_of_temp assem ~dst ~src =
    let s = ref assem in
    let dst =
      List.mapi
        (fun i t ->
          let physical = reg_of_temp t in
          s :=
            Str.global_replace (Str.regexp ("`d" ^ string_of_int i)) physical !s;
          physical)
        dst
    in
    let src =
      List.mapi
        (fun i t ->
          let physical = reg_of_temp t in
          s :=
            Str.global_replace (Str.regexp ("`s" ^ string_of_int i)) physical !s;
          physical)
        src
    in
    (!s, dst, src)
  in
  match i with
  | Label _ -> i
  | Move { assem; dst; src } ->
      let assem, dst, src = subst reg_of_temp assem ~dst:[ dst ] ~src:[ src ] in
      Move { assem; dst = List.hd dst; src = List.hd src }
  | Oper ({ assem; dst; src; _ } as o) ->
      let assem, dst, src = subst reg_of_temp assem ~dst ~src in
      Oper { o with assem; dst; src }

(* Constructs the control-flow graph (CFG) successor relation
   for a list of assembly instructions.

   For each instruction i:
     - If it contains explicit jump targets (jump = Some labels),
       successors are the corresponding label positions.
     - Otherwise (normal instruction), control flows to i + 1,
       unless it is the last instruction.

   The result is an array where arr.(i) is the list of successor
   instruction indices.
*)
let build_succ instrs =
  let label_map =
    let tbl = Hashtbl.create 16 in
    List.iteri
      (fun i -> function Label { lab; _ } -> Hashtbl.add tbl lab i | _ -> ())
      instrs;
    tbl
  in
  let n = List.length instrs in
  let arr = Array.make n [] in
  List.iteri
    (fun i instr ->
      let succ =
        match instr with
        | Oper { jump = Some labs; _ } -> List.map (Hashtbl.find label_map) labs
        | Oper { jump = None; _ } | Move _ | Label _ ->
            if i + 1 < n then [ i + 1 ] else []
      in
      arr.(i) <- succ)
    instrs;
  arr

let escape s = String.map (function '"' -> '\'' | c -> c) s

let emit fmt instr =
  Format.fprintf fmt "%a" print (assign_physical_register Fun.id instr)

let instr_label i instr = Format.asprintf "%d: %a" i emit instr

let to_dot (instrs : t) (out : out_channel) =
  let succ = build_succ instrs in
  output_string out "digraph CFG {\n";
  output_string out "  node [shape=box fontname=\"monospace\"];\n";
  (* Nodes *)
  List.iteri
    (fun i instr ->
      Printf.fprintf out "  n%d [label=\"%s\"];\n" i (instr_label i instr))
    instrs;
  (* Edges *)
  Array.iteri
    (fun i succs ->
      List.iter (fun j -> Printf.fprintf out "  n%d -> n%d;\n" i j) succs)
    succ;
  output_string out "}\n"
