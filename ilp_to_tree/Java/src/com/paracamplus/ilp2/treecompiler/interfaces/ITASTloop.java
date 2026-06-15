package com.paracamplus.ilp2.treecompiler.interfaces;

import com.paracamplus.ilp2.interfaces.IASTloop;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;

public interface ITASTloop extends IASTloop, ITASTexpression {

  @Override
  public ITASTexpression getCondition();

  @Override
  public ITASTexpression getBody();
}
