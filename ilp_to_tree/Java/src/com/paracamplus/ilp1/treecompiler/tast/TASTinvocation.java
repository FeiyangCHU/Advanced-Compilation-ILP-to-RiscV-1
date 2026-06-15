package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.ast.ASTinvocation;
import com.paracamplus.ilp1.treecompiler.interfaces.*;

public class TASTinvocation extends ASTinvocation implements ITASTinvocation {

    private final ITASTexpression function;
    private final ITASTexpression[] arguments;
    private final Type type;

    public TASTinvocation(ITASTexpression function,
                          ITASTexpression[] arguments,
                          Type type) {
        super(function, arguments);
        this.function = function;
        this.arguments = arguments;
        this.type = type;
    }

    @Override
    public ITASTexpression getFunction() {
        return function;
    }

    @Override
    public ITASTexpression[] getArguments() {
        return arguments;
    }

    @Override
    public Type getType() {
        return type;
    }

    @Override
	public <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data)
            throws Anomaly {
    return visitor.visit(this, data);
  }

}
