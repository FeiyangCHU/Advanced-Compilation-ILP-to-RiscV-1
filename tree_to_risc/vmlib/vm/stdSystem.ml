open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module Function = Function.Make (A)

  exception ExitException of (int * Memory.t)

  (** exit * Predefined function exit * Exit the program with exit code given *)
  let exit pos mem =
    Function.unary (fun _ x -> raise (ExitException (x, mem))) "exit" pos mem

  (** flush * Predefined function flush * Flush the output buffer *)
  let flush pos mem =
    Function.zeroary
      (fun mem ->
        Format.fprintf !Vmio.out "%!";
        (mem, Result.Nothing))
      "flush" pos mem

  (** getchar * Predefined function getchar * Read a character on input. Return
      an empty string on an end of file *)
  let getchar pos mem =
    Function.zeroary
      (fun mem ->
        match In_channel.input_char !Vmio.input with
        | Some c ->
            let mem', addr = Memory.mreserve mem 8 in
            let mem'' = Char.code c |> Memory.mstore mem' addr in
            (Memory.mstore mem'' (addr + 4) 0, Result.Int addr)
        | None ->
            let mem', addr = Memory.mreserve mem 4 in
            (Memory.mstore mem' addr 0, Int addr))
      "getchar" pos mem

  (** init_array * Predefined function init_array * Initialize an array of a
      given size with a given value and return its address *)
  let init_array pos mem =
    Function.binary
      (fun mem size value ->
        let mem', addr = Memory.mreserve mem (4 * size) in
        ( Memory.mstore_seq mem' addr (Seq.init size (fun _ -> value)),
          Result.Int addr ))
      "init_array" pos mem

  (** malloc * Predefined function malloc * Reserve a segment of memory of a
      given size in bytes and return its address *)
  let malloc pos mem =
    Function.unary
      (fun cpu size ->
        let cpu', addr = Memory.mreserve cpu size in
        (cpu', Result.Int addr))
      "malloc" pos mem
end
