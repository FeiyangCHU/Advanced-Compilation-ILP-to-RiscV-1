package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.ast.ASTsequence;
import com.paracamplus.ilp1.treecompiler.interfaces.*;

public class TASTsequence
  extends ASTsequence implements ITASTsequence {

  private final ITASTexpression[] expressions;
  private final Type type;

  public TASTsequence(ITASTexpression[] expressions, Type type) {
    super(expressions);
    this.expressions = expressions;
    this.type = type;
  }

  @Override
  public ITASTexpression[] getExpressions() {
    return expressions;
  }

  @Override
  public Type getType() {
    return type;
  }

  @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
    throws Anomaly {
    return visitor.visit(this, data);
  }

}
