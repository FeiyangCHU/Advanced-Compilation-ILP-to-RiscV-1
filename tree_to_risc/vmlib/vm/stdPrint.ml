open Result
open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module Function = Function.Make (A)
  open Exceptions

  let print_int pos mem =
    Function.unary
      (fun mem x ->
        Vmio.printf "%d%!" x;
        (mem, Nothing))
      "print_int" pos mem

  let print pos mem =
    Function.unary
      (fun mem x ->
        let str =
          try Memory.fetch_str mem x
          with Failure msg ->
            raise (RuntimeError (Format.sprintf "print : %s" msg))
        in
        Vmio.printf "%s%!" str;
        (mem, Nothing))
      "print" pos mem

  let print_err pos mem =
    Function.unary
      (fun mem x ->
        let str =
          try Memory.fetch_str mem x
          with Failure msg ->
            raise (RuntimeError (Format.sprintf "print_err : %s" msg))
        in
        Vmio.eprintf "%s%!" str;
        (mem, Nothing))
      "print_err" pos mem
end
