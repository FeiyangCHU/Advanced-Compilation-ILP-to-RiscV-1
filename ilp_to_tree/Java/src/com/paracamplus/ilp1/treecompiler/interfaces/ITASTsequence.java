package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTsequence;

public interface ITASTsequence extends IASTsequence, ITASTexpression {
    @Override
    public ITASTexpression[] getExpressions();
}
