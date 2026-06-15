(** The purpose of this module is to build structures to evaluate the control
    flow :
    - The flow.t record for the jumps to a label.
    - The map for routines, which associate the label to its main sequence.
    - The map for the strings. This is done by the build function which is the
      entry point. The preload functions (preloadExpr, preloadSeq and
      preloadStmt) build the stacks and the maps for the jumps and associate the
      maps for the eseqs. preloadSeq and preloadStmt also return a "local" Map.
      They are used in two cases :
    - In preloadExpr, in the eseq case, where they are associated to the current
      eseq.
    - In build, where they are merged to the current routine map *)

open Tree
open Utils

exception PreloadError of string * location

type t = {
  litterals : string SMap.t;
  routines : stmt list SMap.t;
  jump_dest : Flow.t;
}
(** Result of the preload *)

(** empty t *)
let empty =
  { litterals = SMap.empty; routines = SMap.empty; jump_dest = Flow.empty }

(** merge * Merge two map *)
let merge (left : t) (right : t) : t =
  {
    litterals = Flow.merge_labels left.litterals right.litterals;
    routines = Flow.merge_labels left.routines right.routines;
    jump_dest = Flow.merge left.jump_dest right.jump_dest;
  }

(** preloadSeq * Do the preload for a sequence of statements *)
let rec preloadSeq (level : int) (stack : stmt list list) (prog : stmt list) :
    t * Flow.dest SMap.t =
  let rec aux (prog : stmt list) ((right1, right2) : t * Flow.dest SMap.t) =
    match prog with
    | [] -> (right1, right2)
    | s :: st ->
        let left1, left2 = preloadStmt level stack s st in
        aux st (merge left1 right1, Flow.merge_labels left2 right2)
  in
  aux prog (empty, SMap.empty)

(** preloadStmt * Do the preload on a statement * - In the case of a litteral,
    it add it to the corresponding * - In the case of a label (for a jump), it
    add it to the current * label map * - Otherwise, it call the preload
    functions on the childs and merge * their results *)
and preloadStmt (level : int) (stack : stmt list list) (s : stmt)
    (st : stmt list) : t * Flow.dest SMap.t =
  match s.payload with
  | Move (m, e) ->
      ( merge (preloadExpr (level + 1) stack m) (preloadExpr (level + 1) stack e),
        SMap.empty )
  | Sxp e -> (preloadExpr (level + 1) stack e, SMap.empty)
  | Jump (e, _) -> (preloadExpr (level + 1) stack e, SMap.empty)
  | Cjump (_, t, f, _, _) ->
      ( merge (preloadExpr (level + 1) stack t) (preloadExpr (level + 1) stack f),
        SMap.empty )
  | Seq l -> preloadSeq (level + 1) (st :: stack) l
  | Label name -> (empty, SMap.singleton name ((s :: st) :: stack, level))
  | Litteral (name, dat) ->
      ({ empty with litterals = SMap.singleton name dat }, SMap.empty)

(** prelaadExpr * Do the preload on a expression * - If it is an eseq, do the
    preload on the eseq's statement and associate * its local jump label map to
    the eseq * - Otherwise, it call the preload functions on the childs and
    merge * their results *)
and preloadExpr (level : int) (stack : stmt list list) (e : expr) : t =
  match e.payload with
  | Binop (_, e1, e2) ->
      merge
        (preloadExpr (level + 1) stack e1)
        (preloadExpr (level + 1) stack e2)
  | Mem e2 -> preloadExpr (level + 1) stack e2
  | Call (f, args, _) ->
      List.fold_left merge empty
        (List.map (preloadExpr (level + 1) stack) (f :: List.map snd args))
  | Eseq (s, e2) ->
      let r, map = preloadSeq (level + 1) [] [ s ] in
      merge
        {
          r with
          jump_dest = { r.jump_dest with eseq = (s, map) :: r.jump_dest.eseq };
        }
        (preloadExpr (level + 1) stack e2)
  | _ -> empty

(** preload * Do the preload and return the litterals and the destiations of
    jumps *)
let preload (prog : stmt list) : string SMap.t * Flow.t =
  let r, map = preloadSeq 0 [] prog in
  ( r.litterals,
    {
      r.jump_dest with
      routines =
        SMap.singleton "main"
          (Flow.merge_labels (SMap.find "main" r.jump_dest.routines) map);
    } )

(** build * Create the maps for the litterals, the routines, and the jumps to a
    label. * This is done by looping on the top level and calling the preload
    functions for * the jumps, and in the loop for the two other. *)
let build (prog : stmt list) : t =
  let rec preload_routine curname acc t l =
    (* Reverse the list l and do the preload of each statements *)
    match l with
    | [] -> { acc with routines = SMap.add curname t acc.routines }
    | [ { payload = Label n; _ } ] when n = curname ->
        { acc with routines = SMap.add curname t acc.routines }
    | stmt :: tl ->
        let jump_dest = preload_stmt curname acc t stmt in
        preload_routine curname { acc with jump_dest } (stmt :: t) tl
  and preload_stmt curname acc t stmt =
    try
      let r, map = preloadStmt 0 [] stmt t in
      let eseq = List.rev_append r.jump_dest.eseq acc.jump_dest.eseq in
      let top = Flow.merge_labels map acc.jump_dest.top in
      { (Flow.add_routine acc.jump_dest curname map) with eseq; top }
    with Flow.FlowError s -> raise (PreloadError (s, stmt.loc))
  in

  let rec loop acc ((curname, curbody) as cur) = function
    | [] when curbody = [] -> acc
    | [] ->
        Format.eprintf
          "The routine %s should end with 'label end'. Terminating it.\n"
          curname;
        preload_routine curname acc [] curbody
    | { payload = Litteral (n, str); _ } :: t ->
        loop { acc with litterals = SMap.add n str acc.litterals } cur t
    | ({ payload = Label "end"; _ } as l) :: t ->
        loop (preload_routine curname acc [ l ] curbody) ("", []) t
    | ({ payload = Label n; _ } as l) :: t
      when curbody = [] (* this means the label is at top level *) ->
        loop acc (n, [ l ]) t
    | stmt :: t -> loop acc (curname, stmt :: curbody) t
  in
  loop empty ("", []) prog
