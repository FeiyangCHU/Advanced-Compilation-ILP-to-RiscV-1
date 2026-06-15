# The Mel Project

The goal of this project is to compile some Tree program

```Tree
# Routine: L1
label L1
  move
    temp rv
    binop
      mul
      const 2  
      temp i0  

# Routine main
label main
sxp
  eseq 
    sxp
      call
        name print
        call 
          name string_of_int
          call
            name L1
            const 27            
          call end          
        call end        
      call end      
    const 0
label end
```

to a risc-V program

```risc-v
.section .text
    .globl _start

# int deuxfois(int x)
deuxfois:
    slli a0, a0, 1     # a0 = a0 * 2 (shift left by 1)
    ret

_start:
    li   a0, 27        # argument x = 27
    jal  ra, deuxfois  # call deuxfois(27)
                       # result now in a0 (54)

    # print integer in a0
    li   a7, 1         # syscall: print_int
    ecall

    # exit program
    li   a7, 10        # syscall: exit
    ecall
```

# Stages:
- Linearization
- Instruction Selection
- Liveness analysis
- Register allocation

### Work flow
run `make`. This will compile the project.

run `./mel.sh Samples/u01-1.hir`.

Right now, this should raise an exception. This is intended. It's your
job to incementally implement all of the functions skeletons that
raise a NotImplemented exception until the hir samples are compiled
normally.

When your compiler will be working correctly (at least partially),
running `./mel.sh Samples/u01-1.hir` will compile the hir source file
and produce (among other things) the riscv file: Samples/u01-1.s.

run `ls Samples/u01-1.*` and examine the produced files.

You can also execute run `./mel.sh --check Samples/u01-1.hir` to
verify that the checkpoints representations (lir,riscv) run
correctly.

run `make test`. This will lauch `./mel.sh --check` on all hir
files of the Samples directory.

### Task
Read the files:
- vmlib/frontend/tree.ml
- vmlib/frontend/tree_helper.ml
- compilelib/select.ml
- compilelib/backend.ml

Complete the files:
- compilelib/linearization.ml
- compilelib/region.ml (optional, but wishable for a smaller/better generated code)
- compilelib/blocks.ml (optional, but wishable for a smaller/better generated code)
- compilelib/riscv.ml
- compilelib/regalloc.ml
- compilelib/conventions.ml

You might want to modify:
- compilelib/asm.ml
- compilelib/driver.ml