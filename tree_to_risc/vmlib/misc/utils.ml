let test = ref false
let show_ast = ref false
let show_temps = ref false
let trace = ref false
let error_verbose = ref false

(* TODO : argv *)
let show_version = ref false
let jump_debug = ref false
let linearize = ref false
let eval = ref true
let basic_blocks = ref false
let lir_check = ref false
let ssa_check = ref false
let unsafe = ref false
let heapsize = ref 81920
let stacksize = ref 81920
let file = ref ""
let word_size = ref 32
let riscv = ref false

module SSet = struct
  include Set.Make (String)

  let print fmt s =
    to_seq s |> List.of_seq
    |> (Format.pp_print_list ~pp_sep:Format.pp_print_space
          Format.pp_print_string)
         fmt
end

module SMap = struct
  include Map.Make (String)

  (* TODO: remove me when bumping to > 5.1 *)
  let of_list l = List.fold_left (fun acc (k, e) -> add k e acc) empty l

  let print pp_binding fmt s =
    bindings s
    |> (Format.pp_print_list ~pp_sep:Format.pp_print_space pp_binding) fmt
end

(* keep backward compat with 4.14 *)
(* TODO: remove me when bumping to > 5.1 *)
module Format = struct
  include Format

  let pp_print_array ~pp_sep pp_elem fmt arr =
    pp_print_list ~pp_sep pp_elem fmt (Array.to_list arr)
end

let print_version () =
  Format.printf
    "This tool is written by Damien Assire, Mael Cravero and Ghiles Ziat.\n\n\
     Copyright (C) 2024-2025 EPITA Research Laboratory (LRE).\n\
     It comes with ABSOLUTELY NO WARRANTY.\n\
     This is free software, and you are welcome to redistribute and modify it\n\
     under certain conditions; see source for details.\n"

let print_smap ?pp_sep pp_elem fmt smap =
  let print_pair fmt (s, v) = Format.fprintf fmt "%s:%a" s pp_elem v in
  Format.fprintf fmt "%a"
    (Format.pp_print_list ?pp_sep print_pair)
    (SMap.bindings smap)

let print_sset fmt ~pp_sep sset =
  Format.fprintf fmt "%a"
    (Format.pp_print_list ~pp_sep Format.pp_print_string)
    (List.of_seq (SSet.to_seq sset))

let pp_opt pp fmt = function
  | None -> () (* print nothing *)
  | Some x -> pp fmt x

(** div_ceiling * Return the smallest integer greater than or equal to n/d *)
let div_ceiling (n : int) (d : int) : int = ((n - 1) / d) + 1

module type Integer = sig
  type t

  (* comparisons *)
  val compare : t -> t -> int
  val unsigned_compare : t -> t -> int

  (* arithmetics *)
  val add : t -> t -> t
  val sub : t -> t -> t
  val mul : t -> t -> t
  val div : t -> t -> t
  val rem : t -> t -> t

  (* logic *)
  val logand : t -> t -> t
  val logor : t -> t -> t
  val logxor : t -> t -> t
  val shift_left : t -> int -> t
  val shift_right_logical : t -> int -> t
  val shift_right : t -> int -> t

  (* conversion *)
  val of_int : int -> t
  val to_int : t -> int

  (* printing and to string *)
  val to_string : t -> string
  val of_string : string -> t

  (* utility to store floats with integer representation *)
  val bits_of_float : float -> t
  val float_of_bits : t -> float
end

type file_range = Lexing.position * Lexing.position
