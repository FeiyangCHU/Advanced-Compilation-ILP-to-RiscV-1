open Treelib

(* A tile describes one instruction pattern *)
type tile = {
  cost : int;
  matches_exp : Tree.expr -> bool;
  emit_exp :
    (Tree.expr -> Asm.temp) ->
    (* recurse *)
    Tree.expr ->
    string Utils.SMap.t ->
    (* float literals map *)
    Asm.instr list * Asm.temp;
}

(* -------------------------------------------------------------------------- *)
(* Signature describing a target architecture backend.

   It provides everything required by the backend to perform
   instruction selection and register allocation for a specific
   machine (e.g., RISC-V):

     - Tree tiling rules (instruction selection)
     - Statement lowering
     - Available registers
     - Calling convention details
     - File-level assembly boilerplate
*)

module type ARCH = sig
  (* Instruction selection interface *)
  (***********************************)

  (* Set of tree tiles used for cost-based instruction
     selection. Each tile describes how to match an IR pattern and
     emit the corresponding assembly code. *)
  val tiles : Tree_helper.rewritter -> tile list

  (* Parameter moves
   This function generates the sequence of instructions that move
   a function's incoming arguments from their assigned temporary
   registers (i0, i1, i2, ... for integers, fi0, fi1, ... for floats)
   into the physical argument registers (a0, a1, ... / fa0, fa1, ...).

   These moves must be emitted **at the start of every function** to
   respect the target calling convention, ensuring that each function
   sees its parameters in the correct registers.
   Returns a list of assembly instructions performing all required moves.*)
  val param_moves : string list -> Asm.instr list

  (* Lowers a single IR statement into assembly instructions.
     Receives:
       - a rewriter (for fresh temporaries),
       - a function to evaluate expressions into temps,
       - the statement to translate. *)
  val munch_stm :
    Tree_helper.rewritter ->
    (Tree.expr -> Asm.temp) ->
    Tree.stmt ->
    Asm.instr list

  (* Register sets and calling convention *)
  (****************************************)

  (* Allocatable integer and floating-point registers.*)
  val registers : string list
  val f_registers : string list

  (* Registers that must be preserved according to the calling
     convention. *)
  val callee_saved : string list
  val caller_saved : string list

  (* precolored registers for allocation.*)
  val precolored : (string * string) list
  val f_precolored : (string * string) list

  (* Target-specific assembly emitted at the beginning and end
     of the generated file (e.g., directives, runtime setup). *)
  val file_prologue : string
  val file_epilogue : string
end
