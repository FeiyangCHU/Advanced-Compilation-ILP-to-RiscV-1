package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTprogram;

public interface ITASTprogram extends IASTprogram{
  @Override
	ITASTexpression getBody();
}
