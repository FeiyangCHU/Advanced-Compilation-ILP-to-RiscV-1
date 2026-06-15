let input = ref In_channel.stdin
let out = ref Format.std_formatter
let err = ref Format.err_formatter
let trace : Format.formatter option ref = ref None

let init ~(out_channel : Format.formatter) ~(err_channel : Format.formatter)
    ?trace:(tc : Format.formatter option) (ic : In_channel.t) =
  input := ic;
  out := out_channel;
  err := err_channel;
  trace := tc

let printf (fmt : ('a, Format.formatter, unit) format) : 'a =
  Format.fprintf !out fmt

let eprintf (fmt : ('a, Format.formatter, unit) format) : 'a =
  Format.fprintf !err fmt

(** Contain all the formatter where we need to print a \n *)
let lazy_endline : Format.formatter list ref = ref []

(** remove_lazy_endline
 *  Check if there is a \n to print in the formatter, remove it to the list and
 *  return if it was in the list or not
 *)
let remove_lazy_endline (x : Format.formatter) : bool =
  let rec aux (l : 'a list) (acc : 'a list) =
    match l with
    | h :: t -> if h == x then Some (List.rev_append acc t) else aux t (h :: acc)
    | [] -> None
  in
  Option.map
    (fun l ->
      lazy_endline := l;
      true)
    (aux !lazy_endline [])
  |> Option.is_some

(** print_lazy_endline
 *  Check if there is a \n to print in the formatter and print it if needed
 *)
let print_lazy_endline (x : Format.formatter) : unit =
  if remove_lazy_endline x then Format.fprintf x "@\n"

(** add_lazy_endline
 *  Add a formatter to the list of formatter which need an \n
 *)
let add_lazy_endline (fmt : Format.formatter) : unit =
  if not (List.memq fmt !lazy_endline) then lazy_endline := fmt :: !lazy_endline

(** print_trace
 *  print in trace output if some is given
 *)
let print_trace (msg : string) =
  (* Check if it finish with an empty line and remove it if so *)
  let rec aux (l : string list) (acc : string list) : string list option =
    match l with
    | [] -> None
    | [ _ ] -> None (* Avoid having a \n for the empty string *)
    | [ h; x ] -> if x = "" then Some (List.rev (h :: acc)) else None
    | h :: t -> aux t (h :: acc)
  in
  Option.iter
    (fun fmt ->
      print_lazy_endline fmt;
      let l = String.split_on_char '\n' msg in
      let l =
        match aux l [] with
        | Some l' ->
            add_lazy_endline fmt;
            l'
        | None -> l
      in
      Format.pp_print_list
        ~pp_sep:(fun fmt () -> Format.fprintf fmt "@\n")
        (fun fmt msg -> Format.fprintf fmt "@<0>%s" msg)
        fmt l)
    !trace

(** change_offset
 *  Change the offset value by a given value
 *)
let change_offset (update : int) =
  Option.iter
    (fun fmt ->
      if update > 0 then Format.pp_open_box fmt update
      else if update < 0 then Format.pp_close_box fmt ())
    !trace

let set_offset ~number:(n : int) ~(size : int) =
  Option.iter
    (fun fmt ->
      Format.pp_print_flush fmt ();
      for _ = 1 to n do
        change_offset size;
        for _ = 1 to size do
          Format.fprintf fmt " " (* Doesn't indent without *)
        done
      done)
    !trace

(** print_with_offset
 *  Print in trace output if some is given
 *  Change the offset value by a given value
 *  - Decrease it before if the value is negative
 *  - Increase it after if the value is positive
 *  - Do nothing if the value is 0
 *)
let trace_with_offset (modif : int) (msg : string) =
  if modif < 0 then change_offset modif;
  print_trace msg;
  if modif > 0 then change_offset modif

(** Print in trace output and Change the offset value by 2 *)
let trace_indent = trace_with_offset 2

(** Print in trace output and Change the offset value by -2 *)
let trace_dedent = trace_with_offset (-2)
