open Utils
open Result
open Tree

module Make (A : Integer) = struct
  open Exceptions

  let zeroary f fname floc mem (args : (Tree.expr * ('a, 'b) Result.t) list) =
    match args with
    | [] -> (
        try f mem
        with Exceptions.RuntimeError msg ->
          runtime_error (Format.asprintf "%s" msg) floc)
    | _ ->
        runtime_error
          (Format.asprintf "%s : expected 0 argument, given %i" fname
             (List.length args))
          floc

  let unary f fname floc mem (args : (Tree.expr * ('a, 'b) Result.t) list) =
    match args with
    | [ (_, Int x) ] -> (
        try f mem x
        with RuntimeError msg -> runtime_error (Format.asprintf "%s" msg) floc)
    | [ (expr, res) ] ->
        runtime_error
          (Format.asprintf "%s : expected integer, given %a" fname
             Result.print_typ res)
          expr.loc
    | _ ->
        runtime_error
          (Format.asprintf "%s : expected 1 argument, given %i" fname
             (List.length args))
          floc

  let unaryF f fname floc mem (args : (Tree.expr * ('a, 'b) Result.t) list) =
    match args with
    | [ (_, Float x) ] -> (
        try f mem x
        with RuntimeError msg -> runtime_error (Format.asprintf "%s" msg) floc)
    | [ (expr, res) ] ->
        runtime_error
          (Format.asprintf "%s : expected float, given %a" fname
             Result.print_typ res)
          expr.loc
    | _ ->
        runtime_error
          (Format.asprintf "%s : expected 1 argument, given %i" fname
             (List.length args))
          floc

  let binary f fname floc mem (args : (Tree.expr * ('a, 'b) Result.t) list) =
    match args with
    | [ (_, Int x); (_, Int y) ] -> (
        try f mem x y
        with RuntimeError msg -> runtime_error (Format.asprintf "%s" msg) floc)
    | [ (_, Int _); (expr, res) ] ->
        runtime_error
          (Format.asprintf "%s : second argument expected integer, given %a"
             fname Result.print_typ res)
          expr.loc
    | [ (expr, res); (_, Int _) ] ->
        runtime_error
          (Format.asprintf "%s : first argument expected integer, given %a"
             fname Result.print_typ res)
          expr.loc
    | _ ->
        runtime_error
          (Format.asprintf "%s : expected 2 argument, given %i" fname
             (List.length args))
          floc

  let ternary f fname floc mem (args : (Tree.expr * ('a, 'b) Result.t) list) =
    match args with
    | [ (_, Int x); (_, Int y); (_, Int z) ] -> (
        try f mem x y z
        with RuntimeError msg -> runtime_error (Format.asprintf "%s" msg) floc)
    | [ (_, Int _); (_, Int _); (expr, res) ] ->
        runtime_error
          (Format.asprintf "%s : third argument expected integer, given %a"
             fname Result.print_typ res)
          expr.loc
    | [ (_, Int _); (expr, res); (_, _) ] ->
        runtime_error
          (Format.asprintf "%s : second argument expected integer, given %a"
             fname Result.print_typ res)
          expr.loc
    | [ (expr, res); (_, _); (_, _) ] ->
        runtime_error
          (Format.asprintf "%s : first argument expected integer, given %a"
             fname Result.print_typ res)
          expr.loc
    | _ ->
        runtime_error
          (Format.asprintf "%s : expected 3 argument, given %i" fname
             (List.length args))
          floc
end
