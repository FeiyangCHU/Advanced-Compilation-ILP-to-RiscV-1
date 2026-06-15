package com.paracamplus.ilp2.treecompiler.tast;

import com.paracamplus.ilp2.ast.ASTloop;
import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTloop;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTvisitor;

public class TASTloop extends ASTloop implements ITASTloop {
  private final ITASTexpression condition;
  private final ITASTexpression body;
  private final Type type;

  public TASTloop(ITASTexpression condition,
                  ITASTexpression body,
                  Type type) {
    super(condition, body);
    this.condition = condition;
    this.body = body;
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
  public ITASTexpression getCondition() { return condition; }

  @Override
  public ITASTexpression getBody() { return body; }


  @Override
	public <Result, Data, Anomaly extends Throwable> Result accept(
    com.paracamplus.ilp1.treecompiler.interfaces.ITASTvisitor<Result, Data, Anomaly> visitor,
    Data data) throws Anomaly {
    return  ((ITASTvisitor <Result, Data, Anomaly>) visitor).visit(this, data);
  }
}
