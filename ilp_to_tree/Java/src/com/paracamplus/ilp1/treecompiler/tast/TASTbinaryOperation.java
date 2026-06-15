package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTbinaryOperation;


public class TASTbinaryOperation extends ASTbinaryOperation implements ITASTbinaryOperation {
  private final ITASTexpression leftOperand;
  private final ITASTexpression rightOperand;
  private final Type type;

  public TASTbinaryOperation(IASToperator operator,
                             ITASTexpression leftOperand,
                             ITASTexpression rightOperand,
                             Type type) {
    super(operator, leftOperand, rightOperand);
    this.leftOperand = leftOperand;
    this.rightOperand = rightOperand;
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
  public ITASTexpression getLeftOperand() { return leftOperand; }

  @Override
  public ITASTexpression getRightOperand() { return rightOperand; }


  @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
            throws Anomaly {
    return visitor.visit(this, data);
  }
}
