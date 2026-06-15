(*
             /\
            <  >
             \/
             /\
            /  \
           /++++\
          /  ()  \
          /      \
         /~`~`~`~`\
        /  ()  ()  \
        /          \
       /*&*&*&*&*&*&\
      /  ()  ()  ()  \
      /              \
     /++++++++++++++++\
    /  ()  ()  ()  ()  \
    /                  \
   /~`~`~`~`~`~`~`~`~`~`\
  /  ()  ()  ()  ()  ()  \
  /*&*&*&*&*&*&*&*&*&*&*&\
 /                        \
/,.,.,.,.,.,.,.,.,.,.,.,.,.\
           |   |
          |`````|
          \_____/
*)

type location = Lexing.position * Lexing.position

(* Polymorphic located values. Locations are a range of position in the source
   file *)
type 'a located = { payload : 'a; loc : location }

(* Language *)

type label = string

type op =
  (* The integer arithmetic *)
  | Add
  | Sub
  | Mul
  | Div
  | Mod
  (* The float arithmetic *)
  | AddF
  | SubF
  | MulF
  | DivF
  (* integer bitwise logical operators *)
  | And
  | Or
  | Xor
  (* integer logical shift operators*)
  | LShift
  | RShift
  (* integer arithmetic right-shift *)
  | ARshift

type relop =
  (* float equality and nonequality *)
  | EqF
  | NeqF
  (* integer equality and nonequality (signed or unsigned) *)
  | Eq
  | Neq
  (* signed integer inequalities *)
  | LT
  | GT
  | LE
  | GE
  (* float inequalities *)
  | LTF
  | GTF
  | LEF
  | GEF
  (* unsigned integer inequalities *)
  | ULT
  | ULE
  | UGT
  | UGE

type typ = Float | Int

(* The expressions stand for the computation of some value (possibly with side
   effects) *)
type expr_payload =
  | Const of string (* integer constants *)
  | ConstF of string (* float constants *)
  | Name of label
  (* symbolic constants (corresponding to an assembly language label) *)
  | Temp of string
  (* Temporary t. A temporary in the abstract machine is similar to a register
     in a real machine. However, the abstract machine has an infinite number of
     temporaries. *)
  | Binop of op * expr * expr
  (* BINOP(o, e1, e2) The application of binary operator o to operands e1, e2.
     Subexpression e1 is evaluated before e2. he *)
  | Mem of expr
  (* MEM(e) The contents of wordSize bytes of memory starting at address e
     (where wordSize is defined in the Frame module). Note that when MEM is used
     as the left child of a MOVE, it means "store", but anywhere else it means
     "fetch."*)
  | Call of expr * args * typ
    (* CALL(f, l) A procedure call: the application of function f to argument list
     l. The subexpression f is evaluated before the arguments which are
     evaluated left to right. Return type is indicated in typ*)
  | Eseq of stmt * expr
(* ESEQ(s, e) The statement s is evaluated for side effects, then e is evaluated
   for a result *)

and args = (typ * expr) list (* args are typed *)
and expr = expr_payload located

(* The statements perform side effects and control flow *)
and stmt_payload =
  | Move of expr * expr
  (* MOVE(TEMP t, e) Evaluate e and move it into temporary t. MOVE(MEM(e1) e2)
     Evaluate e1, yielding address a. The nevaluate e2, and store the result
     into wordSize bytes of memory starting at a. *)
  | Sxp of expr (* SXP(e) Evaluate e and discard the result. *)
  | Jump of expr * label list
  (* JUMP(e, labs) Transfer control (jump) to address e. The destination e may
     be a literal label, as in NAME( lab), or it may be an address calculated by
     any other kind of expression. For example, a C-language switch(i) statement
     may be implemented by doing arithmetic on i. The list of labels labs
     specifies all the possible locations that the expression e can evaluate to;
     this is necessary for dataflow analysis later. The common case of jumping
     to a known label l is written as JUMP(NAME l, []) *)
  | Cjump of relop * expr * expr * label * label
  (* CJUMP(o, e1, e2, t, f) Evaluate e1, e2 in that order, yielding values a, b.
     Then compare a, b using the relational operator o. If the result is true,
     jump to t; otherwise jump to f . The relational operators *)
  | Seq of stmt list (* SEQ(s1, s2) The statement s1 followed by s2. *)
  | Label of label
  (* LABEL(n) Define the constant value of name n to be the current machine code
     address. This is like a label definition in assembly language. The value
     NAME(n) may be the target of jump *)
  | Litteral of label * string
(* string litteral data stored at given label *)

and stmt = stmt_payload located

type program = stmt list

(* Printing *)

let binop_to_string = function
  | Add -> "add"
  | Sub -> "sub"
  | Mul -> "mul"
  | Div -> "div"
  | AddF -> "addF"
  | SubF -> "subF"
  | MulF -> "mulF"
  | DivF -> "divF"
  | Mod -> "mod"
  | Or -> "or"
  | And -> "and"
  | Xor -> "xor"
  | LShift -> "<<"
  | RShift -> ">>"
  | ARshift -> "arshift"

let relop_to_string = function
  | EqF -> "eqF"
  | NeqF -> "neF"
  | Eq -> "eq"
  | Neq -> "ne"
  | LT -> "lt"
  | GT -> "gt"
  | LE -> "le"
  | GE -> "ge"
  | LTF -> "ltF"
  | GTF -> "gtF"
  | LEF -> "leF"
  | GEF -> "geF"
  | ULT -> "lt"
  | UGT -> "ugt"
  | ULE -> "ule"
  | UGE -> "uge"

let rec print_expr fmt e =
  match e.payload with
  | Const i -> Format.fprintf fmt "const %s" i
  | ConstF i -> Format.fprintf fmt "constF %s" i
  | Name l -> Format.fprintf fmt "name %s" l
  | Temp s -> Format.fprintf fmt "temp %s" s
  | Binop (op, e1, e2) ->
      Format.fprintf fmt "binop %s %a %a" (binop_to_string op) print_expr e1
        print_expr e2
  | Mem e -> Format.fprintf fmt "mem %a" print_expr e
  | Call (f_expr, args, Float) ->
      Format.fprintf fmt "@[<hv 2>callF@ %a@ %a@ call end@]" print_expr f_expr
        print_args args
  | Call (f_expr, args, Int) ->
      Format.fprintf fmt "@[<hv 2>call@ %a@ %a@ call end@]" print_expr f_expr
        print_args args
  | Eseq (stmt, expr) ->
      Format.fprintf fmt "@[<v 2>eseq@,%a@,%a@]" print_stmt stmt print_expr expr

and print_stmt fmt s =
  match s.payload with
  | Move (e1, e2) ->
      Format.fprintf fmt "@[<hv 2>move@ %a@ %a@ @]" print_expr e1 print_expr e2
  | Sxp e -> Format.fprintf fmt "@[<v 2>sxp@,%a@]" print_expr e
  | Jump (e, _labs) -> Format.fprintf fmt "@[<hv 2>jump %a@ @]" print_expr e
  | Cjump (r, e1, e2, l1, l2) ->
      Format.fprintf fmt "@[<hv 2>cjump@ %s@ %a@ %a@ name %s@ name %s@ @]"
        (relop_to_string r) print_expr e1 print_expr e2 l1 l2
  | Seq s ->
      Format.fprintf fmt "@[<v 2>seq@,%a@]@,seq end"
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt "@;")
           print_stmt)
        s
  | Label l -> Format.fprintf fmt "label %s" l
  | Litteral (l, s) ->
      Format.fprintf fmt "label %s@, \"%s\"" l (String.escaped s)

and print_args fmt args =
  Format.fprintf fmt "%a"
    (Format.pp_print_list ~pp_sep:Format.pp_print_space print_arg)
    args

and print_arg fmt (t, a) = Format.fprintf fmt "%a %a" print_typ t print_expr a

and print_typ fmt = function
  | Int -> Format.fprintf fmt "int"
  | Float -> Format.fprintf fmt "float"

let print_prog fmt (p : program) =
  Format.fprintf fmt "@[<v>%a@]@," (Format.pp_print_list print_stmt) p

let print_location fmt (p1, p2) =
  let open Lexing in
  Format.fprintf fmt "Line %i, col %i to Line %i, col %i" p1.pos_lnum
    (p1.pos_cnum - p1.pos_bol) p2.pos_lnum (p2.pos_cnum - p2.pos_bol)
