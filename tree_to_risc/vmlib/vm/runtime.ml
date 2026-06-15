open Tree
open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module StdChar = StdChar.Make (A)
  module StdString = StdString.Make (A)
  module StdSystem = StdSystem.Make (A)
  module StdPrint = StdPrint.Make (A)
  module StdInt = StdInt.Make (A)
  module StdFloat = StdFloat.Make (A)

  type ('a, 'b) annot_arg = expr * ('a, 'b) Result.t

  type ('a, 'b) runtime_function =
    file_range ->
    Memory.t ->
    ('a, 'b) annot_arg list ->
    Memory.t * ('a, 'b) Result.t

  (** stdFun * Predefined functions' map *)
  let stdFun : (int, float) runtime_function SMap.t =
    SMap.of_list
      [
        ("chr", StdChar.chr);
        ("concat", StdString.strconcat);
        ("exit", StdSystem.exit);
        ("flush", StdSystem.flush);
        ("float_of_int", StdFloat.float_of_int);
        ("getchar", StdSystem.getchar);
        ("init_array", StdSystem.init_array);
        ("malloc", StdSystem.malloc);
        ("not", StdInt.std_not);
        ("ord", StdChar.ord);
        ("print", StdPrint.print);
        ("print_err", StdPrint.print_err);
        ("print_int", StdPrint.print_int);
        ("size", StdString.size);
        ("strcmp", StdString.strcmp);
        ("string_of_int", StdString.string_of_int);
        ("string_of_float", StdString.string_of_float);
        ("streq", StdString.equals);
        ("stringEqual", StdString.equals);
        ("substring", StdString.substring);
      ]

  (** of_label * Give the function corresponding to a label *)
  let of_label (name : label) =
    try SMap.find name stdFun
    with Not_found ->
      failwith
        (Format.sprintf "%s not in standard library or not implemented yet" name)

  (** of_label * Give the function corresponding to a label *)
  let of_label_opt (name : label) = SMap.find_opt name stdFun

  (** in_stdlib * Check if a label correspond to a function in predefined
      functions *)
  let in_stdlib (name : label) : bool = SMap.exists (fun x _ -> x = name) stdFun
end
