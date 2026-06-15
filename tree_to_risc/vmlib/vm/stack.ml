open Utils

type t = { stacksize : int; memory : int array }

(** initialize * Create a stack * The stack pointer is considered to be in the
    temporaries *)
let initialize (stacksize : int) : t =
  { stacksize; memory = Array.init stacksize (fun _ -> 0) }

(** fetch * Read the memory at a given adress * 0 is the end of the stack *)
let fetch (st : t) (i : int) : int = st.memory.(i / 4)

(** store * Write a value in the memory at a given address *)
let store (st : t) (i : int) (value : int) = st.memory.(i / 4) <- value

(** print * Print the stack *)
let print (fmt : Format.formatter) (st : t) =
  Format.fprintf fmt "size : %i\n%a" st.stacksize
    (Format.pp_print_array
       ~pp_sep:(fun fmt () -> Format.fprintf fmt ";@,")
       (fun fmt x -> Format.fprintf fmt "%d" x))
    st.memory
