package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTvariable;

public class TASTvariable extends ASTvariable implements ITASTvariable {

  private final Type type;

  public TASTvariable(String name, Type type) {
    super(name);
    this.type = type;
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
