package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.interfaces.IASTblock;

public interface ITASTblock extends IASTblock, ITASTexpression {

    /**
     * Typed nested binding interface.
     */
    interface ITASTbinding extends IASTblock.IASTbinding {
        @Override
        public ITASTvariable getVariable();

        @Override
        public ITASTexpression getInitialisation();
    }

    @Override
    public ITASTbinding[] getBindings();

    @Override
    public ITASTexpression getBody();
}
