{
 open Lexing
 open Parser

exception Lexical_error of string * string * int * int

let string_buff = Buffer.create 256

let char_for_backslash = function
  | 'a' -> '\007'
  | 'b' -> '\008'
  | 't' -> '\009'
  | 'n' -> '\010'
  | 'v' -> '\011'
  | 'f' -> '\012'
  | 'r' -> '\013'
  | c   -> c

let raise_lexical_error lexbuf msg =
  let p = Lexing.lexeme_start_p lexbuf in
  raise (Lexical_error (msg,
                        p.Lexing.pos_fname,
                        p.Lexing.pos_lnum,
                        p.Lexing.pos_cnum - p.Lexing.pos_bol + 1))

(* keyword table *)
let kwd_table = Hashtbl.create 30
let _ =
  List.iter (fun (a,b) -> Hashtbl.add kwd_table a b)
    [
      "const",      CONST;
      "constF",      CONSTF;
      "name",       NAME;
      "temp",       TEMP;
      "binop",      BINOP;
      "mem",        MEM;
      "call",       CALL;
      "callF",      CALLF;
      "eseq",       ESEQ;
      "move",       MOVE;
      "sxp",        SXP;
      "jump",       JUMP;
      "cjump",      CJUMP;
      "seq",        SEQ;
      "label",      LABEL;
      "add",        ADD;
      "sub",        SUB;
      "mul",        MUL;
      "div",        DIV;
      "xor",        XOR;
      "addF",       ADDF;
      "subF",       SUBF;
      "mulF",       MULF;
      "divF",       DIVF;
      "mod",        MOD;
      "lt",         LT;
      "gt",         GT;
      "le",         LE;
      "ge",         GE;
      "ltF",        LTF;
      "gtF",        GTF;
      "leF",        LEF;
      "geF",        GEF;
      "ult",        ULT;
      "ugt",        UGT;
      "ule",        ULE;
      "uge",        UGE;
      "eq",         EQ;
      "eqF",        EQF;
      "ne",         NEQ;
      "neF",        NEQF;
      "int",        INT;
      "float",      FLOAT;
    ]
}

(* character classes *)
let space = [' ' '\t' '\r']+
let newline = "\n" | "\r" | "\r\n"
let digit = ['0'-'9']
let hex = ['0'-'9' 'A'-'F'] | ['0'-'9' 'a'-'f']
let octal = ['0'-'7']
let cst = ('-'?digit+)
let float = cst '.' digit*

let backslash_escapes =
    ['\\' '\'' '"' 'a' 'b' 'f' 'n' 'r' 't' 'v' ' ']
let backslash_hex = hex hex ?
let backslash_octal = octal octal ? octal ?

rule token = parse
(* identifier or reserved keyword *)
| ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_'] * ('.'['a'-'z' 'A'-'Z' '0'-'9' '_']+) ? as id
{ try Hashtbl.find kwd_table id with Not_found -> TOK_id id }

(* symbols *)
| "+"    { ADD }
| "-"    { SUB }
| "*"    { MUL }
| "/"    { DIV }
| "+."   { ADDF }
| "-."   { SUBF }
| "*."   { MULF }
| "/."   { DIVF }
| "%"    { MOD}
| "<"    { LT }
| ">"    { GT }
| "<="   { LE }
| ">="   { GE }
| "="    { EQ }
| "<>"   { NEQ }

(* literals *)
| cst as c { TOK_const c }
| float as f { TOK_float f }

(* keywords with spaces *)
| "call end" {CALLEND}
| "seq end"  {SEQEND}

| '"'
    { Buffer.clear string_buff;
      string lexbuf;
      STRING (Buffer.contents string_buff) }

(* spaces, comments *)
| "/*" { comment lexbuf; token lexbuf }
| "#" [^ '\n' '\r']* { token lexbuf }
| newline { new_line lexbuf; token lexbuf }
| space { token lexbuf }
(* end of file *)
| eof { EOF }
| _
    { raise_lexical_error lexbuf
        ("illegal character " ^ String.escaped(Lexing.lexeme lexbuf))
    }

(* nested comments (handled recursively)  *)
and comment = parse
| "*/" { () }
| [^ '\n' '\r'] { comment lexbuf }
| newline { new_line lexbuf; comment lexbuf }

and string = parse
| '"' { () }
| '\\' (backslash_escapes as c)
    { Buffer.add_char string_buff (char_for_backslash c);
      string lexbuf }
| '\\' 'x' (backslash_hex as c)
    { Buffer.add_char string_buff (Char.chr (int_of_string ("0x" ^ c)));
      string lexbuf }
| '\\' (backslash_octal as c)
    { Buffer.add_char string_buff (Char.chr (int_of_string ("0o" ^ c)));
      string lexbuf }
| _ as c
    { Buffer.add_char string_buff c;
      string lexbuf }
