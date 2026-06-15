open Result
open Utils

module Make (A : Integer) = struct
  module Function = Function.Make (A)

  (** std_not * Predefined function not * Return 1 if 0 is given, else return 0
  *)
  let std_not pos mem =
    Function.unary
      (fun mem x -> if x = 0 then (mem, Int 1) else (mem, Int 0))
      "not" pos mem
end
