open Utils

type ('a, 'b) t = Nothing | Int of 'a | Float of 'b

let print pp_int pp_float fmt = function
  | Nothing -> Format.fprintf fmt "void"
  | Int i -> Format.fprintf fmt "%a" pp_int i
  | Float f -> Format.fprintf fmt "%a" pp_float f

let map map_int map_float = function
  | Nothing -> Nothing
  | Int i -> Int (map_int i)
  | Float f -> Float (map_float f)

let print_typ fmt x =
  print
    (fun fmt _ -> Format.fprintf fmt "int")
    (fun fmt _ -> Format.fprintf fmt "float")
    fmt x

let to_int (x : ('a, 'b) t) : 'a =
  match x with
  | Int res -> res
  | x -> failwith (Format.asprintf "excpected integer but got %a" print_typ x)

let to_float (x : ('a, 'b) t) : 'b =
  match x with
  | Float res -> res
  | x -> failwith (Format.asprintf "excpected float but got %a" print_typ x)
