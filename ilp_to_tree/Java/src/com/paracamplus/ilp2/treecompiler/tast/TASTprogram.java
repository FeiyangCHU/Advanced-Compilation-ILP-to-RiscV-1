package com.paracamplus.ilp2.treecompiler.tast;

import java.util.Arrays;
import java.util.List;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp2.ast.ASTprogram;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTprogram;
import com.paracamplus.ilp2.treecompiler.interfaces.ITASTfunctionDefinition;

public class TASTprogram extends ASTprogram implements ITASTprogram {
  private final Type type;
  private final ITASTexpression expression;
  protected List<ITASTfunctionDefinition> functions;

  public TASTprogram(ITASTfunctionDefinition[] functions, ITASTexpression expression, Type t) {
    super(functions, expression);
    this.functions = Arrays.asList(functions);
    this.expression = expression;
    type=t;
  }

  @Override
  public ITASTexpression getBody() {
    return this.expression;
  }

  public Type getType() {
    return this.type;
  }

  @Override
	public ITASTfunctionDefinition[] getFunctionDefinitions() {
    return functions.toArray(new ITASTfunctionDefinition[0]);
  }
}
