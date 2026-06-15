%{
open Tree
%}


/* Keywords */
%token CONST
%token CONSTF
%token NAME
%token TEMP
%token BINOP
%token MEM
%token CALL
%token CALLF
%token CALLEND
%token ESEQ
%token MOVE
%token SXP
%token JUMP
%token CJUMP
%token SEQ
%token SEQEND
%token LABEL

%token INT
%token FLOAT

/* Operators */
%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token XOR
%token ADDF
%token SUBF
%token MULF
%token DIVF

%token ULT
%token UGT
%token ULE
%token UGE
%token LT
%token GT
%token LE
%token GE
%token LTF
%token GTF
%token LEF
%token GEF
%token NEQ
%token NEQF
%token EQ
%token EQF

%token <string> TOK_id
%token <string> TOK_const
%token <string> TOK_float
%token <string> STRING

%token EOF

/* entry points */
%start <stmt list> program

%%

%public %inline loc(X):
x=X { {loc=($startpos,$endpos); payload=x} }

program:
  p=list(stmt) EOF {p}

stmt:
  | s=loc (rawstmt) {s}

rawstmt:
  | LABEL l=TOK_id                   { Label l }
  | LABEL l=TOK_id s=STRING          { Litteral (l,s) }
  | MOVE e1=expr e2=expr             { Move (e1,e2) }
  | SXP e=expr                       { Sxp e }
  | SEQ l=list(stmt) SEQEND          { Seq l }
  | CJUMP rop=relop e1=expr e2=expr NAME l1=TOK_id NAME l2=TOK_id { Cjump (rop,e1,e2,l1,l2)}
  | JUMP e=expr labs=list(TOK_id)    { Jump (e,labs) }

expr:
  | e = loc (rawexpr) {e}

rawexpr:
  | CONST c=TOK_const                    { Const c }
  | CONSTF c=TOK_float                   { ConstF c }
  | TEMP id=TOK_id                       { Temp id }
  | MEM e=expr                           { Mem e }
  | BINOP b=bop e1=expr e2=expr          { Binop(b,e1,e2) }
  | NAME l=TOK_id                        { Name l }
  | CALL f=expr args=list(arg) CALLEND   { Call (f,args,Int) }
  | CALLF f=expr args=list(arg) CALLEND  { Call (f,args,Float) }
  | ESEQ s=stmt e=expr                   { Eseq (s,e) }

arg:
  | e=expr { (Int, e) }
  | INT e=expr { (Int, e) }
  | FLOAT e=expr { (Float, e) }

bop:
  | ADD {Add}
  | MUL {Mul}
  | SUB {Sub}
  | DIV {Div}
  | MOD {Mod}
  | XOR {Xor}
  | ADDF {AddF}
  | MULF {MulF}
  | SUBF {SubF}
  | DIVF {DivF}

relop:
  | EQF { EqF }
  | NEQF { NeqF }
  | EQ { Eq }
  | NEQ { Neq }
  | LT { LT }
  | GT { GT }
  | LE { LE }
  | GE { GE }
  | LTF { LTF }
  | GTF { GTF }
  | LEF { LEF }
  | GEF { GEF }
  | ULT { ULT }
  | UGT { UGT }
  | ULE { ULE }
  | UGE { UGE }
