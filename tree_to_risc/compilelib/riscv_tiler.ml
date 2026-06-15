open Treelib
open Tree
open Tree_helper
open! Asm
open! Backend

(* integer registers *)
let registers = [ "s1"; "s2"; "s3"; "s4"; "s5"; "s6" ]

(* floating-point registers *)
let f_registers = [ "fs0"; "fs1"; "fs2"; "fs3"; "fs4"; "fs5"; "fs6" ]

let callee_saved =
  [
    (* integer *)
    "s0";
    "s1";
    "s2";
    "s3";
    "s4";
    "s5";
    "s6";
    "s7";
    "s8";
    "s9";
    "s10";
    "s11";
    (* floating-point *)
    "fs0";
    "fs1";
    "fs2";
    "fs3";
    "fs4";
    "fs5";
    "fs6";
    "fs7";
    "fs8";
    "fs9";
    "fs10";
    "fs11";
  ]

let caller_saved =
  [
    (* return address *)
    "ra";
    (* integer temporaries *)
    "t0";
    "t1";
    "t2";
    "t3";
    "t4";
    "t5";
    "t6";
    (* floating-point temporaries *)
    "ft0";
    "ft1";
    "ft2";
    "ft3";
    "ft4";
    "ft5";
    "ft6";
    "ft7";
    "ft8";
    "ft9";
    "ft10";
    "ft11";
  ]

let precolored = [ ("rv", "a0") ]
let f_precolored = [ ("fv", "fa0") ]

let asm_of_binop = function
  (* integer *)
  | Add -> "add"
  | Sub -> "sub"
  | Mul -> "mul"
  | Div -> "div"
  | And -> "and"
  | Or -> "or"
  | Xor -> "xor"
  | Mod -> "rem"
  (* floating-point *)
  | AddF -> "fadd.s"
  | SubF -> "fsub.s"
  | MulF -> "fmul.s"
  | DivF -> "fdiv.s"
  (* integer shifts *)
  | LShift -> "sll"
  | RShift -> "srl"
  | ARshift -> "sra"


(* Lowers a single IR statement (Tree.stmt) into one or more RISC-V assembly
   instructions (Asm.instr).
   The rewriter 'r' is used to generate fresh temporaries when needed
   expr_to_temp: ensures that an IR expression is evaluated and its value is stored
   in a temporary register.

   - If the expression is already a Temp, it simply returns that temp.
   - Otherwise, it generates the necessary instructions to compute the
     expression into a fresh temporary and returns that temp.

   This guarantees that instruction selection always works with
   register operands (temps), not complex IR expressions.
 *)

(* Add parameter move insertion at function entry *)
let param_moves params =
  List.mapi
    (fun i temp ->
      let reg =
        if Tree_helper.is_float_temp temp then "fa" ^ string_of_int i
        else "a" ^ string_of_int i
      in
      Asm.move_param ~dst:temp ~src:reg)
    params

(* Move a temp into a float register.
   If the temp is already a float temp, return it directly.
   Otherwise emit fcvt.s.w to convert the integer value. *)
   (*因为这里fmv什么的只接受左右两个一样的值,所以这个函数的作用就是把拿到的值变成Float*)
   (* Comme ici, fmv et les fonctions similaires n’acceptent que deux valeurs de même type,
   le rôle de cette fonction est de convertir la valeur obtenue en Float. *)
let ensure_float r t =
  if Tree_helper.is_float_temp t then ([], t)
  else
    let ft = r.fresh_temp Float in
    let conv =
      (*Oper是生成一条汇编指令,这里是生成新浮点temp ft,然后把t的值放进去,返回ft*)
      (*d0,s0占位符,这里用fmv是因为tile_mem生成的temp是整数但是他们之后要用浮点转换啥的 *)
      (* Oper génère une instruction assembleur. Ici, on crée un nouveau temp flottant ft,
   puis on y place la valeur de t, et on retourne ft. *)
(* d0 et s0 sont des placeholders. Ici, on utilise fmv parce que le temp généré par tile_mem
   est un entier, mais il devra ensuite être utilisé pour des conversions flottantes, etc. *)
      Oper { assem = "fcvt.s.w `d0, `s0"; dst = [ft]; src = [t];
             jump = None; is_call = false }
    in
    ([conv], ft)

(* Cross-type move between temporaries.
   Emits the correct instruction even when src and dst have different types:
   - same type: mv / fmv.s
   - int src, float dst: fcvt.s.w
   - float src, int dst: fcvt.w.s *)
   (*自动处理整型和浮点之间的移动*)
   (* Gérer automatiquement les déplacements entre entiers et flottants. *)
