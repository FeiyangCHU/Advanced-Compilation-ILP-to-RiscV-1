open Treelib
open! Tree
open! Tree_helper
open! Utils

(* Basic block formation with fall-through insertion *)
(* ================================================= *)

(*
- Separate literals from code
  Keep string/data labels (Litteral) apart from control-flow code.
  This preserves .data vs .text separation for later passes.

- Identify routines
  Each routine starts at a Label <name> and ends at Label "end".
  This allows later passes to process functions individually.

- Decompose routines into basic blocks
  Each basic block Starts at a Label
  Ends at a Jump, Cjump, or routine end
  Has a body of sequential instructions
  Fall-throughs (implicit next-block execution) are made explicit via jumps.

- Normalize control flow
  Ensure every Cjump is immediately followed by its false label.
  Simplifies later analyses: liveness, CFG, optimization, or code generation.

- Reassemble
  After reordering, rebuild a valid linear program.
*)


(* Right now, basic block reordering is not implemented. CJUMP
   normalization (which is necessary) is made in Linearization. You
   can implement here the basic block reordering, with correct
   handling of CJUMP normalization, in which case the normalize_cjump
   function of linearization will have no effect *)
let reordering p = p
