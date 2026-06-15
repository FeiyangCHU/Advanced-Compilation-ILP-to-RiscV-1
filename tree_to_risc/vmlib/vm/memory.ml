open Tree
open Utils

module Make (A : Integer) = struct
  module Cpu = Cpu.Make (A)

  type t = {
    temporaries : Cpu.t;
    heap : Heap.t;
    heapsize : int;
    stack : Stack.t;
    stacksize : int;
    jumpLabels : Flow.t;
    littLabel : int SMap.t;
    routines : stmt list SMap.t;
  }

  let sizeOfInt = 4 (* Size of int32 (in bytes) *)

  (** create * Create the VM's memory state *)
  let create ~(heapsize : int) ~(stacksize : int) () : t =
    {
      temporaries = Cpu.initialize ~heapsize ~stacksize ();
      heap = Heap.init (div_ceiling heapsize sizeOfInt);
      heapsize;
      stack = Stack.initialize (div_ceiling stacksize sizeOfInt);
      stacksize;
      jumpLabels = Flow.empty;
      littLabel = SMap.empty;
      routines = SMap.empty;
    }

  (* Temporaries *)

  (** rfetch * Fetch the content of a temporary of the VM's memory * Raise
      Not_found exception if there is no label with that name *)
  let rfetch (mem : t) (temp : label) : A.t =
    (* Can the temporaries (and other parts) contain labels ? *)
    Cpu.rfetch mem.temporaries temp

  (** rfetch * Fetch the content of a temporary of the VM's memory * Raise
      Not_found exception if there is no label with that name *)
  let rfetchF (mem : t) (temp : label) : float =
    (* Can the temporaries (and other parts) contain labels ? *)
    Cpu.rfetchF mem.temporaries temp

  (** rfetch * Fetch the content of a temporary of the VM's memory * Raise
      Not_found exception if there is no label with that name *)
  let fetch (mem : t) (temp : label) =
    (* Can the temporaries (and other parts) contain labels ? *)
    Cpu.fetch mem.temporaries temp

  (** rstore * Store the value in a temporary * If there is a temporary with
      that name, change it's value * If not, create a new one with that value *)
  let rstore (mem : t) (temp : label) (x : A.t) : t =
    { mem with temporaries = Cpu.rstore mem.temporaries temp x }

  (** rstore * Store the value in a temporary * If there is a temporary with
      that name, change it's value * If not, create a new one with that value *)
  let rstoreF (mem : t) (temp : label) (x : float) : t =
    { mem with temporaries = Cpu.rstoreF mem.temporaries temp x }

  (* Memory *)

  (* Possible improvements : fetch/store bytes *)

  (** mreserve * Reserve a block of a given size in the heap * WARNING : The
      size is given in byte where one cell is 4 bytes *)
  let mreserve (mem : t) (size : int) : t * int =
    let nheap, index = Heap.reserve mem.heap (div_ceiling size sizeOfInt) in
    ({ mem with heap = nheap }, index * sizeOfInt)

  (** mfetch * Read the memory at the given address * Dispatch between the heap
      and the stack *)
  let mfetch (mem : t) (addr : int) : int =
    if addr >= 0 && addr < mem.heapsize then Heap.read mem.heap addr
    else if addr < mem.heapsize + mem.stacksize then
      Stack.fetch mem.stack (addr - mem.heapsize)
    else failwith (Format.asprintf "Address %i out of memory range " addr)

  (** mfetch * Read the memory at the given address * Dispatch between the heap
      and the stack *)
  let mfetchF (mem : t) (addr : int) : float =
    if addr >= 0 && addr < mem.heapsize then
      Heap.read mem.heap addr |> A.of_int |> A.float_of_bits
    else if addr < mem.heapsize + mem.stacksize then
      Stack.fetch mem.stack (addr - mem.heapsize) |> A.of_int |> A.float_of_bits
    else failwith (Format.asprintf "Address %i out of memory range " addr)

  (** mfetch_seq * Read a block of values, starting at the given address, in the
      form of a seq *)
  let mfetch_seq (mem : t) (addr : int) (size : int) : int Seq.t =
    if size < 0 then
      failwith
        (Format.sprintf "mfetchn : the size : %i cannot be negative" size)
    else if addr < 0 || addr + (4 * size) > mem.heapsize + mem.stacksize then
      failwith
        (Format.sprintf "Can't fetch values of size %i at address %i" (4 * size)
           addr)
    else Seq.init size (fun i -> mfetch mem (addr + (i * sizeOfInt)))

  (** mstore * Write a value in the memory at the given address * Dispatch
      between the heap and the stack *)
  let mstore (mem : t) (addr : int) (value : int) : t =
    if addr >= 0 && addr < mem.heapsize then Heap.write mem.heap addr value
    else if addr < mem.heapsize + mem.stacksize then
      Stack.store mem.stack (addr - mem.heapsize) value
    else failwith (Format.asprintf "Address %i out of memory range " addr);
    mem

  (** mstore * Write a value in the memory at the given address * Dispatch
      between the heap and the stack *)
  let mstoreF (mem : t) (addr : int) (value : float) : t =
    let value_as_int = A.bits_of_float value |> A.to_int in
    if addr >= 0 && addr < mem.heapsize then
      Heap.write mem.heap addr value_as_int
    else if addr < mem.heapsize + mem.stacksize then
      Stack.store mem.stack (addr - mem.heapsize) value_as_int
    else failwith (Format.asprintf "Address %i out of memory range " addr);
    mem

  (** mstore_seq * Store a sequence of values, starting at the given address *)
  let mstore_seq (mem : t) (addr : int) (values : int Seq.t) =
    let size = sizeOfInt * Seq.length values in
    if addr < 0 || addr + size > mem.heapsize + mem.stacksize then
      failwith
        (Format.sprintf "Can't store values of size %i at address %i" size addr);
    Seq.iteri (fun i x -> ignore (mstore mem (addr + (i * sizeOfInt)) x)) values;
    mem

  (* JumpLabels *)

  (** get_dest * Get the destination associated to a label and an eseq's
      statement *)
  let jump_dest (mem : t) (s : stmt option) (lab : label) : stmt list list * int
      =
    Flow.get_dest mem.jumpLabels s lab

  (* Routines *)

  (** cfetch * Get the code associated to a routine *)
  let cfetch (mem : t) (name : label) : stmt list =
    try SMap.find name mem.routines
    with Not_found ->
      failwith
        (Format.sprintf "No known label with the name \"%s\" in memory" name)

  (* Litterals *)

  (** lfetch * Give the address corresponding to a label *)
  let lfetch (mem : t) (lab : label) : int = SMap.find lab mem.littLabel

  (** add_str * Add a Litteral to the memory *)
  let add_str (mem : t) (str : string) : t * int =
    let size = String.length str in
    let nmem, addr = mreserve mem ((size + 1) * sizeOfInt) in
    let nnmem = mstore nmem (addr + (sizeOfInt * size)) 0 in
    (mstore_seq nnmem addr (str |> String.to_seq |> Seq.map Char.code), addr)

  (** fetch_str_seq * Fetch a string starting at a given address and return its
      int sequence *)
  let fetch_str_seq (mem : t) (addr : int) : int Seq.t =
    try
      Seq.unfold
        (fun addr ->
          let c = mfetch mem addr in
          if c = 0 then None else Some (c, addr + 4))
        addr
    with Failure msg ->
      failwith
        (Format.sprintf "Impossible to get the string starting at %i : %s" addr
           msg)

  (** fetch_str_rev_seq * Fetch a string starting at a given address and return
      it in the form of an reversed list *)
  let fetch_str_rev_seq (mem : t) (addr : int) : char Seq.t =
    try
      fetch_str_seq mem addr
      |> Seq.fold_left (fun acc x -> Seq.cons (Char.chr x) acc) Seq.empty
    with Invalid_argument m -> failwith m (* For Char.chr *)

  (** fetch_str * Fetch a string starting at a given address *)
  let fetch_str (mem : t) (addr : int) : string =
    try fetch_str_seq mem addr |> Seq.map Char.chr |> String.of_seq
    with Invalid_argument m -> failwith m (* For Char.chr *)

  (** initialize * Initialize the memory state of the VM and all it's parts *)
  let initialize ~(heapsize : int) ~(stacksize : int) (prog : stmt list) : t =
    let mem = create ~heapsize ~stacksize () in
    let res =
      Preload.build prog
      (* TODO : Change the function called so it check if there is dupplicate label *)
    in
    let nmem, litt_list =
      SMap.fold
        (fun lab str (mem, map) ->
          let nmem, addr = add_str mem str in
          (nmem, SMap.add lab addr map))
        res.litterals (mem, SMap.empty)
    in
    {
      nmem with
      jumpLabels = res.jump_dest;
      littLabel = litt_list;
      routines = res.routines;
    }

  (* Prints *)

  (** print_temp * Print the temporaries of the VM and their content *)
  let print_temp fmt (mem : t) = Cpu.print_temp fmt mem.temporaries

  (** print_heap *)
  let print_heap (fmt : Format.formatter) (mem : t) = Heap.print fmt mem.heap

  (** print_stack * Print the VM's stack *)
  let print_stack fmt (mem : t) = Stack.print fmt mem.stack

  (** print_code_labels * Print the labels in the code (for jumps) seen during
      the preload *)
  let print_code_labels fmt (mem : t) = Flow.print fmt mem.jumpLabels

  (** print * Print all the different parts of the VM's memory state *)
  let print fmt (mem : t) =
    Format.fprintf fmt "%a\n%a" print_code_labels mem print_temp mem

  let memory_check (temp : string) (value : int) mem : bool =
    try
      let actual = rfetch mem temp |> A.to_int in
      if value <> actual then (
        Format.printf
          "memory mismatch: got \"%s : %i\" but was expecting \"%s : %i\"%!"
          temp actual temp value;
        false)
      else true
    with _ ->
      Format.printf
        "memory mismatch: got \"%s : none\" but was expecting \"%s : %i\"%!"
        temp temp value;
      false

  let full_check mem cells =
    List.for_all (fun (s, i) -> memory_check s i mem) cells
end
