package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTinvocation;

public interface ITASTinvocation extends IASTinvocation, ITASTexpression {

    @Override
    public ITASTexpression getFunction();

    @Override
    public ITASTexpression[] getArguments();
}
