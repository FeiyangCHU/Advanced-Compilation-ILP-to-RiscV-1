package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.ast.ASTstring;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTstring;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvisitor;

public class TASTstring extends ASTstring implements ITASTstring {

  private final Type type;

  public TASTstring(String value, Type type) {
    super(value);
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
