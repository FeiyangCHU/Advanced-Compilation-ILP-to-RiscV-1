package com.paracamplus.ilp1.treecompiler;

import java.util.Map;
import java.util.HashMap;

import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.compiler.CompilationException;

public class StringCollector
  implements IASTvisitor<Void, Void, CompilationException> {

  private final Map<String,String> stringTable = new HashMap<>();
  private long labelCounter = 0;

  /** Produce a fresh string label */
  private String newStringLabel() {
    return "L_str_" + (labelCounter++);
  }

  /** Public accessor */
  public Map<String,String> getStringTable() {
    return stringTable;
  }

  @Override
  public Void visit(IASTstring iast, Void context)
    throws CompilationException {
    stringTable.computeIfAbsent(
      iast.getValue(),
      v -> newStringLabel()
    );
    return null;
  }

  @Override public Void visit(IASTinteger i, Void c) { return null; }
  @Override public Void visit(IASTfloat   i, Void c) { return null; }
  @Override public Void visit(IASTboolean i, Void c) { return null; }
  @Override public Void visit(IASTvariable i, Void c) { return null; }

  @Override
  public Void visit(IASTunaryOperation iast, Void context)
    throws CompilationException {
    iast.getOperand().accept(this, context);
    return null;
  }

  @Override
  public Void visit(IASTbinaryOperation iast, Void context)
    throws CompilationException {
    iast.getLeftOperand().accept(this, context);
    iast.getRightOperand().accept(this, context);
    return null;
  }

  @Override
  public Void visit(IASTsequence iast, Void context)
    throws CompilationException {
    for (IASTexpression e : iast.getExpressions()) {
      e.accept(this, context);
    }
    return null;
  }

  @Override
  public Void visit(IASTalternative iast, Void context)
    throws CompilationException {
    iast.getCondition().accept(this, context);
    iast.getConsequence().accept(this, context);
    if (iast.isTernary()) {
      iast.getAlternant().accept(this, context);
    }
    return null;
  }

  @Override
  public Void visit(IASTblock iast, Void context)
    throws CompilationException {
    if (iast.getBindings() != null) {
      for (IASTblock.IASTbinding b : iast.getBindings()) {
        if (b.getInitialisation() != null) {
          b.getInitialisation().accept(this, context);
        }
      }
    }
    iast.getBody().accept(this, context);
    return null;
  }

  @Override
  public Void visit(IASTinvocation iast, Void context)
    throws CompilationException {
    iast.getFunction().accept(this, context);
    for (IASTexpression arg : iast.getArguments()) {
      arg.accept(this, context);
    }
    return null;
  }

  public Void visit(IASTprogram iast, Void context)
    throws CompilationException {
    iast.getBody().accept(this, context);
    return null;
  }

  public Void collect(IASTprogram iast)
    throws CompilationException {
    visit(iast, null);
    return null;
  }
}
