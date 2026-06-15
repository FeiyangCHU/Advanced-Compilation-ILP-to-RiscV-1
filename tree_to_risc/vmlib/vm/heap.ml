open Utils

type t = { hp : int; heap : int array }
(** Type of heaps *)

(** Returns a fresh heap that can store size elements without reallocations *)
let init size = { hp = 0; heap = Array.init size (fun _ -> 0) }

(** reserves some memory for future use: returns the updated heap pointer and
    the start address of the reserved block *)
let reserve (h : t) (size : int) : t * int =
  let p = h.hp in
  let sum = p + size in
  if sum >= Array.length h.heap then
    failwith
      (Format.asprintf
         "Heap.reserve: heap out of memory error: requested %i, remaining %i"
         size
         (Array.length h.heap - p))
  else ({ h with hp = h.hp + size }, p)

(** returns the element at the address 'addr'

    Raises Invalid_argument if 'addr' is outside the range 0 to (length h.heap -
    1).*)
let read h addr =
  let addr' = addr / 4 in
  if addr' < 0 || addr' >= Array.length h.heap then
    invalid_arg
      (Format.asprintf "Heap.read: address %i out of heap range " addr);
  h.heap.(addr')

(** modifies the element at the address 'addr'

    Raises Invalid_argument if 'addr' is outside the range 0 to (length h.heap -
    1).*)
let write h addr value =
  let addr' = addr / 4 in
  if addr' < 0 || addr' >= Array.length h.heap then
    invalid_arg
      (Format.asprintf "Heap.write: address %i out of heap range " addr);
  h.heap.(addr') <- value

(** print * Print the datas of the heap *)
let print (fmt : Format.formatter) (heap : t) =
  Format.fprintf fmt "Heap size : %i@\nhp : %i@\n[%a]@,"
    (Array.length heap.heap) heap.hp
    (Format.pp_print_array
       ~pp_sep:(fun fmt () -> Format.fprintf fmt ";@,")
       (fun fmt x -> Format.fprintf fmt "%d" x))
    heap.heap
