open Utils

exception LexingError of string
(** raised during lexing when input is invalid *)

exception ParsingError of string
(** raised during parsing when input is invalid *)

exception IllFormed of string
(** raised during static checks *)

let ill_formed msg location =
  raise
    (IllFormed
       (Format.asprintf "Ill-formed program, \"%s\" in %a\n" msg Errors.from_loc
          location))

exception RuntimeError of string
(** raised at runtime when some invalid operation is executed *)

let runtime_error msg location =
  if !error_verbose then
    raise
      (RuntimeError
         (Format.asprintf "\"%s\" in %a\n" msg Errors.from_loc location))
  else raise (RuntimeError (Format.asprintf "%s" msg))
