open Tree
open Utils

let is_float = function AddF | SubF | MulF | DivF -> true | _ -> false

let is_float_cmp = function
  | EqF | NeqF | GEF | GTF | LEF | LTF -> true
  | _ -> false

let is_float_temp = function "fp" | "sp" -> false | t -> t.[0] = 'f'

(** Collects the set of temporaries that appear in an expression *)
let rec temps_expr e =
  match e.payload with
  | Temp s -> SSet.singleton s
  | Binop (_, e1, e2) -> SSet.union (temps_expr e1) (temps_expr e2)
  | Eseq (stmt, e) -> SSet.union (temps_expr e) (temps_stmt stmt)
  | Const _ | ConstF _ | Name _ -> SSet.empty
  | Mem e -> temps_expr e
  | Call (f_expr, args, _) ->
      List.fold_left
        (fun acc (_, e) -> SSet.union (temps_expr e) acc)
        (temps_expr f_expr) args

(** Collects the set of temporaries that appear in a statement *)
and temps_stmt s =
  match s.payload with
  | Move (e1, e2) -> SSet.union (temps_expr e1) (temps_expr e2)
  | Sxp e -> temps_expr e
  | Jump (e, _labs) -> temps_expr e
  | Cjump (_r, e1, e2, _l1, _l2) -> SSet.union (temps_expr e1) (temps_expr e2)
  | Seq s ->
      List.fold_left (fun acc x -> SSet.union acc (temps_stmt x)) SSet.empty s
  | Label _ -> SSet.empty
  | Litteral _ -> SSet.empty

(** builds the set of temporaries that appear in a program *)
let collect_temps (prog : stmt list) : SSet.t =
  List.fold_left (fun acc x -> SSet.union acc (temps_stmt x)) SSet.empty prog

(* True if a temporary represents a function parameter *)
let is_parameter (t : string) : bool =
  let len = String.length t in
  if len = 0 then false
  else
    match t.[0] with
    | 'i' -> len > 1 && t.[1] >= '0' && t.[1] <= '9'
    | 'f' -> len > 2 && t.[1] = 'i' && t.[2] >= '0' && t.[2] <= '9'
    | _ -> false

(** builds the set of parameters (i0,i1,..., f0, f1, ...) that appear in a
    program *)
let collect_parameters (prog : stmt list) : SSet.t =
  SSet.filter is_parameter (collect_temps prog)

(** Collects the set of string litterals that appear in an expression *)
let rec litterals_expr e =
  match e.payload with
  | Temp _ -> SMap.empty
  | Binop (_, e1, e2) ->
      SMap.fold SMap.add (litterals_expr e1) (litterals_expr e2)
  | Eseq (stmt, e) ->
      SMap.fold SMap.add (litterals_expr e) (litterals_stmt stmt)
  | Const _ | ConstF _ | Name _ -> SMap.empty
  | Mem e -> litterals_expr e
  | Call (f_expr, args, _) ->
      List.fold_left
        (fun acc (_, e) -> SMap.fold SMap.add (litterals_expr e) acc)
        (litterals_expr f_expr) args

(** Collects the set of litteraloraries that appear in a statement *)
and litterals_stmt s =
  match s.payload with
  | Move (e1, e2) -> SMap.fold SMap.add (litterals_expr e1) (litterals_expr e2)
  | Sxp e -> litterals_expr e
  | Jump (e, _labs) -> litterals_expr e
  | Cjump (_r, e1, e2, _l1, _l2) ->
      SMap.fold SMap.add (litterals_expr e1) (litterals_expr e2)
  | Seq s ->
      List.fold_left
        (fun acc x -> SMap.fold SMap.add acc (litterals_stmt x))
        SMap.empty s
  | Label _ -> SMap.empty
  | Litteral (l, s) -> SMap.singleton l s

(** builds the set of labels that appear in a program *)
let collect_litterals (prog : stmt list) =
  List.fold_left
    (fun acc x -> SMap.fold SMap.add acc (litterals_stmt x))
    SMap.empty prog

let fresh_float_label =
  let cpt = ref (-1) in
  fun () ->
    incr cpt;
    Format.asprintf "L_float_%i" !cpt

