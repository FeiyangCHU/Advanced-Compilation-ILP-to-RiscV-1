open Lexing
open Utils
open Exceptions

(* open a file and parse it *)
let parse (filename : string) =
  let f = open_in filename in
  let lex = from_channel f in
  let fileparser = Parser.program Lexer.token in
  try
    lex.lex_curr_p <- { lex.lex_curr_p with pos_fname = filename };
    fileparser lex
  with
  | Lexer.Lexical_error (msg, _, _, _) ->
      let msg =
        Format.asprintf "Lexical Error \"%s\" in %a\n" msg Errors.from_lex lex
      in
      close_in f;
      raise (LexingError msg)
  | _ ->
      let msg = Format.asprintf "Syntax Error in %a\n" Errors.from_lex lex in
      close_in f;
      raise (ParsingError msg)
