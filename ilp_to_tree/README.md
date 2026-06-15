# The Ja Project

The goal of this project is to compile some ILP program

```ILP
function deuxfois(x)
(
  2 * x
);

print(deuxfois(27))
```

to a tree program:

```Tree
# Routine: L1
label L1
  # Prologue
  move temp t1 temp fp
  move temp fp temp sp
  move 
    temp sp
    binop sub
      temp sp
      const 42
  move
    mem
    binop add
      temp fp
      const -4
    temp i0
  # Body
  move
    temp rv
    binop
      mul
      const 2  
      temp i0  
# Epilogue
  move temp sp temp fp
  move temp fp temp t1
label end

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

# Difficulties

-ILP has a lot of types : float, int, bool, string, functions, objects
-Tree has two : int and floats

-ILP is dynamically typed and authorizes overloading
-Tree must know the types of values it manipulates to be able to store them in a matching storing unit.

To solve these issues, we decide to statically type ILP (using a very
permissive and flexible type system), resolve ambiguities using strict
operators and then compile the resolved representation

# Stages:
- Typing (Static Type inference)
- Resolution (Overloading resolution and monomorphization)
- Code emission

### First Steps
run `make`. This will compile the project.

run `./ja.sh Samples/u01-1.ilpml`. This will compile the ilpml source file and produce
(among other things) the Tree file: Samples/u01-1.hir

run `ls Samples/u01-1.*` and examine the produced files.

You can also execute run `./ja.sh --check Samples/u01-1.ilpml` to
verify that the checkpoints representations (hir) run
correctly.

run `make test`. This will lauch `./ja.sh --check` on all ilpml
files of the Samples directory.

### Task
Complete the files:
- ilp1/treecompiler/Typer.java
- ilp1/treecompiler/Resolver.java
- ilp1/treecompiler/Compiler.java
- ilp2/treecompiler/Typer.java
- ilp2/treecompiler/Resolver.java
- ilp2/treecompiler/Compiler.java
