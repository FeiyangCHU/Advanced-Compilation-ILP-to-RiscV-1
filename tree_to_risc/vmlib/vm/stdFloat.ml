open Result
open Utils

module Make (A : Integer) = struct
  module Function = Function.Make (A)

  (** std_not * Predefined function not * Return 1 if 0 is given, else return 0
  *)
  let float_of_int pos mem =
    Function.unary
      (fun mem x -> (mem, Float (float_of_int x)))
      "float_of_int" pos mem
end
