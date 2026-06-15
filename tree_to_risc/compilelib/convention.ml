open Treelib
open! Utils


(* -------------------------------------------------------------------------- *)
(* Final assembly rewriting stage responsible for inserting calling
   convention machinery around the already register-allocated code.

   It performs two main tasks:
   1) Prologue / Epilogue generation
      - Determines which callee-saved registers are actually used
        (based on the coloring maps).
      - Computes the required stack frame size (ABI-aligned).
      - Generates:
          * Prologue: adjust stack pointer, save ra, save used callee-saved
            integer and floating-point registers.
          * Epilogue: restore saved registers, restore ra, reset stack
            pointer, and return.
   2) Call rewriting
      - For each function call instruction, inserts code to save and
        restore caller-saved registers around the call.

   Inputs:
     - colors / fcolors : register allocation maps (int and float).
     - callee_saved     : list of callee-saved registers.
     - caller_saved     : list of caller-saved registers.
     - instrs           : body instructions (after register allocation).

   Output:
     - The rewritten instruction list (with caller-save handling),
     - The function prologue,
     - The function epilogue.
*)

let generate (colors : string SMap.t) (fcolors : string SMap.t)
    (callee_saved : string list) (caller_saved : string list) (instrs : Asm.t) =
  (* Collect all physical registers assigned by the coloring *)
  let assigned_regs =
    SMap.fold (fun _ r acc -> SSet.add r acc) colors SSet.empty
    |> fun s -> SMap.fold (fun _ r acc -> SSet.add r acc) fcolors s
  in

  let used_callee =
    List.filter (fun r -> SSet.mem r assigned_regs) callee_saved
  in
  let used_caller =
    List.filter (fun r -> SSet.mem r assigned_regs) caller_saved
  in

  (* Frame layout: ra | callee-saved regs | caller-saved spill area *)
  let saved_regs = "ra" :: used_callee in
  let num_slots = List.length saved_regs + List.length used_caller in
  let frame_size = ((num_slots * 8 + 15) / 16) * 16 in (*Aligner sur 16 octets*)

  (* Offsets within the frame *)
  let callee_offsets = List.mapi (fun i reg -> (reg, i * 8)) saved_regs in
  let caller_offsets =
    let base = List.length saved_regs * 8 in
    List.mapi (fun i reg -> (reg, base + i * 8)) used_caller
  in

  (* Fonctions auxiliaires permettant de générer des instructions de stockage et de chargement*)
  let store_instr reg offset =
    let is_f = Tree_helper.is_float_temp reg in
    Asm.Oper
      {
        assem =
          Format.sprintf "%s %s, %d(sp)"
            (if is_f then "fsw" else "sd") reg offset;
        dst = [];
        src = [ reg; "sp" ];
        jump = None;
        is_call = false;
      }
  in
  let load_instr reg offset =
    let is_f = Tree_helper.is_float_temp reg in
    Asm.Oper
      {
        assem =
          Format.sprintf "%s %s, %d(sp)"
            (if is_f then "flw" else "ld") reg offset;
        dst = [ reg ];
        src = [ "sp" ];
        jump = None;
        is_call = false;
      }
  in

  let prologue =
    Asm.Oper
      {
        assem = Format.sprintf "addi sp, sp, -%d" frame_size;
        dst = [ "sp" ];
        src = [ "sp" ];
        jump = None;
        is_call = false;
      }
    :: List.map (fun (reg, off) -> store_instr reg off) callee_offsets
  in

  let epilogue =
    List.map (fun (reg, off) -> load_instr reg off) callee_offsets
    @ [
        Asm.Oper
          {
            assem = Format.sprintf "addi sp, sp, %d" frame_size;
            dst = [ "sp" ];
            src = [ "sp" ];
            jump = None;
            is_call = false;
          };
        Asm.Oper
          { assem = "ret"; dst = []; src = []; jump = None; is_call = false };
      ]
  in

  (* Caller-save around call instructions *)
  let live = Regalloc.analyze instrs in
  let caller_save_set = SSet.of_list caller_saved in

  let body =
    List.concat
      (List.mapi
        (fun i instr ->
            match instr with
            | Asm.Oper ({ is_call = true; _ }) ->
                let defs = Regalloc.def instr in
                let to_save_temps = SSet.diff live.(i).live_out defs in
                let to_save_regs =
                  SSet.fold
                    (fun t acc ->
                      match SMap.find_opt t colors with
                      | Some r when SSet.mem r caller_save_set ->
                          SSet.add r acc
                      | _ -> (
                          match SMap.find_opt t fcolors with
                          | Some r when SSet.mem r caller_save_set ->
                              SSet.add r acc
                          | _ -> acc))
                    to_save_temps SSet.empty
                in
                let saves =
                  SSet.fold
                    (fun reg acc ->
                      let off = List.assoc reg caller_offsets in
                      store_instr reg off :: acc)
                    to_save_regs []
                in
                let restores =
                  SSet.fold
                    (fun reg acc ->
                      let off = List.assoc reg caller_offsets in
                      load_instr reg off :: acc)
                    to_save_regs []
                in
                saves @ [ instr ] @ restores
            | _ -> [ instr ])
          instrs)
  in

  (body, prologue, epilogue)
