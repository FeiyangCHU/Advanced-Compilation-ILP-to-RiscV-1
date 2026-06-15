open Tree
open Utils

module Make (A : Integer) = struct
  module Memory = Memory.Make (A)
  module Runtime = Runtime.Make (A)
  open Exceptions

  exception JumpException of (label * location * Memory.t)

  let result_print_int = Result.print Format.pp_print_int Format.pp_print_float

  let result_print =
    Result.print
      (fun fmt x -> Format.fprintf fmt "%s" (A.to_string x))
      Format.pp_print_float

  (** [jump_to cpu label] Jump to the label [label], using data in [cpu]. *)
  let jump_to (cpu : Memory.t) (from : location) (dest : label) =
    Vmio.trace_with_offset 0 (Format.sprintf "Jump to label %s\n" dest);
    raise (JumpException (dest, from, cpu))

  (** [evalMove cpu m e] Evaluate a move expression. Store the result of the
      evaluation of [e] in [m] :
      - If [m] is [TEMP t], store the result in the temporary [t].
      - If [m] is [MEM(x)], store the result in memory, at the address [x].
      - Otherwise, it raise a [VM_runtime_exception]. *)
  let rec evalMove (cpu : Memory.t) (m : expr) (e : expr) : Memory.t =
    Vmio.trace_indent "eval move\n";
    let ncpu, store, pp =
      match m.payload with
      | Temp t ->
          ( cpu,
            (fun cpu x ->
              match x with
              | Result.Int x -> Memory.rstore cpu t x
              | Result.Float x -> Memory.rstoreF cpu t x
              | r ->
                  runtime_error
                    (Format.asprintf "%s <- %a : %a, not an integer nor a float"
                       t result_print r result_print r)
                    e.loc),
            Format.asprintf "%a" print_expr m )
      | Mem e1 -> (
          let ncpu, r = eval_expr cpu e1 in
          try
            let addr = Result.to_int r in
            ( ncpu,
              (fun cpu x ->
                match x with
                | Int x -> Memory.mstore cpu (addr |> A.to_int) (x |> A.to_int)
                | Float x -> Memory.mstoreF cpu (addr |> A.to_int) x
                | r ->
                    runtime_error
                      (Format.asprintf
                         "Mem(%s) : %a, not an integer nor a float"
                         (A.to_string addr) result_print r)
                      e.loc),
              Format.sprintf "mem %s" (A.to_string addr) )
          with Failure msg -> runtime_error msg m.loc)
      | _ -> runtime_error "Left-value of move should be mem or temp" m.loc
    in
    let nncpu, x = eval_expr ncpu e in
    Vmio.trace_dedent (Format.asprintf "move : %s <- %a\n" pp result_print x);
    store nncpu x

  (** [evalCjump cpu (op, e1, e2, t, f)] Evaluate the expressions [e1] and [e2]
      and compare their resluts, using [op] :
      - If the result is true, jump to the label [t].
      - If the result is false, jump to the label [f].
      - If one of those result is not an integer, raise a [RuntimeError]. *)
  and evalCjump (cpu : Memory.t) (from : location)
      ((op, lexpr, rexpr, t, f) : relop * expr * expr * label * label) :
      Memory.t =
    Vmio.trace_indent "evalCjump\n";
    let ncpu, l = eval_expr cpu lexpr in
    let nncpu, r = eval_expr ncpu rexpr in
    Vmio.trace_dedent
      (Format.asprintf "%s %a %a\n" (relop_to_string op) result_print l
         result_print r);

    let cond =
      match (op, l, r) with
      (* -------- integer relational ops -------- *)
      | Eq, Int left, Int right -> A.compare left right = 0
      | Neq, Int left, Int right -> A.compare left right <> 0
      | LT, Int left, Int right -> A.compare left right < 0
      | GT, Int left, Int right -> A.compare left right > 0
      | LE, Int left, Int right -> A.compare left right <= 0
      | GE, Int left, Int right -> A.compare left right >= 0
      | ULT, Int left, Int right -> A.unsigned_compare left right < 0
      | UGT, Int left, Int right -> A.unsigned_compare left right > 0
      | ULE, Int left, Int right -> A.unsigned_compare left right <= 0
      | UGE, Int left, Int right -> A.unsigned_compare left right >= 0
      (* -------- float relational ops -------- *)
      | EqF, Float left, Float right -> Float.compare left right = 0
      | NeqF, Float left, Float right -> Float.compare left right <> 0
      | LTF, Float left, Float right -> Float.compare left right < 0
      | GTF, Float left, Float right -> Float.compare left right > 0
      | LEF, Float left, Float right -> Float.compare left right <= 0
      | GEF, Float left, Float right -> Float.compare left right >= 0
      (* -------- type errors -------- *)
      | _, left, right ->
          runtime_error
            (Format.asprintf "Invalid operands for %s: %a %a"
               (relop_to_string op) result_print left result_print right)
            lexpr.loc
    in
    jump_to nncpu from (if cond then t else f)

  (** [evalName loc cpu name] Evaluate a label [name] and return its
      corresponding address using [cpu]. *)
  and evalName ~loc (cpu : Memory.t) (name : label) :
      Memory.t * (A.t, 'b) Result.t =
    Vmio.trace_with_offset 0 (Format.sprintf "name %s" name);
    let r =
      try Memory.lfetch cpu name
      with Not_found ->
        Vmio.print_trace "\n";
        runtime_error (Format.asprintf "label \"%s\" unknown" name) loc
    in
    let ra = A.of_int r in
    Vmio.print_trace (Format.sprintf " -> %s\n" (A.to_string ra));
    (cpu, Int ra)

  and evalBinop (cpu : Memory.t) (op : op) (lexpr : expr) (rexpr : expr) :
      Memory.t * (A.t, 'b) Result.t =
    Vmio.trace_indent (Format.sprintf "eval op %s\n" (binop_to_string op));
    let ncpu, left = eval_expr cpu lexpr in
    let nncpu, right = eval_expr ncpu rexpr in
    Vmio.trace_dedent
      (Format.asprintf "%s %a %a\n" (binop_to_string op) result_print left
         result_print right);

    let result =
      match (op, left, right) with
      (* -------- integer ops -------- *)
      | Add, Int l, Int r -> Result.Int (A.add l r)
      | Sub, Int l, Int r -> Int (A.sub l r)
      | Mul, Int l, Int r -> Int (A.mul l r)
      | Div, Int l, Int r -> Int (A.div l r)
      | Mod, Int l, Int r -> Int (A.rem l r)
      | And, Int l, Int r -> Int (A.logand l r)
      | Or, Int l, Int r -> Int (A.logor l r)
      | Xor, Int l, Int r -> Int (A.logxor l r)
      | LShift, Int l, Int r -> Int (A.shift_left l (A.to_int r))
      | RShift, Int l, Int r -> Int (A.shift_right_logical l (A.to_int r))
      | ARshift, Int l, Int r -> Int (A.shift_right l (A.to_int r))
      (* -------- float ops -------- *)
      | AddF, Float l, Float r -> Float (l +. r)
      | SubF, Float l, Float r -> Float (l -. r)
      | MulF, Float l, Float r -> Float (l *. r)
      | DivF, Float l, Float r -> Float (l /. r)
      (* -------- type errors -------- *)
      | _, _, _ ->
          runtime_error
            (Format.asprintf "Invalid operands for %s: %a %a"
               (binop_to_string op) result_print left result_print right)
            lexpr.loc
    in
    (nncpu, result)

  (** [evalMem cpu e] Evaluate a [MEM] expression by evaluating [e] and
      returning the value at this address. *)
  and evalMem (cpu : Memory.t) (e : expr) : Memory.t * (A.t, 'b) Result.t =
    Vmio.trace_indent "eval mem\n";
    let ncpu, m = eval_expr cpu e in
    let r =
      try Memory.mfetch cpu (Result.to_int m |> A.to_int)
      with Failure msg -> raise (RuntimeError msg)
    in
    Vmio.trace_dedent
      (Format.sprintf "mem %i = %i\n" (Result.to_int m |> A.to_int) r);
    (ncpu, Int (A.of_int r))

  (** [evalCall cpu name args] Evaluate the call of a predefined function or
      user routine [name] with the memory state [cpu] and the arguments [args].
  *)
  and evalCall loc (cpu : Memory.t) (f : label) (args : args) typ :
      Memory.t * (A.t, 'b) Result.t =
    Vmio.trace_indent (Format.sprintf "evalCall %s\n" f);
    let cpu, evalargs =
      List.fold_left_map
        (fun cpu (typ, e) ->
          let cpu', res = eval_expr cpu e in
          (cpu', (typ, res)))
        cpu args
    in
    let evalargs_int =
      List.map (fun (t, r) -> (t, Result.map A.to_int Fun.id r)) evalargs
    in
    Vmio.change_offset (-2);
    Vmio.trace_indent
      (Format.asprintf "call %s %a\n" f
         (Format.pp_print_list ~pp_sep:Format.pp_print_space result_print)
         (List.map snd evalargs));
    let ncpu, res =
      try eval_routine f cpu evalargs typ
      with Failure _ -> (
        try
          let mem, res =
            (Runtime.of_label f) loc cpu
              (List.combine (List.map snd args) (List.map snd evalargs_int))
          in
          (mem, Result.map A.of_int Fun.id res)
        with Failure m -> raise (RuntimeError m))
    in
    Vmio.trace_dedent
      (Format.asprintf "%s %a -> %a\n" f
         (Format.pp_print_list ~pp_sep:Format.pp_print_space result_print)
         (List.map snd evalargs) result_print res);
    (ncpu, res)

  (** [eval_routine name cpu args] Evaluate the routine [name] with the memory
      state [cpu] and the arguments [args].

      The call of [eval_routine name cpu] raise a failure if [name] is not
      associated to a function in [cpu], without the need of [args], allowing to
      do :
      {[
        let f =
          try eval_routine name cpu
          with _ -> ...
        in f args
      ]} *)
  and eval_routine (name : label) (cpu : Memory.t) :
      (Tree.typ * (A.t, float) Result.t) list ->
      typ ->
      Memory.t * (A.t, float) Result.t =
    let body = Memory.cfetch cpu name in
    fun args typ ->
      let (args_int, args_float), _ =
        List.fold_left
          (fun ((acc_i, acc_f), (i, f)) (typ, v) ->
            match (typ, v) with
            | Int, Result.Int x ->
                ((SMap.add (Format.sprintf "i%d" i) x acc_i, acc_f), (i + 1, f))
            | Float, Result.Float x ->
                ((acc_i, SMap.add (Format.sprintf "fi%i" i) x acc_f), (i, f + 1))
            | Int, Result.Float f ->
                raise
                  (RuntimeError
                     (Format.asprintf
                        "was expecting int but got float %f when calling %s" f
                        name))
            | Float, Result.Int x ->
                raise
                  (RuntimeError
                     (Format.asprintf
                        "was expecting float but got int %s when calling %s"
                        (A.to_string x) name))
            | _ ->
                raise
                  (RuntimeError
                     (Format.asprintf "non numeric argument when calling %s"
                        name)))
          ((SMap.singleton "rv" (A.of_int 0), SMap.singleton "fv" 0.), (0, 0))
          args
      in
      (* Create a buffer for routine's traces *)
      let trace = !Vmio.trace in
      let buff = Buffer.create 25 in
      let trace_buff = Format.formatter_of_buffer buff in
      if Option.is_some trace then Vmio.trace := Some trace_buff;
      let restore_trace_channel () =
        Format.fprintf trace_buff "%!";
        Option.iter
          (fun out ->
            if Vmio.remove_lazy_endline out then Format.fprintf out "@<0>\n";
            Format.fprintf out "%s" (String.of_seq (Buffer.to_seq buff));
            if List.mem trace_buff !Vmio.lazy_endline then
              Vmio.add_lazy_endline out)
          trace;
        Vmio.trace := trace
      in
      (* Save temporaries *)
      let temp = cpu.temporaries.temp in
      let ftemp = cpu.temporaries.ftemp in
      let temporaries =
        { cpu.temporaries with temp = args_int; ftemp = args_float }
      in
      (* Evaluate the routine *)
      let mem' =
        try eval_stmts_stack { cpu with temporaries } None [ body ]
        with e ->
          restore_trace_channel ();
          raise e
      in
      let result =
        match typ with
        | Tree.Int -> Result.Int (Memory.rfetch mem' "rv")
        | Float -> Result.Float (Memory.rfetchF mem' "fv")
      in
      (* Restore temporaries *)
      let temporaries = { mem'.temporaries with temp; ftemp } in
      (* Print Routine traces *)
      restore_trace_channel ();
      ({ mem' with temporaries }, result)

  (** [evalEseq cpu s e] Evaluate the statement [s] and return the value of the
      evaluation of the expression [e]. *)
  and evalEseq (cpu : Memory.t) (s : stmt) (e : expr) :
      Memory.t * (A.t, float) Result.t =
    Vmio.trace_indent "evalEseq\n";
    (* TODO : use indices and array instead of assoc list *)
    let ncpu = eval_stmts_stack cpu (Some s) [ [ s ] ] in
    let nncpu, r = eval_expr ncpu e in
    Vmio.trace_dedent (Format.asprintf "Eseq -> %a\n" result_print r);
    (nncpu, r)

  (** [eval_expr cpu e] Evaluate an expression [e] with the memory state [cpu],
      by calling the function corresponding to the case, and return the result
      of the expression and the memory state after the evaluation.

      [eval_expr] is type [acc -> 'a -> acc * 'b] for [List.fold_left_map] *)
  and eval_expr (cpu : Memory.t) (e : expr) : Memory.t * (A.t, 'b) Result.t =
    match e.payload with
    | Const x ->
        let x = A.of_string x in
        Vmio.print_trace (Format.sprintf "const %s\n" (A.to_string x));
        (cpu, Int x)
    | ConstF x ->
        let x = float_of_string x in
        Vmio.print_trace (Format.sprintf "const %f\n" x);
        (cpu, Float x)
    | Name name -> evalName ~loc:e.loc cpu name
    | Temp name -> (
        Vmio.print_trace (Format.sprintf "temp %s" name);
        try
          let res = Memory.fetch cpu name in
          Vmio.print_trace (Format.asprintf " = %a\n" result_print res);
          (cpu, res)
        with Not_found ->
          Vmio.print_trace "\n";
          runtime_error (Format.sprintf "No temporary named \"%s\"" name) e.loc)
    | Binop (op, e1, e2) -> evalBinop cpu op e1 e2
    | Mem e -> evalMem cpu e
    | Call ({ payload = Name f; _ }, args, typ) -> evalCall e.loc cpu f args typ
    | Call _ -> runtime_error "Call on non-name value" e.loc
    | Eseq (s, e) -> evalEseq cpu s e

  (** [eval_stmt cpu s] Evaluate a statement [s] with the memory state [cpu], by
      calling the function corresponding to the case, and return the memory
      state after the evaluation. *)
  and eval_stmt (cpu : Memory.t) (s : stmt) : Memory.t =
    match s.payload with
    | Move (m, e) -> evalMove cpu m e
    | Sxp e ->
        Vmio.trace_indent "eval sxp\n";
        let ncpu, r = eval_expr cpu e in
        Vmio.trace_dedent (Format.asprintf "sxp : %a\n" result_print r);
        ncpu
    | Jump ({ payload = Name label; _ }, _) -> jump_to cpu s.loc label
    | Jump (e, _) -> runtime_error "Jump on non-label" e.loc
    | Cjump (op, left, right, t, f) ->
        evalCjump cpu s.loc (op, left, right, t, f)
    | Seq ls -> evalSeq cpu ls
    | Label l ->
        Vmio.trace_with_offset 0 (Format.sprintf "label %s\n" l);
        cpu
    | Litteral (lab, str) ->
        Vmio.trace_with_offset 0 (Format.sprintf "label %s : \"%s\"\n" lab str);
        cpu

  (** [evalSeq cpu seq] Evaluate a sequence of statements [seq] and return the
      memory state after. *)
  and evalSeq (cpu : Memory.t) (ls : stmt list) : Memory.t =
    Vmio.trace_indent "eval seq\n";
    let r = List.fold_left eval_stmt cpu ls in
    Vmio.trace_dedent "end seq\n";
    r

  (** [eval_stmts_stack cpu s stack] Evaluate a stack of sequences [stack], as
      defined in flow.ml. If a jump is catched, it will try to find its
      destination to evaluate it, using the memory state given :
      - If [s] is [None], it will search in the labels in top level
      - Otherwise, it will search in the labels of the corresponding [ESEQ]
      - If no destination is found, the jump is propagated *)
  and eval_stmts_stack (cpu : Memory.t) (s : stmt option)
      (stack : stmt list list) : Memory.t =
    try
      match stack with
      | h :: t ->
          let ncpu = List.fold_left eval_stmt cpu h in
          List.fold_left
            (fun cpu stmts ->
              Vmio.trace_dedent "end seq\n";
              List.fold_left eval_stmt cpu stmts)
            ncpu t
      | [] -> cpu
    with JumpException (dest, loc, ncpu) ->
      let stack, level =
        try Memory.jump_dest cpu s dest
        with Not_found -> raise (JumpException (dest, loc, ncpu))
      in
      if !jump_debug then
        Vmio.eprintf "Jump to@\n%a%!"
          (Format.pp_print_list
             ~pp_sep:(fun fmt () -> Format.fprintf fmt "@\nin@\n")
             (Format.pp_print_list
                ~pp_sep:(fun fmt () -> Format.fprintf fmt "@\n")
                print_stmt))
          stack;
      Vmio.set_offset ~number:level ~size:2;
      eval_stmts_stack ncpu s stack

  let eval_prog ~heapsize ~stacksize (prog : stmt list) : Memory.t * int =
    try
      let cpu = Memory.initialize ~heapsize ~stacksize prog in
      let main =
        try Memory.cfetch cpu "main"
        with Failure _ -> raise (RuntimeError "No routine main")
      in
      try (eval_stmts_stack cpu None [ main ], 0) with
      | JumpException (label, loc, _cpu) ->
          runtime_error
            (Format.asprintf "Invalid jump destination : %s" label)
            loc
      | Runtime.StdSystem.ExitException (int, mem) -> (mem, int)
    with Preload.PreloadError (s, loc) -> ill_formed s loc

  let eval prog : unit =
    try
      let out_buff = Buffer.create 10 in
      let out_channel = Format.formatter_of_buffer out_buff in
      let err_buff = Buffer.create 50 in
      let err_channel = Format.formatter_of_buffer err_buff in
      if !trace then
        Vmio.init ~out_channel ~err_channel ~trace:Format.std_formatter
          In_channel.stdin
      else Vmio.init ~out_channel ~err_channel In_channel.stdin;
      Option.iter (fun out -> Format.fprintf out "%!") !Vmio.trace;
      let end_state, code =
        if !ssa_check then (Memory.initialize ~heapsize:0 ~stacksize:0 [], 0)
        else eval_prog ~heapsize:!heapsize ~stacksize:!stacksize prog
      in
      Option.iter (fun out -> Format.fprintf out "%!") !Vmio.trace;
      Vmio.trace_with_offset 0 (Format.sprintf "Exit with code : %d\n" code);
      (* Show temporaries *)
      Vmio.print_trace (Format.asprintf "\n%a\n%!" Memory.print_temp end_state);
      (* Show out and err *)
      Format.fprintf out_channel "%!";
      Format.fprintf err_channel "%!";
      Format.printf "%s%!" (Buffer.contents out_buff);
      Format.eprintf "%s%!" (Buffer.contents err_buff);
      exit code
    with RuntimeError msg -> Terminal.error msg 120
end

module Eval32 = Make (Int32)
module Eval64 = Make (Int64)

let run prog : unit =
  if !Utils.word_size = 32 then Eval32.eval prog else Eval64.eval prog
