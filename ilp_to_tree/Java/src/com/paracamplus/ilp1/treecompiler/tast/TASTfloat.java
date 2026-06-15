package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTfloat;


public class TASTfloat
  extends ASTfloat implements ITASTfloat {
  private final Type type;

  public TASTfloat(String description, Type type) {
    super(description);
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
            throws Anomaly {
    return visitor.visit(this, data);
  }
}
