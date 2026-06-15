package com.paracamplus.ilp2.treecompiler.tast;

import com.paracamplus.ilp2.ast.ASTassignment;
import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTassignment;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTvisitor;

public class TASTassignment extends ASTassignment implements ITASTassignment {
  private final ITASTvariable variable;
  private final ITASTexpression expression;
  private final Type type;

  public TASTassignment(ITASTvariable variable, ITASTexpression expression, Type type) {
    super(variable, expression);
    this.variable = variable;
    this.expression = expression;
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
  public ITASTexpression getExpression() { return expression; }

  @Override
  public ITASTvariable getVariable() { return variable; }


  @Override
	public <Result, Data, Anomaly extends Throwable> Result accept(
    com.paracamplus.ilp1.treecompiler.interfaces.ITASTvisitor<Result, Data, Anomaly> visitor,
    Data data) throws Anomaly {
    return  ((ITASTvisitor <Result, Data, Anomaly>) visitor).visit(this, data);
  }
}
