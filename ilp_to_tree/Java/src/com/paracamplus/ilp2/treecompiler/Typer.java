package com.paracamplus.ilp2.treecompiler;

import java.util.*;

import com.paracamplus.ilp1.compiler.interfaces.IOperatorEnvironment;
import com.paracamplus.ilp1.compiler.interfaces.IGlobalVariableEnvironment;
import com.paracamplus.ilp1.interfaces.IASTexpression;
import com.paracamplus.ilp1.interfaces.IASTinvocation;
import com.paracamplus.ilp1.interfaces.IASTvariable;
import com.paracamplus.ilp2.interfaces.IASTprogram;
import com.paracamplus.ilp2.interfaces.IASTassignment;
import com.paracamplus.ilp2.interfaces.IASTloop;
import com.paracamplus.ilp2.interfaces.IASTfunctionDefinition;
import com.paracamplus.ilp2.interfaces.IASTvisitor;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.treecompiler.tast.TASTvariable;
import com.paracamplus.ilp1.treecompiler.tast.TASTinvocation;
import com.paracamplus.ilp1.treecompiler.TypingException;
import com.paracamplus.ilp2.treecompiler.tast.*;
import com.paracamplus.ilp2.treecompiler.interfaces.*;


public class Typer extends com.paracamplus.ilp1.treecompiler.Typer
  implements IASTvisitor<ITASTexpression, Void, TypingException> {

  public Typer(IOperatorEnvironment ioe, IGlobalVariableEnvironment igve) {
    super(ioe,igve);
  }

  public TASTprogram visit(IASTprogram iast) throws TypingException {
    TASTprogram p = visit(iast,null);
    return p;
  }

  final class FunctionKey {
    final String name;
    final List<Type> argTypes;

    FunctionKey(String name,  List<Type> argTypes){
      this.name = name;
      this.argTypes=argTypes;
    }

    @Override
    public boolean equals(Object o) {
      if (!(o instanceof FunctionKey)) return false;
      FunctionKey k = (FunctionKey) o;
      return name.equals(k.name) && argTypes.equals(k.argTypes);
    }

    @Override
    public int hashCode() {
      return Objects.hash(name, argTypes);
    }

    @Override
    public String toString() {
      StringBuilder sb = new StringBuilder();
      sb.append(name).append("(");
      for (int i = 0; i < argTypes.size(); i++) {
        sb.append(argTypes.get(i));
        if (i < argTypes.size() - 1) sb.append(", ");
      }
      sb.append(")");
      return sb.toString();
    }
  }

  // function defintions are stored as is and will be typed upon invocation
  private final Map<String, IASTfunctionDefinition> functions = new HashMap<>();
  protected Map<FunctionKey, TASTfunctionDefinition> specializations = new HashMap<>();
  protected Map<FunctionKey, Type> specializedReturnTypes = new HashMap<>();
  //是为了在推断中防止(Fact = fact(n-1))的一直推断的情况,所以加一个这个来防
  private final Set<FunctionKey> inProgress = new HashSet<>();

  public void printDebugInfo() {
    System.out.println("=== Functions ===");
    for (Map.Entry<String, IASTfunctionDefinition> entry : functions.entrySet()) {
      String name = entry.getKey();
      IASTfunctionDefinition fdef = entry.getValue();
      System.out.println("Function: " + name + ", params: " +
                         Arrays.toString(fdef.getVariables()));
    }

    System.out.println("\n=== Specializations ===");
    for (Map.Entry<FunctionKey, TASTfunctionDefinition> entry : specializations.entrySet()) {
      FunctionKey key = entry.getKey();
      TASTfunctionDefinition spec = entry.getValue();
      System.out.println("Specialization: " + key.name + key.argTypes +
                         " -> mangled: " + spec.getName());
    }

    System.out.println("\n=== Specialized Return Types ===");
    for (Map.Entry<FunctionKey, Type> entry : specializedReturnTypes.entrySet()) {
      FunctionKey key = entry.getKey();
      Type retType = entry.getValue();
      System.out.println("Return type for " + key.name + key.argTypes + " -> " + retType);
    }
  }


  private String mangle(String name, Type[] types) {
    StringBuilder sb = new StringBuilder(name);
    for (Type t : types) {
      sb.append("__").append(t.name().toLowerCase());
    }
    return sb.toString();
  }

  public TASTprogram visit(IASTprogram iast, Void context) throws TypingException {
    IASTfunctionDefinition[] fundefs = iast.getFunctionDefinitions();
    for (int i = 0; i < fundefs.length; i++) {
      visit(fundefs[i], context);
    }
    ITASTfunctionDefinition[] typedFun = new ITASTfunctionDefinition[fundefs.length];
    ITASTexpression body = iast.getBody().accept(this, context);
    Collection<TASTfunctionDefinition> defs = specializations.values();
    ITASTfunctionDefinition[] defArray = defs.toArray(new ITASTfunctionDefinition[0]);
    return new TASTprogram(defArray,body,body.getType());
  }

  // function defintions are stored as is and will be typed upon invocation
  public void visit(IASTfunctionDefinition iast, Void context)
    throws TypingException {
    functions.put(iast.getName(), iast);
    functionTypes.put(iast.getName(),Type.PARAM);
  }

  //这里是为了用户自定义函数
  @Override
  public ITASTexpression visit(IASTvariable iast, Void context)
    throws TypingException {
    if (functions.containsKey(iast.getName())) {
      return new TASTvariable(iast.getName(), Type.FUNCTION);
    }
    return super.visit(iast, context);
  }


  /**
   * Type-check and specialize the body of a function for a given specialization key.
   *
   * This method is called once a function signature (name + argument types)
   * has already been selected. Its role is to:
   *
   *  1) Create a new local scope for the function body
   *  2) Bind each formal parameter to a typed variable
   *  3) Type-check the function body in this environment
   *  4) Record the resulting return type
   *  5) Build the specialized function definition
   *
   * Important:
   * - This method must NOT try to infer argument types.
   *   They are already provided by the FunctionKey.
   * - The function body may contain calls to other functions,
   *   including recursive or mutually recursive ones.
   */
  private void typeFunctionBody(IASTfunctionDefinition fdef, FunctionKey key)
    throws TypingException {

    inProgress.add(key);
    // Stackframe
    this.enterScope();

    try {
        IASTvariable[] params = fdef.getVariables();
        List<Type> argTypes = key.argTypes;
        
        if (params.length != argTypes.size()) {
            throw new TypingException("函数 " + key.name + " 参数数量不匹配");
        }

        ITASTvariable[] tparams = new ITASTvariable[params.length];
        for (int i = 0; i < params.length; i++) {
            tparams[i] = new TASTvariable(params[i].getName(), argTypes.get(i));
            bindVariableAs(params[i].getName(), tparams[i]);
        }
        //Vérification récursive des types
        ITASTexpression typedBody = fdef.getBody().accept(this, null);
        Type returnType = typedBody.getType();

        //specialized function definition
        String mangledName = mangle(key.name, argTypes.toArray(new Type[0]));

        ITASTvariable funcVar = new TASTvariable(mangledName, returnType);
        TASTfunctionDefinition tdef = new TASTfunctionDefinition(funcVar, tparams, typedBody, returnType);
        
        if (specializations != null) {
            specializations.put(key, tdef);
        }
        //某个函数在某组参数类型下,返回什么类型的表->specializedReturnTypes,查这个表,然后Type returnType = specializedReturnTypes.get(key);,return new TASTinvocation(tf, targs, returnType);
        //多态,不同参数不同返回结果类型
        specializedReturnTypes.put(key, returnType);

    } finally {
        inProgress.remove(key);
        this.leaveScope();
    }
  }

  @Override
  public ITASTexpression visit(IASTinvocation iast, Void context)
    throws TypingException {

    IASTexpression rawFunction = iast.getFunction();
    if (!(rawFunction instanceof IASTvariable)) {
        return super.visit(iast, context);
    }
    String fname = ((IASTvariable) rawFunction).getName();

    //S'il s'agit d'une fonction intégrée
    if (functions == null || !functions.containsKey(fname)) {
        return super.visit(iast, context); 
    }
    //S'il s'agit d'une fonction définie par l'utilisateur
    IASTexpression[] args = iast.getArguments();
    ITASTexpression[] targs = new ITASTexpression[args.length];
    List<Type> argTypes = new ArrayList<>();

    for (int i = 0; i < args.length; i++) {
        targs[i] = args[i].accept(this, context);
        argTypes.add(targs[i].getType());
    }
    //FunctionKey
    FunctionKey key = new FunctionKey(fname, argTypes);
    String mangledName = mangle(fname, argTypes.toArray(new Type[0]));
    ITASTexpression tf = new TASTvariable(mangledName, Type.FUNCTION);

    if (!specializations.containsKey(key)) {
        if (inProgress.contains(key)) {
            Type provisional = specializedReturnTypes.getOrDefault(key, Type.PARAM);
            //直接返回PARAM,对于没法判断类型的fact(n-1)
            return new TASTinvocation(tf, targs, provisional);
        }
        IASTfunctionDefinition fdef = functions.get(fname);
        //这里现场推断函数体,然后存进specilaization和specializedReturnTypes
        typeFunctionBody(fdef, key);
    }

    Type returnType = specializedReturnTypes.get(key);

    return new TASTinvocation(tf, targs, returnType);
  }

  @Override
  public ITASTexpression visit(IASTloop iast, Void context) throws TypingException {
    //Verifier la condition est en type bool
    ITASTexpression tcond = iast.getCondition().accept(this, context);
    if (tcond.getType() != Type.BOOL) {
        throw new TypingException("Loop condition must be of type BOOL, but got " + tcond.getType());
    }

    //Stakcframe
    this.enterScope();
    ITASTexpression tbody;
    try {
        tbody = iast.getBody().accept(this, context);
    } finally {
        this.leaveScope();
    }


    return new TASTloop(tcond, tbody, tbody.getType());
  }

  @Override
  public ITASTexpression visit(IASTassignment iast, Void context) throws TypingException {
    ITASTexpression texpr = iast.getExpression().accept(this, context);
    Type exprType = texpr.getType();

    String varName = iast.getVariable().getName();
    ITASTvariable tvar = lookupVariable(varName);

    if (tvar == null) {
      //这里是如果没有这个变量,那么就在全局给他创一个
        tvar = new TASTvariable(varName, exprType);
        bindVariableAs(varName, tvar);
    }

    Type.unify(tvar.getType(), exprType,"Assignment type mismatch: variable " + varName + " is " + tvar.getType() + ", but tried to assign " + exprType);

    return new TASTassignment(tvar, texpr, exprType);
  }
}