let cross_move ~dst ~src =
  if Tree_helper.is_float_temp dst && not (Tree_helper.is_float_temp src) then
    [ Oper { assem = "fcvt.s.w `d0, `s0"; dst = [dst]; src = [src];
             jump = None; is_call = false } ]
  else if (not (Tree_helper.is_float_temp dst)) && Tree_helper.is_float_temp src then
    [ Oper { assem = "fcvt.w.s `d0, `s0"; dst = [dst]; src = [src];
             jump = None; is_call = false } ]
  else
    [ Asm.move_instr ~dst ~src ]

(* Emit the pair of instructions for a conditional branch:
     bXX t1, t2, lt   (branch to true label)
     j lf              (fall through to false label)
   For float relops, first emit a float compare into an integer temp,
   then branch on that temp. *)
   (* 把cjump翻译好了*)
let cjump_instrs r relop t1 t2 lt lf =
  if Tree_helper.is_float_cmp relop then begin
    (*t_res整形存结果*)
    (* t_res stocke le résultat sous forme entière. *)
    let t_res = r.fresh_temp Int in
    let (cmp_assem, swap, negate) = match relop with
      | EqF  -> ("feq.s `d0, `s0, `s1", false, false)
      | NeqF -> ("feq.s `d0, `s0, `s1", false, true)  (* branch to lt when feq=0 *)
      | LTF  -> ("flt.s `d0, `s0, `s1", false, false) (*这个会匹配到cmp_assem,swap,negate上去*)
      | GTF  -> ("flt.s `d0, `s0, `s1", true,  false)
      | LEF  -> ("fle.s `d0, `s0, `s1", false, false)
      | GEF  -> ("fle.s `d0, `s0, `s1", true,  false)
      | _ -> assert false
    in
    let (f1, f2) = if swap then (t2, t1) else (t1, t2) in
    let cmp_instr =
      Oper { assem = cmp_assem; dst = [t_res]; src = [f1; f2];
             jump = None; is_call = false }
    in
    let branch_assem =
      if negate then "beqz `s0, " ^ lt
      else             "bnez `s0, " ^ lt
    in
    let branch_lt =
      Oper { assem = branch_assem; dst = []; src = [t_res];
             jump = Some [lt; lf]; is_call = false }
    in
    let branch_lf =
      Oper { assem = "j " ^ lf; dst = []; src = [];
             jump = Some [lf]; is_call = false }
    in
    [cmp_instr; branch_lt; branch_lf]
  end else begin
    (* Integer branch: bXX s1, s2, lt *)
    let (branch_assem, swap) = match relop with
      | Eq  -> ("beq `s0, `s1, "  ^ lt, false)
      | Neq -> ("bne `s0, `s1, "  ^ lt, false)
      | LT  -> ("blt `s0, `s1, "  ^ lt, false)
      | GT  -> ("blt `s0, `s1, "  ^ lt, true)   
      | LE  -> ("bge `s0, `s1, "  ^ lt, true)   
      | GE  -> ("bge `s0, `s1, "  ^ lt, false)
      | ULT -> ("bltu `s0, `s1, " ^ lt, false)
      | UGT -> ("bltu `s0, `s1, " ^ lt, true)
      | ULE -> ("bgeu `s0, `s1, " ^ lt, true)
      | UGE -> ("bgeu `s0, `s1, " ^ lt, false)
      | _ -> assert false
    in
    let (s1, s2) = if swap then (t2, t1) else (t1, t2) in
    let branch_lt =
      Oper { assem = branch_assem; dst = []; src = [s1; s2];
             jump = Some [lt; lf]; is_call = false }
    in
    let branch_lf =
      Oper { assem = "j " ^ lf; dst = []; src = [];
             jump = Some [lf]; is_call = false }
    in
    [branch_lt; branch_lf]
  end

