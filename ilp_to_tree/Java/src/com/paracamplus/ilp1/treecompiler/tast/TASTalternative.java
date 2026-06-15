package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTalternative;


public class TASTalternative extends ASTalternative implements ITASTalternative {
  private final ITASTexpression condition;
  private final ITASTexpression consequence;
  private final ITASTexpression alternant;
  private final Type type;

  public TASTalternative(ITASTexpression condition,
                         ITASTexpression consequence,
                         ITASTexpression alternant,
                         Type type) {
    super(condition, consequence, alternant);
    this.condition = condition;
    this.consequence = consequence;
    this.alternant = alternant;
    this.type = type;
  }

  @Override
  public Type getType() { return type; }

  @Override
  public ITASTexpression getCondition() { return condition; }

  @Override
  public ITASTexpression getConsequence() { return consequence; }

  @Override
  public ITASTexpression getAlternant() { return alternant; }


  @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
            throws Anomaly {
    return visitor.visit(this, data);
  }
}
