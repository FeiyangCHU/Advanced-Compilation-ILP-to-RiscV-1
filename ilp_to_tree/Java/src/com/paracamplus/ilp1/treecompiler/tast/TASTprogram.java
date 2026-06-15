package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.ast.ASTprogram;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTprogram;

public class TASTprogram extends ASTprogram implements ITASTprogram {
  private final Type type;
  private final ITASTexpression expression;

  public TASTprogram(ITASTexpression expression, Type t) {
    super(expression);
    this.expression = expression;
    type=t;
  }
  @Override
  public ITASTexpression getBody() {
    return this.expression;
  }

  public Type getType() {
    return this.type;
  }

}