(*六种语句翻译成asm*)
(* Traduire les six types d’instructions en ASM. *)
  let munch_stm (r : rewritter) (expr_to_temp : expr -> temp) (s : stmt) =
  match s.payload with
  | Tree.Move ({ payload = Temp "fv"; _ }, src) ->
      let ts = expr_to_temp src in
      [ Oper { assem = "fmv.s fa0, `s0"; dst = ["fv"]; src = [ts];
               jump = None; is_call = false } ]
  | Tree.Move ({ payload = Temp t; _ }, src) ->
      let ts = expr_to_temp src in
      cross_move ~dst:t ~src:ts

  | Tree.Move ({ payload = Mem addr_expr; _ }, src) ->
      let t_addr = expr_to_temp addr_expr in
      let t_src  = expr_to_temp src in
      let op = if Tree_helper.is_float_temp t_src then "fsw" else "sd" in
      [ Oper { assem = op ^ " `s1, 0(`s0)"; dst = [];
               src = [t_addr; t_src]; jump = None; is_call = false } ]

  | Tree.Jump ({ payload = Name l; _ }, _) ->
      [ Oper { assem = "j " ^ l; dst = []; src = [];
               jump = Some [l]; is_call = false } ]

  | Tree.Jump (e, labs) ->
      let t = expr_to_temp e in
      [ Oper { assem = "jr `s0"; dst = []; src = [t];
               jump = Some labs; is_call = false } ]

  | Tree.Cjump (relop, e1, e2, lt, lf) ->
      let t1 = expr_to_temp e1 in
      let t2 = expr_to_temp e2 in
      cjump_instrs r relop t1 t2 lt lf

  | Tree.Label "end" ->
      []
  | Tree.Label l ->
      [ Asm.label l ]

  | _ ->
      failwith (Format.asprintf "munch_stm: %a not supported" print_stmt s)

(* Instruction-selection tile for integer constants.
   This tile matches IR expressions of the form:
       Const n

   When selected, it:
     1. Creates a fresh temporary register.
     2. Emits a single "load immediate" instruction that loads
        the constant value n into that temporary.
     3. Returns the generated instruction along with the temp
        holding the result. *)
let tile_const r =
  {
    cost = 1;
    matches_exp = (function { payload = Const _; _ } -> true | _ -> false);
    emit_exp =
      (fun _ e _ ->
        match e.payload with
        | Const n ->
            let t = r.fresh_temp Int in
            ([ Asm.load_immediate ~temp:t ~imm:n ], t)
        | _ -> assert false);
  }

(* Tile for register temporaries: Temp t → return t with no instructions. *)
(* Tile本质是把IR节点算出来的值放进一个temp*)
(* Un tile consiste essentiellement à placer la valeur calculée par un nœud IR dans un temp. *)
let tile_temp =
  {
    cost = 0;
    matches_exp = (function { payload = Temp _; _ } -> true | _ -> false);
    emit_exp =
      (fun _ e _ ->
        match e.payload with
        | Temp t -> ([], t)
        | _ -> assert false);
  }

(* Tile for floating-point constants: ConstF f
   Load the single-precision float stored in .rodata via its label:
     la  t_aux, L_float_n
     flw ft,    0(t_aux) *)
let tile_constF r =
  {
    cost = 2;
    matches_exp = (function { payload = ConstF _; _ } -> true | _ -> false);
    emit_exp =
      (fun _ e float_literals ->
        match e.payload with
        | ConstF s ->
            let label = Utils.SMap.find s float_literals in
            let t_aux = r.fresh_temp Int in
            let ft    = r.fresh_temp Float in
            let load_addr =
              Oper { assem = "la `d0, " ^ label; dst = [t_aux]; src = [];
                     jump = None; is_call = false }
            in
            let load_f =
              Oper { assem = "flw `d0, 0(`s0)"; dst = [ft]; src = [t_aux];
                     jump = None; is_call = false }
            in
            ([load_addr; load_f], ft)
        | _ -> assert false);
  }

(* Tile for symbolic labels: Name l → la t, l *)
let tile_name r =
  {
    cost = 1;
    matches_exp = (function { payload = Name _; _ } -> true | _ -> false);
    emit_exp =
      (fun _ e _ ->
        match e.payload with
        | Name l ->
            let t = r.fresh_temp Int in
            let instr =
              Oper { assem = "la `d0, " ^ l; dst = [t]; src = [];
                     jump = None; is_call = false }
            in
            ([instr], t)
        | _ -> assert false);
  }

(* Tile for binary operations: Binop(op, e1, e2)
   Recursively lower both operands, then emit the corresponding instruction.
   For float ops, ensure both operands are in float registers. *)
