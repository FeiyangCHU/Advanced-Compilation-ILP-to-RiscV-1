package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTunaryOperation;

public interface ITASTunaryOperation extends ITASTexpression, IASTunaryOperation{
  @Override
	ITASTexpression getOperand();
}
