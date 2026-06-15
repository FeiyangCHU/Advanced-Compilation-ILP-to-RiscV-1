package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTexpression;
import com.paracamplus.ilp1.treecompiler.tast.Type;

public interface ITASTexpression extends IASTexpression, ITASTvisitable{
  public Type getType();
}
