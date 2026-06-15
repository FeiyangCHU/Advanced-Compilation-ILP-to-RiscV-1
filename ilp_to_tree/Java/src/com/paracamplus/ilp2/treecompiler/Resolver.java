package com.paracamplus.ilp2.treecompiler;

import com.paracamplus.ilp1.compiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.ResolutionException;
import com.paracamplus.ilp1.treecompiler.tast.TASTvariable;
import com.paracamplus.ilp1.treecompiler.tast.TASTinvocation;
import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTexpression;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTvariable;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTinvocation;
import com.paracamplus.ilp2.treecompiler.tast.*;
import com.paracamplus.ilp2.treecompiler.interfaces.*;

import java.util.*;

public class Resolver extends com.paracamplus.ilp1.treecompiler.Resolver
  implements ITASTvisitor<ITASTexpression, Void, ResolutionException> {

  public Resolver(IOperatorEnvironment ioe, IGlobalVariableEnvironment igve) {
    super(ioe,igve);
  }

  // Map from function name to its (possibly unresolved) definition
  protected Map<String, ITASTfunctionDefinition> funs;

  public void fillFunctionDeclarations(ITASTfunctionDefinition[] orig) throws ResolutionException{
    // First pass: register function signatures
    // Only names, parameters, and declared types are recorded.
    // Function bodies are NOT resolved yet.
    for (ITASTfunctionDefinition f : orig) {
      ITASTfunctionDefinition header =
        new TASTfunctionDefinition(f.getFunctionVariable(),
                                   f.getVariables(),
                                   f.getBody(),   // body left untouched for now
                                   f.getType());
      funs.put(f.getFunctionVariable().getName(), header);
    }
    // Second pass: resolve function bodies
    // All functions are now known, so calls can be resolved safely.
    for (ITASTfunctionDefinition f : orig) {
      ITASTexpression body = f.getBody().accept(this, null);
      ITASTfunctionDefinition resolved =
        new TASTfunctionDefinition(f.getFunctionVariable(),
                                   f.getVariables(),
                                   body,
                                   f.getType());
      funs.put(f.getFunctionVariable().getName(), resolved);
    }
  }

  public TASTprogram resolve(ITASTprogram iast) throws ResolutionException {
    ITASTfunctionDefinition[] orig = iast.getFunctionDefinitions();
    funs = new HashMap<>();
    fillFunctionDeclarations(orig);
    // Resolve the main program body
    ITASTexpression newBody = iast.getBody().accept(this, null);
    return new TASTprogram(
                           funs.values().toArray(new ITASTfunctionDefinition[0]),
                           newBody,
                           newBody.getType()
                           );
  }

  @Override
  public ITASTexpression visit(ITASTloop iast, Void context) throws ResolutionException {
    ITASTexpression condT = iast.getCondition().accept(this, context);
    ITASTexpression bodyT = iast.getBody().accept(this, context);
    return new TASTloop(condT, bodyT, Type.BOOL);
  }

  @Override
  public ITASTexpression visit(ITASTassignment iast, Void context) throws ResolutionException {
    ITASTexpression exprT = iast.getExpression().accept(this, context);
    String varname = iast.getVariable().getName();
    ITASTvariable varT = new TASTvariable(varname,exprT.getType());
    return new TASTassignment(varT, exprT, exprT.getType());
  }

  @Override
  public ITASTexpression visit(ITASTinvocation iast, Void context)
    throws ResolutionException {
    // The function expression must be a variable
    ITASTexpression func = iast.getFunction();
    if (!(func instanceof ITASTvariable))
      throw new ResolutionException("Only named functions can be invoked");
    String fname = ((ITASTvariable) func).getName();
    if (!funs.containsKey(fname)){
      // primitive function (handled in ILP1)
      return super.visit(iast, context);
    }
    // Resolve arguments
    ITASTexpression[] rargs =
      new ITASTexpression[iast.getArguments().length];
    for (int i = 0; i < rargs.length; i++) {
      rargs[i] = iast.getArguments()[i].accept(this, context);
    }
    // Rebuild the invocation
    return new TASTinvocation(func, rargs, iast.getType());
  }

}
