package com.paracamplus.ilp2.treecompiler;

import java.io.IOException;
import java.io.Writer;
import java.io.BufferedWriter;
import java.io.StringWriter;

import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.treecompiler.tast.TASTvariable;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTinvocation;
import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTvisitor;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTloop;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTfunctionDefinition;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTassignment;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTprogram;

public class CompilerTree extends com.paracamplus.ilp1.treecompiler.CompilerTree
  implements ITASTvisitor<Void, Void, CompilationException> {

  public CompilerTree() {
    super();
    strCollect = new StringCollector();
    funNames = new HashMap<String,String>();
  }

  protected HashMap<String,String> funNames;

  public String compile(ITASTprogram program)
    throws CompilationException {

    StringWriter sw = new StringWriter();
    try {
      out = new BufferedWriter(sw);
      visit(program, null);
      out.flush();
    } catch (IOException exc) {
      throw new CompilationException(exc);
    }
    return sw.toString();
  }

  public void visit(ITASTprogram iast, Void context)
    throws CompilationException {
    emit(treeProgramPrefix);
    strCollect.collect(iast);
    ensureStringLiteral("true");
    ensureStringLiteral("false");

    emit("/* String Litterals */\n");
    for (Map.Entry<String,String> e : strCollect.getStringTable().entrySet()) {
      emit("label " + e.getValue() + " \"" + escape(e.getKey()) + "\"\n");
    }
    emit("\n");

    // Associate to each function a label *before* function definition
    // emission. Needed to have label already mapped for mutually
    // recurive functions
    for(ITASTfunctionDefinition f: iast.getFunctionDefinitions()){
      String fname = f.getName();
      String funLabel = newLabel();
      funNames.put(fname,funLabel);
    }

    emit("/* Function Definitions */\n");
    for(ITASTfunctionDefinition f: iast.getFunctionDefinitions()){
      emit("/* function : "+f.getFunctionVariable().getName()+" */\n");
      visit(f,context);
      emit("\n");
    }
    emit("\n");
    emit("/* Main */\n");
    emit("# Routine main\n");
    emit("label main\n");
    emit("sxp\n");
    indent();
    iast.getBody().accept(this, context);
    dedent();
    emit("\nlabel end\n");
  }

  public void visit(ITASTfunctionDefinition iast, Void context)
    throws CompilationException {

    String fname = iast.getName();
    String funLabel = funNames.get(fname);
    emit("");
    emit("# Routine: " + funLabel + "\n");
    emit("label " + funLabel + "\n");
    indent();
    enterScope();

    /* Parameters handling: bind variable to its arg name */
    ITASTvariable[] params = iast.getVariables();
    int intArg = 0;
    int floatArg = 0;

    for (int i = 0; i < params.length; i++) {
      String name;
      if (((TASTvariable) params[i]).getType() == Type.FLOAT) {
        name = "fi" + floatArg;
        floatArg++;
      } else {
        name = "i" + intArg;
        intArg++;
      }
      envStack.peek().put(params[i].getName(), name);
    }

    emit("# Body\n");
    emit("move\n");
    if (((ITASTexpression) iast.getBody()).getType() == Type.FLOAT)
      emit("temp fv\n");
    else
      emit("temp rv\n");

    iast.getBody().accept(this, context);
    emit("\nlabel end\n");
    leaveScope();
    dedent();
  }


  @Override
  public Void visit(ITASTloop iast, Void context) throws CompilationException {
    String startLabel = newLabel();
    String bodyLabel = newLabel();
    String endLabel = newLabel();

    emit("eseq\n");
    indent();
    enterSeq();
    emit("label " + startLabel + "\n");

    emit("cjump\n");
    emit("eq\n");
    iast.getCondition().accept(this, context);
    emit("\nconst 0\n");
    emit("name " + endLabel + "\n");
    emit("name " + bodyLabel + "\n");

    emit("label " + bodyLabel + "\n");
    emit("sxp\n");
    indent();
    iast.getBody().accept(this, context);
    emit("\n");
    dedent();

    emit("jump name " + startLabel + "\n");
    emit("label " + endLabel + "\n");
    exitSeq();
    emit("const 0");
    dedent();

    return null;
  }

  @Override
  public Void visit(ITASTassignment iast, Void context) throws CompilationException {
    String varName = iast.getVariable().getName();
    String target = null;

    for (Map<String, String> scope : envStack) {
      if (scope.containsKey(varName)) {
        target = scope.get(varName);
        break;
      }
    }

    if (target == null) {
      target = iast.getExpression().getType() == Type.FLOAT
        ? bindFloatVariable(varName)
        : bindVariable(varName);
    }

    emit("eseq\n");
    indent();
    enterSeq();
    emitMoveToTemp(target, iast.getExpression());
    exitSeq();
    emit("temp " + target);
    dedent();

    return null;
  }

  @Override
	public Void visit(ITASTinvocation iast, Void context)
    throws CompilationException {
    ITASTexpression function = iast.getFunction();
    ITASTvariable v = (ITASTvariable) function;
    String fname = v.getName();

    if (!funNames.containsKey(fname)) {
        return super.visit(iast, context);
    }

    String label = funNames.get(fname);
    emitCallExpr(label, iast.getType(), iast.getArguments());

    return null;
  }
}
