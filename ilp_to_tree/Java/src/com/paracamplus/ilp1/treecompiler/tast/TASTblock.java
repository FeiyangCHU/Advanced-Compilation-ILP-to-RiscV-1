package com.paracamplus.ilp1.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.ast.ASTblock;
import com.paracamplus.ilp1.ast.ASTblock.ASTbinding;

public class TASTblock extends ASTblock implements ITASTblock {

    public static class TASTbinding extends ASTbinding implements ITASTblock.ITASTbinding {
        private final ITASTvariable variable;
        private final ITASTexpression initialisation;

        public TASTbinding(ITASTvariable variable, ITASTexpression initialisation) {
          super (variable,initialisation);
          this.variable = variable;
          this.initialisation = initialisation;
        }

        @Override
        public ITASTvariable getVariable() {
            return variable;
        }

        @Override
        public ITASTexpression getInitialisation() {
            return initialisation;
        }
    }

    private final ITASTblock.ITASTbinding[] binding;
    private final ITASTexpression body;
    private final Type type;

    public TASTblock(ITASTblock.ITASTbinding[] binding, ITASTexpression body, Type type) {
        super(binding, body);
        this.binding = binding;
        this.body = body;
        this.type = type;
    }

    @Override
    public ITASTblock.ITASTbinding[] getBindings() {
        return binding;
    }

    @Override
    public ITASTexpression getBody() {
        return body;
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
