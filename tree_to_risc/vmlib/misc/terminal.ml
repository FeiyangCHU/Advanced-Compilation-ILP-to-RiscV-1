open Utils

(** terminal output with a color given in parameter restoring default color
    after use *)
let color_printf col x =
  Format.kasprintf (fun s -> Format.printf "%s%s%s" col s "\027[0m") x

(** red terminal output *)
let color_eprintf col x =
  Format.kasprintf (fun s -> Format.eprintf "%s%s%s" col s "\027[0m") x

(** red terminal output *)
let red_fprintf x = color_printf "\027[31m" x

(** red terminal output *)
let red_eprintf x = color_eprintf "\027[31m" x

(** blue terminal output *)
let cyan_fprintf x = color_printf "\027[36m" x

(** green terminal output *)
let green_fprintf x = color_printf "\027[32m" x

(** yellow terminal output *)
let yellow_fprintf x = color_printf "\027[33m" x

let ok () = green_fprintf "\xE2\x9C\x94%!\n"
let ko () = red_fprintf "\xE2\x9C\x95%!\n"

(** Terminal ouput for errors; exits the program with code *)
let error msg code =
  (* in case of non terminated print we skip a line *)
  if !error_verbose then red_eprintf "OVM error: ";
  Format.eprintf "%s\n" msg;
  exit code
