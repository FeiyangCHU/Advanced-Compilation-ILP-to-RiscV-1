package com.paracamplus.ilp2.treecompiler.interfaces;

import com.paracamplus.ilp2.treecompiler.interfaces.ITASTfunctionDefinition;

public interface ITASTprogram
  extends com.paracamplus.ilp1.treecompiler.interfaces.ITASTprogram{

  ITASTfunctionDefinition[] getFunctionDefinitions();
}
