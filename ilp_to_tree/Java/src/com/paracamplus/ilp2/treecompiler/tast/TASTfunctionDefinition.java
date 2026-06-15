package com.paracamplus.ilp2.treecompiler.tast;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp2.ast.ASTfunctionDefinition;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTfunctionDefinition;

public class TASTfunctionDefinition extends ASTfunctionDefinition
implements ITASTfunctionDefinition
{

  public TASTfunctionDefinition(ITASTvariable functionVariable,
                                ITASTvariable[] variables,
                                ITASTexpression body ,
                                Type type){

    super(functionVariable, variables, body);
    this.functionVariable = functionVariable;
    this.variables = variables;
    this.body = body;
    this.type = type;
  }

  private final ITASTvariable functionVariable;
  private final ITASTvariable[] variables;
  private final ITASTexpression body;
  private Type type;

  @Override
	public ITASTvariable getFunctionVariable() {
    return functionVariable;
    }

  @Override
	public ITASTvariable[] getVariables() {
    return variables;
  }

  @Override
	public ITASTexpression getBody() {
    return body;
  }

	public Type getType() {
    return type;
  }

}
