open Utils
open Exceptions
open Tree

(** {1 Jumps validity} *)

(** [add_label_scope cur_scope seq] Add to [cur_scope] all the labels in the
    sequence [seq] and its contained sequences. labels at toplevel, i.e
    routine's entry point, are not considered valid to jump to *)
let rec add_label_scope (scope : SSet.t) (stmts : stmt list) : SSet.t =
  let aux (acc : SSet.t) (s : stmt) =
    match s.payload with
    | Label lab -> SSet.add lab acc
    | Seq stmts -> add_label_scope acc stmts
    | _ -> acc
  in
  List.fold_left aux scope stmts

(** [valid_jump_seq scope seq] Check if the jumps in a sequence's AST [seq] are
    valid. *)
let rec valid_jump_seq (scope : SSet.t) (stmts : stmt list) =
  List.iter (valid_jump_stmt scope) stmts

(** [valid_jump_stmt scope stmt] Check if the jumps in a statement's AST [stmt]
    are valid. *)
and valid_jump_stmt (scope : SSet.t) s =
  match s.payload with
  | Jump ({ payload = Name lab; _ }, _l) ->
      if not (SSet.mem lab scope) then ill_formed "illegal jump" s.loc
  | Jump (e, l) ->
      if not (List.for_all (Fun.flip SSet.mem scope) l) then
        ill_formed "illegal jump" s.loc
      else valid_jump_expr scope e
  | Cjump (_op, e1, e2, t, f) ->
      if not (SSet.mem t scope || SSet.mem f scope) then
        ill_formed "illegal jump" s.loc;
      valid_jump_expr scope e1;
      valid_jump_expr scope e2
  | Seq l -> valid_jump_seq scope l
  | Sxp e -> valid_jump_expr scope e
  | Move (e1, e2) ->
      valid_jump_expr scope e1;
      valid_jump_expr scope e2
  | Label _ | Litteral _ -> ()

(** [valid_jump_expr scope expe] Check if the jumps in an expression's AST
    [expr] are valid. *)
and valid_jump_expr (scope : SSet.t) e =
  match e.payload with
  | Const _ | ConstF _ | Name _ | Temp _ -> ()
  | Binop (_, l, r) ->
      valid_jump_expr scope l;
      valid_jump_expr scope r
  | Mem e -> valid_jump_expr scope e
  | Call (f, a, _) ->
      valid_jump_expr scope f;
      List.iter (fun (_, a) -> valid_jump_expr scope a) a
  | Eseq (s, e) ->
      valid_jump_stmt (add_label_scope scope [ s ]) s;
      valid_jump_expr scope e

(** binds a label to it's definition point. If the label is already bound then
    we raise an error. If the label is "end" and we are not at toplevel, we
    raise an error *)
let add l stmt toplevel map =
  if l = "end" then
    if not toplevel then
      ill_formed "label \"end\" must only be defined at toplevel" stmt
    else map
  else
    SMap.update l
      (function
        | None -> Some stmt
        | Some s ->
            raise
              (IllFormed
                 (Format.asprintf
                    "Ill-formed program, label %s has multiple definitions :@\n\
                     %a\n\n\
                    \ and \n\
                     %a"
                    l Errors.from_loc s Errors.from_loc stmt)))
      map

(** [labels_check_stmt stmt] Return the map from labels name to their
    definitions in a statement. *)
let rec labels_check_stmt toplevel map (stmt : stmt) =
  match stmt.payload with
  | Label l | Litteral (l, _) -> add l stmt.loc toplevel map
  | Move (e1, e2) | Cjump (_, e1, e2, _, _) ->
      labels_check_expr (labels_check_expr map e1) e2
  | Sxp e | Jump (e, _) -> labels_check_expr map e
  | Seq l -> List.fold_left (labels_check_stmt false) map l

(** [labels_check_expr map expr] Return the map from labels name to their
    definitions in an expression [expr]. *)
and labels_check_expr map (expr : expr) =
  match expr.payload with
  | Const _ | ConstF _ | Name _ | Temp _ -> map
  | Binop (_, e1, e2) -> labels_check_expr (labels_check_expr map e1) e2
  | Mem e -> labels_check_expr map e
  | Call (f, a, _) ->
      List.fold_left labels_check_expr (labels_check_expr map f)
        (List.map snd a)
  | Eseq (s, e) -> labels_check_expr (labels_check_stmt false map s) e

(** [labels_check_seq prog] Return the map from labels name to their definitions
    in a program. *)
let labels_check_prog (prog : stmt list) =
  List.fold_left (labels_check_stmt true) SMap.empty prog

(** {1 Linearity} *)

(** [linear_check_expr call seq e] Check if the expression [expr] is linear.
    - [call] is [true] if [expr] is in a call.
    - [seq] is [true] if [expr] is in a sequence. *)
let rec linear_check_expr (call : bool) (seq : bool) e =
  match e.payload with
  | Const _ | ConstF _ | Name _ | Temp _ -> ()
  | Binop (_, l, r) ->
      linear_check_expr call seq l;
      linear_check_expr call seq r
  | Mem e -> linear_check_expr call seq e
  | Call (_f, _a, _) ->
      (* Call is not in a sxp or a move stmt if we get to there *)
      ill_formed "call illegal in LIR" e.loc
  | Eseq _ -> ill_formed "eseq not allowed in LIR" e.loc

(** [linear_check_seq call seq stmts] Check if the sequence [stmts] is linear.
    - [call] is [true] if [expr] is in a call.
    - [seq] is [true] if [expr] is in a sequence. *)
and linear_check_seq (call : bool) (seq : bool) (stmts : stmt list) =
  let rec aux expect_label stmts =
    match (expect_label, stmts) with
    | Some l, ({ payload = Label l'; loc; _ } as s) :: t ->
        if l = l' then
          let expect_label = linear_check_stmt false seq s t in
          aux expect_label t
        else
          let msg =
            Format.asprintf "Cjump followed by wrong label (%s instead of %s)"
              l' l
          in
          ill_formed msg loc
    | Some _, { payload = _; loc; _ } :: _ ->
        ill_formed "Cjump not followed by a label" loc
    | Some _, [] ->
        raise (IllFormed (Format.asprintf "Cjump not followed by a label"))
    | None, [] -> ()
    | None, s :: t ->
        let expected_label = linear_check_stmt call seq s t in
        aux expected_label t
  in
  aux None stmts

(** [linear_check_stmt call seq s t] Check if the statement [s] is linear, with
    [t] the next statements.
    - [call] is [true] if [expr] is in a call.
    - [seq] is [true] if [expr] is in a sequence. return Some 'l' if the next
      statement is expected to be a label 'l' and None otherwise *)
and linear_check_stmt (call : bool) (seq : bool) (s : stmt) (_st : stmt list) :
    label option =
  match s.payload with
  | Sxp { payload = Call (f, a, _); _ } ->
      (* Call is non-linear if nested in a call *)
      linear_check_expr true seq f;
      List.iter (fun (_, a) -> linear_check_expr true seq a) a;
      None
  | Move (dest, { payload = Call (f, a, _); _ }) ->
      (* Call is non-linear if nested in a call *)
      linear_check_expr true seq f;
      linear_check_expr true seq dest;
      List.iter (fun (_, a) -> linear_check_expr true seq a) a;
      None
  | Move (e1, e2) ->
      linear_check_expr call seq e1;
      linear_check_expr call seq e2;
      None
  | Sxp e ->
      linear_check_expr call seq e;
      None
  | Jump (e, _l) ->
      linear_check_expr call seq e;
      None
  | Cjump (_op, e1, e2, _t, f) ->
      linear_check_expr call seq e1;
      linear_check_expr call seq e2;
      Some f
  | Seq l ->
      (* Seq is non-linear if nested in a seq *)
      if seq then ill_formed "nested seq not allowed in LIR" s.loc;
      linear_check_seq call true l;
      None
  | Label _ | Litteral _ -> None

(** [linear_check_prog prog] Check if the program [prog] is linear. *)
let linear_check_prog (prog : stmt list) =
  let rec aux (seq : bool) expect_label stmts =
    match (expect_label, stmts) with
    | Some l, ({ payload = Label l'; loc; _ } as s) :: t ->
        if l = l' then
          let expect_label = linear_check_stmt false seq s t in
          aux seq expect_label t
        else ill_formed "Cjump followed by wrong label" loc
    | Some _, { payload = _; loc; _ } :: _ ->
        ill_formed "Cjump not followed by a label" loc
    | Some _, [] ->
        raise (IllFormed (Format.asprintf "Cjump not followed by a label"))
    | None, [] -> ()
    | None, { payload = Label "end"; _ } :: t -> aux false None t
    | None, { payload = Seq l; _ } :: t ->
        linear_check_seq false true l;
        aux true None t
    | None, s :: t ->
        let expect_label = linear_check_stmt false seq s t in
        aux seq expect_label t
  in
  aux false None prog

(* SSA *)

(** [ssa_check_temp_reassignment id] Check if the temp [id] may be reassigned in
    SSA form context. *)
let ssa_check_temp_reassignment (id : string) =
  id <> "fp" && id <> "sp" && id <> "rv"
  && not (String.starts_with ~prefix:"i" id)

(** [ssa_check_expr label_set e] Check if the expression [e] is written using
    SSA:
    - [label_set] is a set of each temp symbol defined. *)
let rec ssa_check_expr (label_set : SSet.t) (e : expr) =
  match e.payload with
  | Const _ | ConstF _ | Name _ | Temp _ -> label_set
  | Binop (_, l, r) -> ssa_check_expr (ssa_check_expr label_set l) r
  | Mem e -> ssa_check_expr label_set e
  | Call (f, a, _) ->
      List.fold_left ssa_check_expr
        (ssa_check_expr label_set f)
        (List.map snd a)
  | Eseq (s, e) -> ssa_check_expr (ssa_check_stmt label_set s) e

(** [ssa_check_stmt label_set s] Check if the statement [s] is written using
    SSA: If a move statement, the destination is added to label_set.
    - [label_set] is a set of each temp symbol defined. *)
and ssa_check_stmt (label_set : SSet.t) (s : stmt) =
  match s.payload with
  | Label _ | Litteral _ -> label_set
  | Move ({ payload = Temp id; _ }, e2) ->
      let set = ssa_check_expr label_set e2 in
      if ssa_check_temp_reassignment id && SSet.mem id set then
        ill_formed "redefinition of temp" s.loc
      else SSet.add id set
  | Move (e1, e2) -> ssa_check_expr (ssa_check_expr label_set e1) e2
  | Cjump (_, e1, e2, _, _) -> ssa_check_expr (ssa_check_expr label_set e1) e2
  | Sxp e | Jump (e, _) -> ssa_check_expr label_set e
  | Seq l -> List.fold_left ssa_check_stmt label_set l

(** [ssa_check_seq label_set] Check if all statements of a seq [stmts] are
    written using SSA.
    - [label_set] is a set of each temp symbol that were already defined. *)
and ssa_check_seq (label_set : SSet.t) (stmts : stmt list) =
  List.fold_left ssa_check_stmt label_set stmts

(** [ssa_check_prog prog] Check if the program [prog] is written using SSA. *)
let ssa_check_prog (prog : stmt list) =
  let rec aux (symbol_set : SSet.t) = function
    | [] -> ()
    | s :: t -> aux (ssa_check_stmt symbol_set s) t
  in
  aux SSet.empty prog

let go prog =
  ignore (labels_check_prog prog);
  valid_jump_seq (add_label_scope SSet.empty prog) prog
