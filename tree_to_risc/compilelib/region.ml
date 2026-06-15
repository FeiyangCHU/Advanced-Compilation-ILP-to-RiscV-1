open Treelib
open Tree

(* This file is a placeholder to implement a conflict analysis to
   detect expression/instruction whose evaluation can commute. Right
   now, it is left for students to implment and the conservative
   approach (always conflict) is provided *)

(* Commutatitivity definition:
------------------------------
   two expressions commute if changing their evaluation order does not change
   the overall behaviour of the program : that is if we have memory equivalence
   and io equivalence.

   We have memory equivalence if no memory region (either temporary or absolute
   address) is written in one of the two expression, and read or written in the
   other (read-read conflict do not matter)

   e.g:

   - 2, a // commute
   - a, (b+a) // commute
   - a, (b:=a) // commute

   - a, (a:=2; 42) // do NOT commute *)


let conflicts_e_e (e1 : expr) (e2 : expr) =
   true

let conflicts_s_e (s1 : stmt) (e2 : expr) =
   true
