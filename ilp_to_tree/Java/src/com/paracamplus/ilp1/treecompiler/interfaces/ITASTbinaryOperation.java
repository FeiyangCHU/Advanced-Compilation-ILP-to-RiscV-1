package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTbinaryOperation;

public interface ITASTbinaryOperation extends ITASTexpression, IASTbinaryOperation{
  @Override
	ITASTexpression getLeftOperand();
  @Override
	ITASTexpression getRightOperand();
}
