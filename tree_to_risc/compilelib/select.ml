open Treelib
open Utils
open Backend
open Tree_helper

exception SelectionException of string

(* -------------------------------------------------------------------------- *)
(* Make functor:
   Builds an instruction selector parameterized by a target architecture.

   The architecture module `A` provides:
     - A set of tiles (pattern -> assembly templates with costs)
     - Statement lowering logic
     - Architecture-specific instruction definitions

   The selector implements:
     - Cost-based tree tiling for expressions (munch_exp)
     - Statement lowering (munch_stm)
*)

module Make (A : ARCH) = struct
  let instrs : Asm.instr list ref = ref []
  let emit i = instrs := i :: !instrs

  (* Performs tree-based instruction selection for an expression.

      For a given IR expression [e], it:
      1. Retrieves all architecture tiles that can match [e].
      2. Selects the lowest-cost matching tile (greedy choice).
      3. Recursively generates code for sub-expressions.
      4. Emits the corresponding assembly instructions.
      5. Returns the temporary register holding the result.

      If no tile matches the expression, selection fails. *)
  let rec munch_exp (r : rewritter) (float_literals : string SMap.t)
      (e : Tree.expr) : string =
    let applicable = List.filter (fun t -> t.matches_exp e) (A.tiles r) in
    match applicable with
    | [] ->
        raise
          (SelectionException
             (Format.asprintf "No tile for %a" Tree.print_expr e))
    | h :: tl ->
        let best =
          List.fold_left
            (fun t1 t2 -> if t2.cost < t1.cost then t2 else t1)
            h tl
        in
        let code, temp =
          best.emit_exp (munch_exp r float_literals) e float_literals
        in
        List.iter emit code;
        temp

  (* Performs instruction selection for IR statements. *)
  let rec munch_stm (r : rewritter) (float_literals : string SMap.t)
      (s : Tree.stmt) =
    match s.payload with
    | Tree.Move _ | Tree.Jump _ | Tree.Cjump _ | Tree.Label _ ->
        List.iter emit (A.munch_stm r (munch_exp r float_literals) s)
    | Tree.Sxp e -> ignore (munch_exp r float_literals e)
    | Tree.Seq l -> List.iter (munch_stm r float_literals) l
    | Tree.Litteral _ -> ()

  (* Entry point of the instruction selection phase.
     Given:
       - A rewriter 'r' (used to generate fresh temporaries),
       - A map of float literals,
       - A program routine represented as a list of IR statements,
     It:
       1. Clears the internal instruction buffer.
       2. Traverses the program statement by statement.
       3. Applies tree tiling (via munch_stm / munch_exp).
       4. Collects and returns the generated assembly instructions
          in the correct execution order.
  *)
  let select (r : Tree_helper.rewritter) (float_literals : string SMap.t)
      (prog : Tree.program) : Asm.t =
    instrs := [];
    let function_params = Tree_helper.collect_parameters prog in
    let moves = A.param_moves (function_params |> SSet.elements) in
    List.iter emit moves;
    List.iter (munch_stm r float_literals) prog;
    List.rev !instrs
end
