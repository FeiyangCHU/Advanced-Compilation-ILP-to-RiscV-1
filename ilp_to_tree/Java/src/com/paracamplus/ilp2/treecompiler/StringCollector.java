package com.paracamplus.ilp2.treecompiler;

import java.util.Map;
import java.util.HashMap;

import com.paracamplus.ilp2.interfaces.IASTvisitor;
import com.paracamplus.ilp2.interfaces.IASTloop;
import com.paracamplus.ilp2.interfaces.IASTassignment;
import com.paracamplus.ilp2.interfaces.IASTprogram;
import com.paracamplus.ilp2.interfaces.IASTfunctionDefinition;
import com.paracamplus.ilp1.compiler.CompilationException;

public final class StringCollector
  extends com.paracamplus.ilp1.treecompiler.StringCollector
  implements IASTvisitor<Void, Void, CompilationException> {

  public Void collect(IASTprogram iast)
    throws CompilationException {
    visit(iast, null);
    return null;
  }

  public Void visit(IASTprogram iast, Void context)
    throws CompilationException {
    IASTfunctionDefinition[] fundefs = iast.getFunctionDefinitions();
    for (int i = 0; i < fundefs.length; i++) {
      visit(fundefs[i],context);
    }
    iast.getBody().accept(this, context);
    return null;
  }

  public Void visit(IASTfunctionDefinition iast, Void context)
    throws CompilationException {
    iast.getBody().accept(this, context);
    return null;
  }

  @Override
  public Void visit(IASTloop iast, Void context) throws CompilationException {
    iast.getCondition().accept(this, context);
    iast.getBody().accept(this, context);
    return null;
  }

  @Override
  public Void visit(IASTassignment iast, Void context) throws CompilationException {
    iast.getExpression().accept(this,context);
    return null;
  }
}
