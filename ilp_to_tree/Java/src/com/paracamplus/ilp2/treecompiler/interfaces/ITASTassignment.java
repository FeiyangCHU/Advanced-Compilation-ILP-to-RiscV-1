package com.paracamplus.ilp2.treecompiler.interfaces;

import com.paracamplus.ilp2.interfaces.IASTassignment;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;

public interface ITASTassignment extends IASTassignment, ITASTexpression {

  @Override
  ITASTvariable getVariable();
  @Override
  ITASTexpression getExpression();

}