let tile_binop r =
  {
    cost = 1;
    matches_exp = (function { payload = Binop _; _ } -> true | _ -> false);
    emit_exp =
      (fun recurse e _ ->
        match e.payload with
        | Binop (op, e1, e2) ->
            let t1 = recurse e1 in
            let t2 = recurse e2 in
            let is_fop = Tree_helper.is_float op in
            let asm_op = asm_of_binop op in
            if is_fop then begin
              let (c1, ft1) = ensure_float r t1 in
              let (c2, ft2) = ensure_float r t2 in
              let dst = r.fresh_temp Float in
              let instr = Asm.binary_instr ~op:asm_op ~dst ~src1:ft1 ~src2:ft2 in
              (*这里是先转换再进instr里面运算*)
              (* Ici, on effectue d’abord la conversion, puis on entre dans instr pour faire le calcul. *)
              (c1 @ c2 @ [instr], dst)
            end else begin
              let dst = r.fresh_temp Int in
              let instr = Asm.binary_instr ~op:asm_op ~dst ~src1:t1 ~src2:t2 in
              ([instr], dst)
            end
        | _ -> assert false);
  }

(* Tile for memory loads: Mem(e) → ld t, 0(t_addr) *)
let tile_mem r =
  {
    cost = 2;
    matches_exp = (function { payload = Mem _; _ } -> true | _ -> false);
    emit_exp =
      (fun recurse e _ ->
        match e.payload with
        | Mem addr_expr ->
            let t_addr = recurse addr_expr in
            let t = r.fresh_temp Int in
            let instr =
              Oper { assem = "ld `d0, 0(`s0)"; dst = [t]; src = [t_addr];
                     jump = None; is_call = false }
            in
            ([instr], t)
        | _ -> assert false);
  }

(* Tile for function calls: Call(f, args, ret_typ)
   1. Evaluate each argument and move it into the appropriate physical register
      (a0/a1/… for Int args, fa0/fa1/… for Float args, counted independently).
   2. Emit the call instruction.
   3. Capture the return value from a0 (Int) or fa0 (Float). *)
let tile_call r =
  {
    cost = 3;
    matches_exp = (function { payload = Call _; _ } -> true | _ -> false);
    emit_exp =
      (fun recurse e _ ->
        match e.payload with
        | Call (f_expr, args, ret_typ) ->
            let instrs = ref [] in
            (*每次调用emit就输出一行指令到instrs里*)
            (* Chaque appel à emit ajoute une ligne d’instruction dans instrs. *)
            let emit i = instrs := i :: !instrs in

            let int_count   = ref 0 in
            let float_count = ref 0 in
            List.iter
            (* 把所有的参数都存起来*)
              (fun (typ, arg_expr) ->
                let t = recurse arg_expr in
                (match typ with
                | Int ->
                  (*这里是吧一个个参数存放到整数或者浮点数的寄存器里面*)
                  (* Ici, on place chaque argument dans un registre entier ou flottant. *)
                    let reg = "a" ^ string_of_int !int_count in
                    incr int_count;
                    emit
                      (Oper { assem = "mv " ^ reg ^ ", `s0"; dst = []; src = [t];
                               jump = None; is_call = false })
                | Float ->
                    let reg = "fa" ^ string_of_int !float_count in
                    incr float_count;
                    let mv_assem =
                      if Tree_helper.is_float_temp t then
                        "fmv.s " ^ reg ^ ", `s0"
                      else
                        "fcvt.s.w " ^ reg ^ ", `s0"
                    in
                    emit
                      (Oper { assem = mv_assem; dst = []; src = [t];
                               jump = None; is_call = false })))
              args;

            let fname =
              match f_expr.payload with
              | Name l -> l
              | _ -> failwith "tile_call: indirect calls not supported"
            in
            emit
              (*这里是真正的函数调用*)
              (* Ici, c’est le véritable appel de fonction. *)
              (Oper { assem = "call " ^ fname; dst = []; src = [];
                       jump = None; is_call = true });
            (*把最后的值存起来放进temp,原来的那些a0什么的都会被消掉*)
            (* Stocker la valeur finale dans un temp ; les registres d’origine comme a0 seront écrasés. *)
            let ret_temp = r.fresh_temp ret_typ in
            emit (Asm.return_value ~dst:ret_temp);

            (List.rev !instrs, ret_temp)
        | _ -> assert false);
  }

let tiles r =
  [
    tile_temp;
    tile_const r;
    tile_constF r;
    tile_name r;
    tile_binop r;
    tile_mem r;
    tile_call r;
  ]

let file_prologue =
  ".text\n.globl main\nmain:\n" ^ "  addi sp, sp, -16\n" ^ "  sd ra, 8(sp)\n"
  ^ "  # Call ILPmain\n" ^ "  jal ra, ILPmain\n" ^ "  li a0, 0\n"
  ^ "  ld ra, 8(sp)\n" ^ "  addi sp, sp, 16\n" ^ "  ret\n"

let file_epilogue = ""
