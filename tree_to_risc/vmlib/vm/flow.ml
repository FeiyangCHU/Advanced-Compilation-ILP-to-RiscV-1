(** This module provides structure for the VM to handle jumps (to a label), and
    functions to manipulate this structure by adding labels. The jumps are done
    by raising a JumpException with the name of the label to jump. This
    exception is catch at two situations :
    - In the main sequence of a routine. If the label is not found, the
      evaluation is stopped.
    - In an eseq, to avoid stopping the evaluation of an expression. If the
      label is not found in the eseq's map, the exception is propagated.
 *)

open Tree
open Utils

exception FlowError of string

type dest = stmt list list * int
(** Destination of a jump and its imbrication level.
    The destination is in the form of a stack of sequences, to represent the
    imbrications of sequences (seq instruction), the end of a sequence
    representing the end of a seq end.
 *)

type t = {
  eseq : (stmt * dest SMap.t) list;
  routines : dest SMap.t SMap.t;
  top : dest SMap.t;
}
(** Record with the maps for the jumps' label *)

(** empty jump_dest *)
let empty = { eseq = []; routines = SMap.empty; top = SMap.empty }

(** merge_labels
 *  Merge two label maps
 *)
let merge_labels (left : 'a SMap.t) (right : 'a SMap.t) : 'a SMap.t =
  SMap.union
    (fun l _ _ -> raise (FlowError (Format.sprintf "label %s has duplicate" l)))
    left right

(** print_labels
 *  Print the labels and the data associated
 *)
let print_labels (out : Format.formatter) (f : Format.formatter -> 'a -> unit)
    (l : (string * 'a) list) =
  Format.fprintf out "Labels :\n%a\n"
    (Format.pp_print_list
       ~pp_sep:(fun fmt () -> Format.fprintf fmt "\n")
       (fun fmt (lab, x) -> Format.fprintf fmt "%s%a" lab f x))
    l

(** merge
 *  Merge two map
 *)
let merge (left : t) (right : t) : t =
  {
    eseq = List.rev_append left.eseq right.eseq;
    routines =
      SMap.union
        (fun _ left right -> Some (merge_labels left right))
        left.routines right.routines;
    top = merge_labels left.top right.top;
  }

(** get_dest_eseq
 *  Get the destination associated to a label and an eseq's statement
 *)
let get_dest_eseq (labels : t) (s : stmt) (lab : label) : dest =
  let map =
    try List.assq s labels.eseq
    with Not_found ->
      raise (FlowError (Format.asprintf "Unknown statement : %a" print_stmt s))
  in
  SMap.find lab map

(** get_dest_rout
 *  Get the destination associated to a label and in a routine
 *)
let get_dest_rout (labels : t) (routine : label) (lab : label) : dest =
  let map =
    try SMap.find routine labels.routines
    with Not_found ->
      raise (FlowError (Format.sprintf "Unknown routine %s" routine))
  in
  SMap.find lab map

(** get_dest
 *  Get the destination associated to a label and an eseq's statement or at top
 *  level
 *)
let get_dest (labels : t) (s : stmt option) (lab : label) : dest =
  match s with
  | Some s -> get_dest_eseq labels s lab
  | None -> SMap.find lab labels.top

(** add_routine
 *  Add labels to jump in a routine's main sequence
 *)
let add_routine (labels : t) (name : label) (new_labels : dest SMap.t) : t =
  {
    labels with
    routines =
      SMap.update name
        (function
          | None -> Some new_labels
          | Some old_labels -> Some (merge_labels old_labels new_labels))
        labels.routines;
  }

(** print
 *  print the data of a Flow.t
 *)
let print (out : Format.formatter) (jumpLabels : t) =
  let aux fmt (_st, level) =
    Format.fprintf fmt " : %i, stack : %i%a" level (List.length _st)
      (fun fmt l ->
        List.iteri
          (fun i s ->
            Format.fprintf fmt "@\n@[<v 2>%i : @\n%a@]" i
              (Format.pp_print_list print_stmt)
              s)
          l)
      _st
  in
  print_labels out
    (if !jump_debug then aux
     else fun out (_st, level) -> Format.fprintf out " : %i" level)
    (List.fold_left
       (fun acc map -> SMap.fold (fun k x acc -> (k, x) :: acc) map acc)
       []
       (List.map snd jumpLabels.eseq));
  SMap.iter
    (fun k v ->
      Format.fprintf out "%s :@\n%a\n" k
        (Format.pp_print_seq
           ~pp_sep:(fun fmt () -> Format.fprintf fmt "@\n")
           (fun fmt (l, _) -> Format.fprintf fmt "%s" l))
        (SMap.to_seq v))
    jumpLabels.routines