(** Collects the set of float literals that appear in an expression *)
let rec float_litterals_expr e =
  match e.payload with
  | Temp _ -> SMap.empty
  | Binop (_, e1, e2) ->
      SMap.fold SMap.add (float_litterals_expr e1) (float_litterals_expr e2)
  | Eseq (stmt, e) ->
      SMap.fold SMap.add (float_litterals_expr e) (float_litterals_stmt stmt)
  | Const _ | Name _ -> SMap.empty
  | ConstF s ->
      let lbl = fresh_float_label () in
      SMap.singleton s lbl
  | Mem e -> float_litterals_expr e
  | Call (f_expr, args, _) ->
      List.fold_left
        (fun acc (_, e) -> SMap.fold SMap.add (float_litterals_expr e) acc)
        (float_litterals_expr f_expr)
        args

(** Collects the set of float literals that appear in a statement *)
and float_litterals_stmt s =
  match s.payload with
  | Move (e1, e2) ->
      SMap.fold SMap.add (float_litterals_expr e1) (float_litterals_expr e2)
  | Sxp e -> float_litterals_expr e
  | Jump (e, _labs) -> float_litterals_expr e
  | Cjump (_r, e1, e2, _l1, _l2) ->
      SMap.fold SMap.add (float_litterals_expr e1) (float_litterals_expr e2)
  | Seq s ->
      List.fold_left
        (fun acc x -> SMap.fold SMap.add acc (float_litterals_stmt x))
        SMap.empty s
  | Label _ -> SMap.empty
  | Litteral _ -> SMap.empty

(** builds the set of float literal labels that appear in a program *)
let collect_float_litterals (prog : stmt list) =
  List.fold_left
    (fun acc x -> SMap.fold SMap.add acc (float_litterals_stmt x))
    SMap.empty prog

(* fake location for ast parts that are inserted by a transformation
   (e.g linearization) *)
let fake_loc = (Lexing.dummy_pos, Lexing.dummy_pos)
let loc a = { payload = a; loc = fake_loc }

(** builds the set of labels that appear in an expression *)
let rec labels_expr e =
  match e.payload with
  | Temp _ -> SSet.empty
  | Binop (_, e1, e2) -> SSet.union (labels_expr e1) (labels_expr e2)
  | Eseq (stmt, e) -> SSet.union (labels_expr e) (labels_stmt stmt)
  | Const _ | ConstF _ | Name _ -> SSet.empty
  | Mem e -> labels_expr e
  | Call (f_expr, args, _) ->
      List.fold_left
        (fun acc (_, e) -> SSet.union (labels_expr e) acc)
        (labels_expr f_expr) args

(** builds the set of labels that appear in a statement *)
and labels_stmt s =
  match s.payload with
  | Move (e1, e2) -> SSet.union (labels_expr e1) (labels_expr e2)
  | Sxp e -> labels_expr e
  | Jump (e, _labs) -> labels_expr e
  | Cjump (_r, e1, e2, _l1, _l2) -> SSet.union (labels_expr e1) (labels_expr e2)
  | Seq s ->
      List.fold_left (fun acc x -> SSet.union acc (labels_stmt x)) SSet.empty s
  | Label l -> SSet.singleton l
  | Litteral _ -> SSet.empty

(** builds the set of labels that appear in a program *)
let collect_labels (prog : stmt list) : SSet.t =
  List.fold_left (fun acc x -> SSet.union acc (labels_stmt x)) SSet.empty prog

(** given a program p, returns a temporary generator that generates temporaries
    that are not in p *)
let fresh_temp (prog : stmt list) : typ -> string =
  let temps = collect_temps prog in
  let cpt = ref 0 in
  let rec loop () =
    let t = Format.sprintf "t%i" !cpt in
    incr cpt;
    if SSet.mem t temps then loop () else t
  in
  let rec loopf () =
    let t = Format.sprintf "f%i" !cpt in
    incr cpt;
    if SSet.mem t temps then loopf () else t
  in
  function Int -> loop () | Float -> loopf ()

(** given a program p, returns a label generator that generates labels that are
    not in p *)
let fresh_label (prog : stmt list) : unit -> string =
  let labels = collect_labels prog in
  let cpt = ref 1 in
  let rec loop () =
    let l = Format.sprintf "L%i" !cpt in
    incr cpt;
    if SSet.mem l labels then loop () else l
  in
  loop

(** if the argument is a cjump, flips its destinations otherwise leaves
    unchanged *)
let flip stmt : stmt =
  match stmt.payload with
  | Cjump (r, e1, e2, then_, else_) ->
      { stmt with payload = Cjump (r, e2, e1, else_, then_) }
  | _ -> stmt

type rewritter = { fresh_temp : typ -> string; fresh_label : unit -> string }

let build_rewriter prog =
  let fresh_temp = fresh_temp prog in
  { fresh_temp; fresh_label = fresh_label prog }
