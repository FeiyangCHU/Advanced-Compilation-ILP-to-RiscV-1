package com.paracamplus.ilp2.treecompiler.interfaces;

import com.paracamplus.ilp2.interfaces.IASTfunctionDefinition;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp1.treecompiler.tast.Type;

public interface ITASTfunctionDefinition extends IASTfunctionDefinition {
    ITASTvariable getFunctionVariable();
	ITASTvariable[] getVariables();
	ITASTexpression getBody();
  Type getType();
}
