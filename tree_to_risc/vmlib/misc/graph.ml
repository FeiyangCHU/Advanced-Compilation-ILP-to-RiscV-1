open Utils

(* adjacency table *)
type t = (string, SSet.t) Hashtbl.t

let empty () : t = Hashtbl.create 32
let is_empty g = Hashtbl.length g = 0

let neighbors (g : t) t =
  match Hashtbl.find_opt g t with Some s -> s | None -> SSet.empty

let degree (g : t) t = SSet.cardinal (neighbors g t)
let add_node g t = if not (Hashtbl.mem g t) then Hashtbl.add g t SSet.empty

let add_edge g a b =
  if a <> b then (
    add_node g a;
    add_node g b;
    Hashtbl.replace g a (SSet.add b (Hashtbl.find g a));
    Hashtbl.replace g b (SSet.add a (Hashtbl.find g b)))

let remove_node g t =
  let neighs = neighbors g t in
  SSet.iter
    (fun n ->
      let ns = SSet.remove t (neighbors g n) in
      Hashtbl.replace g n ns)
    neighs;
  Hashtbl.remove g t

let to_dot (g1 : t) (g2 : t) (out : out_channel) =
  output_string out "graph Interference {\n";
  output_string out "  node [shape=circle fontname=\"monospace\"];\n";
  let print_node t neighs =
    if SSet.is_empty neighs then Printf.fprintf out "  \"%s\";\n" t
    else
      SSet.iter
        (fun u -> if t < u then Printf.fprintf out "  \"%s\" -- \"%s\";\n" t u)
        neighs
  in
  Hashtbl.iter print_node g1;
  Hashtbl.iter print_node g2;
  output_string out "}\n"
