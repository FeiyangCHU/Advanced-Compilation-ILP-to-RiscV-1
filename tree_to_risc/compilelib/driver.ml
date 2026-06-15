open Treelib
open Utils
open Regalloc

module Emit (A : Backend.ARCH) = struct
  let get_colorizations (registers : string list) (f_registers : string list)
      (selected : Asm.t) : Regalloc.colorization * Regalloc.colorization =
    let live = Regalloc.analyze selected in
    let ig, fg = Regalloc.build_interference selected live in
    let col = Regalloc.color ~registers ~precolored:A.precolored ig in
    let f_col =
      Regalloc.color ~registers:f_registers ~precolored:A.f_precolored fg
    in
    (col, f_col)

  let assign_function col float_col =
   fun t ->
    if SMap.mem t col.physical_bindings then SMap.find t col.physical_bindings
    else if SMap.mem t float_col.physical_bindings then
      SMap.find t float_col.physical_bindings
    else failwith ("uncolored temporary " ^ t)

  let allocate_registers ~routinename ~(selected : Asm.t) =
    let col, float_col = get_colorizations A.registers A.f_registers selected in
    let reg_of_temp = assign_function col float_col in
    if col.spills <> [] || float_col.spills <> [] then
      failwith ("spilling not implemented in " ^ routinename);
    let asm, prologue, epilogue =
      Convention.generate col.physical_bindings float_col.physical_bindings
        A.callee_saved A.caller_saved selected
    in
    let entry =
      Asm.label (if routinename = "main" then "ILPmain" else routinename)
    in
    (entry :: prologue)
    @ List.map (Asm.assign_physical_register reg_of_temp) asm
    @ epilogue

  let instr oc i = output_string oc (Format.asprintf "%a\n" Asm.emit i)

  let routine oc name instrs =
    output_string oc ("\n# -------- Function " ^ name ^ " --------\n");
    List.iter (instr oc) instrs;
    output_string oc ("# -------- End of function " ^ name ^ " --------\n")

  let data oc string_literals float_literals =
    if not (SMap.is_empty string_literals) then (
      output_string oc ".section .rodata\n";
      SMap.iter
        (fun l s ->
          output_string oc (l ^ ":\n");
          output_string oc ("\t.string \"" ^ String.escaped s ^ "\"\n"))
        string_literals);

    if not (SMap.is_empty float_literals) then (
      output_string oc ".section .rodata\n";
      SMap.iter
        (fun lit lab ->
          output_string oc (lab ^ ":\n");
          output_string oc ("\t.float " ^ lit ^ "\n"))
        float_literals)
end

module RV = struct
  module Selector = Select.Make (Riscv_tiler)
  module EM = Emit (Riscv_tiler)

  let compile prog filename =
    let loaded = Preload.build prog in
    let rewriter = Tree_helper.build_rewriter prog in
    let string_literals = Tree_helper.collect_litterals prog in
    let float_literals = Tree_helper.collect_float_litterals prog in
    let select_routines =
      SMap.map (Selector.select rewriter float_literals) loaded.routines
    in
    let asm_oc = open_out (Filename.chop_extension filename ^ ".asm") in
    let fmt_asm_oc = Format.formatter_of_out_channel asm_oc in
    SMap.iter
      (fun r_name select ->
        Format.fprintf fmt_asm_oc "// Routine %s\n%a\n" r_name
          (Format.pp_print_list ~pp_sep:Format.pp_print_newline Asm.emit)
          select;
        let cfg_oc =
          open_out (Filename.chop_extension filename ^ "." ^ r_name ^ ".cfg")
        in
        Asm.to_dot select cfg_oc)
      select_routines;
    let asm_routines =
      SMap.mapi
        (fun name selected -> EM.allocate_registers ~routinename:name ~selected)
        select_routines
    in
    let oc = open_out filename in
    EM.data oc string_literals float_literals;
    output_string oc Riscv_tiler.file_prologue;
    SMap.iter (EM.routine oc) asm_routines;
    output_string oc Riscv_tiler.file_epilogue;
    close_out oc
end
