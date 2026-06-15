open Treelib
open Tree
open Tree_helper

exception LinearizationException of string


(* Rewrites the program by putting calls into explicit call by value *)
let normalize_call (temp_gen : typ -> string) (p : program) : program =
  let seq_or_single stmts =
    match stmts with
    | [] -> loc (Seq [])
    | [ s ] -> s
    | _ -> loc (Seq stmts)
  in
  let rec norm_expr e =
    match e.payload with
    | Const _ | ConstF _ | Name _ | Temp _ -> e
    | Binop (op, e1, e2) -> loc (Binop (op, norm_expr e1, norm_expr e2))
    | Mem e1 -> loc (Mem (norm_expr e1))
    | Eseq (s, e1) -> loc (Eseq (norm_stmt s, norm_expr e1))
    | Call (f, args, typ) ->
        let stmts, call = norm_call f args typ in
        let t = temp_gen typ in
        loc (Eseq (seq_or_single (stmts @ [ loc (Move (loc (Temp t), call)) ]),
                   loc (Temp t)))
  and norm_call f args typ =
    let f' = norm_expr f in
    let f_stmts, f_arg =
      match f'.payload with
      | Const _ | ConstF _ | Name _ | Temp _ -> ([], f')
      | _ ->
          let t = temp_gen Int in
          ([ loc (Move (loc (Temp t), f')) ], loc (Temp t))
    in
    let arg_stmts, new_args =
      List.fold_left
        (fun (ms, eas) (arg_typ, arg_e) ->
          let arg_e' = norm_expr arg_e in
          let t = temp_gen arg_typ in
          (loc (Move (loc (Temp t), arg_e')) :: ms,
           (arg_typ, loc (Temp t)) :: eas))
        ([], []) args
    in
    (f_stmts @ List.rev arg_stmts,
     loc (Call (f_arg, List.rev new_args, typ)))
  and norm_stmt s =
    match s.payload with
    | Move (e1, { payload = Call (f, args, typ); _ }) ->
        let e1' = norm_expr e1 in
        let stmts, call = norm_call f args typ in
        let e2' =
          match stmts with
          | [] -> call
          | _ -> loc (Eseq (seq_or_single stmts, call))
        in
        loc (Move (e1', e2'))
    | Move (e1, e2) -> loc (Move (norm_expr e1, norm_expr e2))
    | Sxp { payload = Call (f, args, typ); _ } ->
        let stmts, call = norm_call f args typ in
        seq_or_single (stmts @ [ loc (Sxp call) ])
    | Sxp e -> loc (Sxp (norm_expr e))
    | Jump (e, labs) -> loc (Jump (norm_expr e, labs))
    | Cjump (r, e1, e2, l1, l2) ->
        loc (Cjump (r, norm_expr e1, norm_expr e2, l1, l2))
    | Seq stmts -> loc (Seq (List.map norm_stmt stmts))
    | Label _ | Litteral _ -> s
  in
  List.map norm_stmt p

(* Rewrites the program by linearizing it. At the end, no seq or eseq must remain *)
let linearize (temp_gen : typ -> string) (p : program) : program =
  let is_float_binop op = match op with
    | AddF | SubF | MulF | DivF -> true
    | _ -> false
  in
  let typ_of_expr default e =
    match e.payload with
    | ConstF _ -> Float
    | Temp t when is_float_temp t -> Float
    | Binop (op, _, _) when is_float_binop op -> Float
    | Call (_, _, typ) -> typ
    | _ -> default
  in
  let commutes stmts e =
    stmts = [] ||
    match e.payload with
    | Const _ | ConstF _ | Name _ -> true
    | _ -> false
  in
  let force_temp typ stmts e =
    let t = temp_gen typ in
    (stmts @ [ loc (Move (loc (Temp t), e)) ], loc (Temp t))
  in
  (* 处理表达式，返回 (前置语句列表, 不含Eseq的干净表达式) ,最终不含Eseq的干净表达式一定是干净的,因为已经消除掉了*)
  (* Traite l'expression et renvoie (liste des instructions préalables, expression propre sans Eseq) ; l'expression finale est nécessairement propre, puisque les Eseq ont déjà été éliminés *)
  let rec lin_expr e =
    match e.payload with
    (* 叶子节点：没有副作用，直接返回 *)
    (* Feuilles : pas d'effet de bord, on renvoie directement *)
    | Const _ | ConstF _ | Name _ | Temp _ -> ([], e)
    (* Eseq：提取语句，递归处理表达式 *)
    (* Eseq : on extrait l'instruction et on traite récursivement l'expression *)
    | Eseq (s, e1) ->
        let stmts1 = lin_stmt s in
        let (stmts2, e1') = lin_expr e1 in
        (stmts1 @ stmts2, e1')
    (* Mem：线性化地址表达式 *)
    (* Mem : on linéarise l'expression d'adresse *)
    | Mem e1 ->
        let (s1, e1') = lin_expr e1 in
        (s1, loc (Mem e1'))
    (* Binop：分别线性化左右子表达式，注意保护左边不被右边的副作用覆盖 *)
    (* Binop : on linéarise séparément les sous-expressions gauche et droite, en veillant à protéger la gauche des effets de bord de la droite *)
    | Binop (op, e1, e2) ->
        let (s1, e1') = lin_expr e1 in
        let (s2, e2') = lin_expr e2 in
        if commutes s2 e1' then (s1 @ s2, loc (Binop (op, e1', e2')))
        else
          let typ = if is_float_binop op then Float else Int in
          let (s1, e1') = force_temp typ s1 e1' in
          (s1 @ s2, loc (Binop (op, e1', e2')))
    (* Call：参数经过normalize_call已经都是Temp。*)
    (* Call : après normalize_call, tous les arguments sont déjà des Temp. *)
    | Call (f, args, typ) ->
        let (sf, f') = lin_expr f in
        (sf, loc (Call (f', args, typ)))
  (* 处理语句，返回平坦的语句列表（无嵌套Seq，无Eseq） *)
  (* Traite l'instruction et renvoie une liste plate d'instructions (sans Seq imbriqué, sans Eseq) *)
  (* move什么的都还保留着,但是把seq和eseq消除掉了*)
  (* Les Move et autres sont conservés, mais on élimine les Seq et Eseq *)
  and lin_stmt s =
    match s.payload with
    | Move ({ payload = Mem addr; _ }, src) ->
        let (s_addr, addr') = lin_expr addr in
        let (s_src, src') = lin_expr src in
        if commutes s_src addr' then
          s_addr @ s_src @ [ loc (Move (loc (Mem addr'), src')) ]
        else
          let (s_addr, addr') = force_temp Int s_addr addr' in
          s_addr @ s_src @ [ loc (Move (loc (Mem addr'), src')) ]
    (* Move：Move(_, Call) 和 Move(_, 普通 expr) 都合法，无需 extract *)
    (* Move : Move(_, Call) et Move(_, expression ordinaire) sont tous deux valides, pas besoin d'extraire *)
    | Move (e1, e2) ->
        let (s1, e1') = lin_expr e1 in
        let (s2, e2') = lin_expr e2 in
        s1 @ s2 @ [ loc (Move (e1', e2')) ]
    (* Sxp(Call) 和 Sxp(普通 expr) 都合法，无需 extract *)
    (* Sxp(Call) et Sxp(expression ordinaire) sont tous deux valides, pas besoin d'extraire *)
    | Sxp e ->
        let (stmts, e') = lin_expr e in
        stmts @ [ loc (Sxp e') ]
    | Jump (e, labs) ->
        let (stmts, e') = lin_expr e in
        stmts @ [ loc (Jump (e', labs)) ]
    | Cjump (r, e1, e2, l1, l2) ->
        let (s1, e1') = lin_expr e1 in
        let (s2, e2') = lin_expr e2 in
        if commutes s2 e1' then
          s1 @ s2 @ [ loc (Cjump (r, e1', e2', l1, l2)) ]
        else
          let typ = typ_of_expr Int e1' in
          let (s1, e1') = force_temp typ s1 e1' in
          s1 @ s2 @ [ loc (Cjump (r, e1', e2', l1, l2)) ]
    (* Seq：展平，对每条子语句递归处理再拼接 *)
    (* Seq : on aplatit, en traitant récursivement chaque sous-instruction puis en concaténant *)
    (* 这里要消除掉Seq*)
    (* Ici, on doit éliminer les Seq *)
    | Seq stmts ->
        List.concat_map lin_stmt stmts
    (* Label/Litteral：没有子表达式，原样返回（包进单元素列表） *)
    (* Label/Litteral : pas de sous-expression, on les renvoie tels quels (encapsulés dans une liste à un seul élément) *)
    | Label _ | Litteral _ -> [ s ]
  in
  List.concat_map lin_stmt p

(* CJUMP normalization: ensures that every CJUMP is immediately followed by its
   false label. *)
   (*这里只做了假标签一定立刻在后面*)
   (* Ici on garantit uniquement que le faux label suit immédiatement *)
let rec normalize_cjump (label_gen : unit -> string) (p : program) : program =
  match p with
  | [] -> []
  | s :: rest ->
      (match s.payload with
       | Cjump (r, e1, e2, t, f) ->
        (*这里是false label判断函数*)
        (* Ici, c'est la fonction qui teste si le faux label suit *)
           let false_follows =
             match rest with
             | next :: _ ->
              (*这里l=f是等于判断,判断true还是false,是不是后面的label标签就是false的那条分支标签*)
              (* Ici, l=f est un test d'égalité qui renvoie true ou false : on vérifie si le label qui suit est bien celui de la branche fausse *)
                 (match next.payload with Label l -> l = f | _ -> false)
             | [] -> false
           in
           if false_follows then s :: normalize_cjump label_gen rest
           else
            (* 这里是重构新的分支点*)
            (* Ici, on reconstruit un nouveau point de branchement *)
             let f' = label_gen () in
             let new_cjump = loc (Cjump (r, e1, e2, t, f')) in
             let new_label = loc (Label f') in
             (*这里是jump到一个我们造的假分支F',然后要去真正的新分支F,name把f包装成expr*)
             (* Ici, on saute vers le faux label F' que l'on vient de créer, puis vers la véritable branche F ; Name encapsule f en tant qu'expression *)
             let new_jump = loc (Jump (loc (Name f), [ f ])) in
             new_cjump :: new_label :: new_jump
             :: normalize_cjump label_gen rest
       | _ -> s :: normalize_cjump label_gen rest)

(** This function performs the transformation to LIR and generate the .lir file.
    operation made are:
    - call by value transformation
    - flattening of the sequences and eseq lift until a fixpoint is reached
    - It calls basic block reordering
    - naive CJump normalization (label insertion if needed) *)
let linearize (p : program) (filename : string) : program =
  let temp_gen = fresh_temp p in
  let label_gen = fresh_label p in
  let normalized_calls = normalize_call temp_gen p in
  let linearized = linearize temp_gen normalized_calls in
  let reordered = Blocks.reordering linearized in
  let normalized_cjump = normalize_cjump label_gen reordered in
  let oc = open_out filename in
  let fmt = Format.formatter_of_out_channel oc in
  Format.fprintf fmt "%a%!" print_prog normalized_cjump;
  normalized_cjump
