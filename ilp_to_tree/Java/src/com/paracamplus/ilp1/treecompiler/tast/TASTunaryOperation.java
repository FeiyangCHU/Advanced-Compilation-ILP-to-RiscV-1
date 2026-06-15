package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTunaryOperation;


public class TASTunaryOperation
  extends ASTunaryOperation implements ITASTunaryOperation {
  private final ITASTexpression operand;
  private final Type type;

  public TASTunaryOperation(IASToperator operator,
                             ITASTexpression operand,
                             Type type) {
    super(operator, operand);
    this.operand = operand;
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
  public ITASTexpression getOperand() { return operand; }

  @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
    throws Anomaly {
    return visitor.visit(this, data);
  }

}
