open Result
open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module Function = Function.Make (A)
  open Exceptions

  (** chr * Predefined function chr * Return the one character long string
      containing the character which code is code * If code does not belong to
      the range [0..255], raise a runtime `error: chr: character out of range`
  *)
  let chr pos mem =
    Function.unary
      (fun cpu x ->
        if 0 <= x && x < 256 then
          let ncpu, addr = Memory.mreserve cpu 2 in
          (Memory.mstore_seq ncpu addr (List.to_seq [ x; 0 ]), Int addr)
        else raise (RuntimeError (Format.sprintf "chr: character out of range")))
      "chr" pos mem

  (** ord * Predefined function ord * Return the ascii code of the first
      character in string and -1 if the given string is empty *)
  let ord pos mem =
    Function.unary
      (fun mem addr ->
        try (mem, Int (Memory.mfetch mem addr))
        with Failure msg -> raise (RuntimeError msg))
      "ord" pos mem
end
