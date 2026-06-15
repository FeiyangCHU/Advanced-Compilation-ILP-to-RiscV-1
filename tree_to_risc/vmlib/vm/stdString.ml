open Result
open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module Function = Function.Make (A)
  open Exceptions

  (** size_aux * Give the size of a string stored in memory * WARNING : The acc
      must be inititialized at 0 *)
  let rec size_aux (mem : Memory.t) (addr : int) (acc : int) : int =
    let x =
      try Memory.mfetch mem addr with Failure msg -> raise (RuntimeError msg)
    in
    if x = 0 then acc else size_aux mem (addr + Memory.sizeOfInt) (acc + 1)

  (** size * Predefined function size * Give the size of a string stored in
      memory *)
  let size pos mem =
    Function.unary
      (fun mem addr -> (mem, Int (size_aux mem addr 0)))
      "size" pos mem

  (** strconcat * Predefined function concat * Create a string in memory which
      is the concatenation of two other *)
  let strconcat pos mem =
    let memcpy mem dest src size =
      if size > 0 then
        Memory.mstore_seq mem dest (Memory.mfetch_seq mem src size)
      else if size = 0 then mem
      else failwith (Format.sprintf "memcpy : size %d < 0" size)
    in
    Function.binary
      (fun mem addr1 addr2 ->
        try
          let size1 = size_aux mem addr1 0 in
          let size2 = size_aux mem addr2 0 in
          let size = Memory.sizeOfInt * (size1 + size2 + 1) in
          let mem', addr_res = Memory.mreserve mem size in
          let mem' = memcpy mem' addr_res addr1 size1 in
          let mem' = memcpy mem' (addr_res + (4 * size1)) addr2 size2 in
          (Memory.mstore mem' (addr_res + size - 1) 0, Int addr_res)
        with Failure msg -> raise (RuntimeError msg))
      "concat" pos mem

  (** strcmp * Predefined function strcmp * Compare the strings a and b. Return
      -1 if a < b, 0 if equal, and 1 otherwise. *)
  let strcmp pos mem =
    let rec strcmp_aux (mem : Memory.t) (addr1 : int) (addr2 : int) : int =
      try
        let left = Memory.mfetch mem addr1 in
        let right = Memory.mfetch mem addr2 in
        if left < right then -1
        else if right < left then 1
        else if left = 0 then 0
        else strcmp_aux mem (addr1 + Memory.sizeOfInt) (addr2 + Memory.sizeOfInt)
      with Failure msg -> raise (RuntimeError msg)
    in
    Function.binary
      (fun cpu addr1 addr2 -> (cpu, Int (strcmp_aux cpu addr1 addr2)))
      "strcmp" pos mem

  (** equals * Predefined function streq * Return 1 if the strings a and b are
      equal, 0 otherwise. Often faster than strcmp to test string * equality *)
  let equals pos mem =
    let rec equals_aux (mem : Memory.t) (addr1 : int) (addr2 : int) : bool =
      try
        let left = Memory.mfetch mem addr1 in
        let right = Memory.mfetch mem addr2 in
        left = right
        && (left = 0
           || equals_aux mem (addr1 + Memory.sizeOfInt)
                (addr2 + Memory.sizeOfInt))
      with Failure msg -> raise (RuntimeError msg)
    in
    Function.binary
      (fun cpu addr1 addr2 ->
        (cpu, Int (if equals_aux cpu addr1 addr2 then 1 else 0)))
      "equals" pos mem

  (** substring * Predefined function substring * Return a string composed of
      the characters of string starting at the first character (0 being * the
      origin), and composed of length characters (i.e., up to and including the
      character first * + length - 1) * Let size be the size of the string, the
      following assertions must hold: * - 0 <= first * - 0 <= length * - first +
      length <= size *)
  let substring pos mem =
    Function.ternary
      (fun cpu addr first length ->
        if first < 0 then
          raise
            (RuntimeError (Format.sprintf "substring: arguments out of bounds"))
        else if length < 0 then
          raise
            (RuntimeError (Format.sprintf "substring: arguments out of bounds"))
        else
          let size = size_aux cpu addr 0 in
          if first + length > size then
            raise
              (RuntimeError
                 (Format.sprintf "substring: arguments out of bounds"))
          else
            let ncpu, addr' =
              Memory.mreserve cpu ((size + 1) * Memory.sizeOfInt)
            in
            let substr =
              Memory.mfetch_seq ncpu (addr + (Memory.sizeOfInt * first)) length
            in
            let nncpu = Memory.mstore ncpu (addr' + length) 0 in
            (Memory.mstore_seq nncpu addr' substr, Int addr'))
      "substring" pos mem

  (** string_of_int * Predefined function string_of_int * Convert an integer to
      its string representation *)
  let string_of_int pos mem =
    let rec digits_of_int n =
      if n < 10 then [ n ] else digits_of_int (n / 10) @ [ n mod 10 ]
    in
    Function.unary
      (fun cpu n ->
        try
          let is_negative = n < 0 in
          let n = if is_negative then -n else n in
          let digits = digits_of_int n in
          let chars =
            if is_negative then
              Char.code '-' :: List.map (fun d -> d + Char.code '0') digits
            else List.map (fun d -> d + Char.code '0') digits
          in
          let size = List.length chars in
          let cpu', addr =
            Memory.mreserve cpu ((size + 1) * Memory.sizeOfInt)
          in
          let cpu'' = Memory.mstore_seq cpu' addr (chars |> List.to_seq) in
          let cpu''' =
            Memory.mstore cpu'' (addr + (size * Memory.sizeOfInt)) 0
          in
          (cpu''', Int addr)
        with Failure msg -> raise (RuntimeError msg))
      "string_of_int" pos mem

  (** string_of_float * Predefined function string_of_float * Convert a float to
      its string representation *)
  let string_of_float pos mem =
    Function.unaryF
      (fun cpu f ->
        try
          let s = Stdlib.string_of_float f in
          let size = String.length s in
          let chars = List.init size (fun i -> Char.code s.[i]) in
          let cpu', addr =
            Memory.mreserve cpu ((size + 1) * Memory.sizeOfInt)
          in
          let cpu'' = Memory.mstore_seq cpu' addr (chars |> List.to_seq) in
          let cpu''' =
            Memory.mstore cpu'' (addr + (size * Memory.sizeOfInt)) 0
          in
          (cpu''', Int addr)
        with Failure msg -> raise (RuntimeError msg))
      "string_of_float" pos mem
end
