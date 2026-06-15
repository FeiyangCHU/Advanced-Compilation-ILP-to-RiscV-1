package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTalternative;
import com.paracamplus.ilp1.annotation.OrNull;

  public interface ITASTalternative extends IASTalternative, ITASTexpression {

  @Override
  public ITASTexpression getCondition();

  @Override
  public ITASTexpression getConsequence();

  @Override @OrNull
  public ITASTexpression getAlternant();
}
