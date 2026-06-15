open Treelib
open Utils
open Exceptions

let globaldescr = "virtual machine for the Tree Language"
let memsize_msg = Format.sprintf "Set the memory size (default : %d)" !heapsize

let options =
  let set_size (size : int ref) (x : int) : unit =
    size := 8 * div_ceiling x 8 (* should work for both 32 and 64 bytes *)
  in
  [
    ("--show-ast", Arg.Set show_ast, "Enables the printing of the AST");
    ("--error-verbose", Arg.Set error_verbose, "Enables detailed error output");
    ("--memory-size", Arg.Int (set_size heapsize), memsize_msg);
    ("--trace", Arg.Set trace, "Print the trace execution");
    ("--unsafe", Arg.Set unsafe, "Don't perform the static checks");
    ( "--32",
      Arg.Unit (fun () -> Utils.word_size := 32),
      "Emulates a 32 bits machine" );
    ( "--64",
      Arg.Unit (fun () -> Utils.word_size := 64),
      "Emulates a 64 bits machine" );
  ]

let parse_args () =
  let set_prog s =
    if Sys.file_exists s then file := s
    else Terminal.error (Format.sprintf "%s : file not found" s) 1
  in
  try
    Arg.parse_argv Sys.argv options set_prog globaldescr;

    if !show_version then (
      print_version ();
      exit 0)
    else if !file = "" then Terminal.error "no filename specified" 64;
    !file
  with
  | Arg.Bad s -> Terminal.error s 64
  | Arg.Help s ->
      Format.printf "%s" s;
      exit 0

let () =
  try
    let file = parse_args () in
    if !trace then (
      Format.printf "@[Parsing ";
      Terminal.cyan_fprintf "%s@,@]" file);
    let prog = Fileparser.parse file in
    if not !unsafe then StaticChecks.go prog;
    if String.ends_with ~suffix:".hir" file then ()
    else if String.ends_with ~suffix:".lir" file then
      StaticChecks.linear_check_prog prog
    else Terminal.error ("unrecognized extension" ^ file) 1;
    Eval.run prog
  with
  | Arg.Help msg | Arg.Bad msg -> Format.printf "%s" msg
  | LexingError msg | ParsingError msg | IllFormed msg -> Terminal.error msg 1
  | e -> Terminal.error (Printexc.to_string e) 1
