package com.paracamplus.ilp1.treecompiler;

import java.util.*;

import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.interpreter.operator.Minus;
import com.paracamplus.ilp1.interpreter.operator.Negate;
import com.paracamplus.ilp1.compiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.tast.*;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.TypingException;

public class Typer implements IASTvisitor<ITASTexpression, Void, TypingException> {

  protected final IOperatorEnvironment operatorEnvironment;
  protected final IGlobalVariableEnvironment globalVariableEnvironment;

  protected final Deque<Map<String,ITASTvariable>> envStack;
  protected Map<String, Type> functionTypes=new HashMap<String, Type>();;


  public Typer(IOperatorEnvironment ioe, IGlobalVariableEnvironment igve) {
    this.operatorEnvironment = ioe;
    this.globalVariableEnvironment = igve;
    this.envStack = new ArrayDeque<>();
    enterScope();
    initBuiltins();
  }

  private void initBuiltins() {
    bindVariableAs("pi", new TASTvariable("pi", Type.FLOAT));
    functionTypes.put("print", Type.BOOL);
    functionTypes.put("type_of", Type.STRING);
    functionTypes.put("to_string", Type.STRING);
  }

  protected void enterScope() {
    envStack.push(new HashMap<>());
  }

  protected void leaveScope() {
    if (envStack.isEmpty())
      throw new IllegalStateException("Scope stack underflow");
    envStack.pop();
  }

  protected void bindVariableAs(String varName, ITASTvariable var) {
    envStack.peek().put(varName, var);
  }

  protected ITASTvariable lookupVariable(String varName) {
    for (Map<String,ITASTvariable> scope : envStack) {
      if (scope.containsKey(varName))
        return scope.get(varName);
    }
    return null;
  }

  protected void typeError(String msg) throws TypingException {
    throw new TypingException("Type error: " + msg);
  }

  public TASTprogram visit(IASTprogram iast) throws TypingException {
    ITASTexpression body = iast.getBody().accept(this, null);
    return new TASTprogram(body,body.getType());
  }

  @Override
  public ITASTexpression visit(IASTinteger iast, Void context) throws TypingException {
    return new TASTinteger(iast.getDescription(), Type.INT);
  }

  @Override
  public ITASTexpression visit(IASTboolean iast, Void context) throws TypingException {
    return new TASTboolean(iast.getDescription(), Type.BOOL);
  }

  @Override
  public ITASTexpression visit(IASTfloat iast, Void context) throws TypingException {
    return new TASTfloat(iast.getDescription(), Type.FLOAT);
  }

  @Override
  public ITASTexpression visit(IASTstring iast, Void context) throws TypingException {
    return new TASTstring(iast.getValue(), Type.STRING);
  }

  @Override
  public ITASTexpression visit(IASTvariable iast, Void context)
    throws TypingException {
	  
	  ITASTvariable v = lookupVariable(iast.getName());
	    if (v != null) {
	    	return v;
	    }
	    if (globalVariableEnvironment.contains(iast)) { 
	        Type t = globalVariableEnvironment.isPrimitive(iast) ? Type.FUNCTION : Type.PARAM;
	
	        return new TASTvariable(iast.getName(), t);
	      }

	      throw new TypingException("No such variable: " + iast.getName());
  }

  @Override
  public ITASTexpression visit(IASTunaryOperation iast, Void context) throws TypingException {
	  
	 try{
	  ITASTexpression operand = iast.getOperand().accept(this, context);
	    Type t = operand.getType();
      /*
      但项目里的约定是通过
  operatorEnvironment.getUnaryOperator(op)
  拿到字符串名（"ILP_Opposite"、"ILP_Not"），再 switch。 */
/*
      Mais la convention dans le projet est de récupérer le nom sous forme de chaîne
  ("ILP_Opposite", "ILP_Not") via
  operatorEnvironment.getUnaryOperator(op),
  puis de faire un switch.
 */

	    String op = operatorEnvironment.getUnaryOperator(iast.getOperator());

	    switch (op) {
	        case "ILP_Opposite":
	            if (!Type.isNumeric(t)) {
	                throw new TypingException("Unary '-' expects numeric, got " + t);
	            }
	            return new TASTunaryOperation(iast.getOperator(), operand, t);

	        case "ILP_Not":
	            return new TASTunaryOperation(iast.getOperator(), operand, Type.BOOL);

	        default:
	            throw new TypingException("Unknown unary operator: " + op);
	    }
  } catch (CompilationException e) {
      throw new TypingException(e);
    }
  }

  protected ITASTexpression
    typePlus(IASTbinaryOperation iast, ITASTexpression l, ITASTexpression r)
    throws TypingException {
	
	  IASToperator op = iast.getOperator();
	Type t1 = l.getType();
	Type t2 = r.getType();
	if(t1 == (Type.STRING) || t2 == (Type.STRING)) {
		return new TASTbinaryOperation(op, l, r, Type.STRING);
	}
	return typeNumeric(iast,op.getName(),l,r);
    
  }

  protected ITASTexpression typeNumeric(
    IASTbinaryOperation iast,
    String op,
    ITASTexpression l,
    ITASTexpression r) throws TypingException {
	Type t1 = l.getType();
	Type t2 = r.getType();
	if(!Type.isNumeric(t1) || !Type.isNumeric(t2) ) {
		throw new TypingException("operand not numeric");
	}
	if(t1 == Type.FLOAT || t2 == Type.FLOAT) {
		return new TASTbinaryOperation(iast.getOperator(), l, r, Type.FLOAT);
	}
	return new TASTbinaryOperation(iast.getOperator(), l, r, Type.INT);
  }

  protected ITASTexpression
    typeModulo(IASTbinaryOperation iast,
               ITASTexpression l,
               ITASTexpression r) throws TypingException {
	  Type t1 = l.getType();
		Type t2 = r.getType();
		if(!(t1 == Type.INT) || !(t2 == Type.INT)) {
			throw new TypingException("Modulo accepte que int");
		}
		return new TASTbinaryOperation(iast.getOperator(), l, r, Type.INT);
   
  }

  protected ITASTexpression typeAlwaysBool(
    IASTbinaryOperation iast,
    ITASTexpression l,
    ITASTexpression r) throws TypingException {
	 return new TASTbinaryOperation(iast.getOperator(), l, r, Type.BOOL);
   
  }

  protected ITASTexpression
    typeComparison(IASTbinaryOperation iast,
                   String op,
                   ITASTexpression l,
                   ITASTexpression r) throws TypingException {
	  Type t1 = l.getType();
		Type t2 = r.getType();
		if(! Type.isNumeric(t1) || !Type.isNumeric(t2) ) {
			if(t1 == Type.STRING && t2 == Type.STRING) {
				return new TASTbinaryOperation(iast.getOperator(), l, r, Type.BOOL);
			}
			throw new TypingException("typeComparision is not correct");
		}
		return new TASTbinaryOperation(iast.getOperator(), l, r, Type.BOOL);
		
   
  }

  @Override
  public ITASTexpression visit(IASTbinaryOperation iast, Void context)
    throws TypingException {

    try {
      ITASTexpression l = iast.getLeftOperand().accept(this, context);
      ITASTexpression r = iast.getRightOperand().accept(this, context);
      //这一行是干什么的?为什么不是直接getOperator?
      String op = operatorEnvironment.getBinaryOperator(iast.getOperator());

      switch (op) {
      case "ILP_Plus":
        return typePlus(iast, l, r);

      case "ILP_Times":
      case "ILP_Minus":
      case "ILP_Divide":
        return typeNumeric(iast, op, l, r);

      case "ILP_Modulo":
        return typeModulo(iast, l, r);

      case "ILP_GreaterThan":
      case "ILP_GreaterThanOrEqual":
      case "ILP_LessThan":
      case "ILP_LessThanOrEqual":
        return typeComparison(iast, op, l, r);

      case "ILP_And":
      case "ILP_Or":
      case "ILP_Xor":
      case "ILP_Equal":
      case "ILP_NotEqual":
        return typeAlwaysBool(iast, l, r);

      default:
        throw new TypingException("Binary operator " + op + " cannot be typed");
      }

    } catch (CompilationException e) {
      throw new TypingException(e);
    }
  }


  @Override
  public ITASTexpression visit(IASTsequence iast, Void context) throws TypingException {
	  IASTexpression[] exprs = iast.getExpressions();
	  if (exprs == null || exprs.length == 0) {
		  throw new TypingException("Empty sequence");
	  }
	  ITASTexpression[] texpressions = new ITASTexpression[exprs.length];
	  for (int i = 0; i < exprs.length; i++) {
		  texpressions[i] = exprs[i].accept(this, context);
	  }
	  ITASTexpression last = texpressions[exprs.length - 1];
	  return new TASTsequence(texpressions, last.getType());
  }
  //if then else
  @Override
  public ITASTexpression visit(IASTalternative iast, Void context) throws TypingException {
	  
	  Type resultType;
    //ITASTexpression可以获得类型,然后accept能够调用visit来自动变成对应的
    // ITASTexpression permet d’obtenir le type, puis accept peut appeler visit pour le transformer automatiquement en l’élément correspondant.
	    ITASTexpression cond = iast.getCondition().accept(this, context);
	    ITASTexpression consequence = iast.getConsequence().accept(this, context);
	    
	    if(iast.getAlternant() == null) {
	    	resultType = consequence.getType();
	    	return new TASTalternative(cond, consequence, null, resultType);
	    }
	    ITASTexpression alternative = iast.getAlternant().accept(this, context);
      //这里就是看else和then两边的类型是否相同,不同的话数值提升或者抛出错误
      // Ici, on vérifie si les types des branches else et then sont identiques ; sinon, on effectue une promotion numérique ou on lève une erreur.
	    	resultType = Type.unify(consequence.getType(), alternative.getType(),"Incompatible types in if branches");
	    
	   
	    return new TASTalternative(cond, consequence, alternative, resultType);
  }

  //这个要搞一下
  @Override
  public ITASTexpression visit(IASTblock iast, Void context) throws TypingException {
	      IASTblock.IASTbinding[] bindings = iast.getBindings();
	      ITASTvariable[] tvars = new ITASTvariable[bindings.length];
	      ITASTexpression[] tinits = new ITASTexpression[bindings.length];
        //求类型,创建带类型的变量
        // Déterminer le type et créer une variable typée.
	      for (int i = 0; i < bindings.length; i++) {
	          String name = bindings[i].getVariable().getName();
	          tinits[i] = bindings[i].getInitialisation().accept(this, context);
	          Type t = tinits[i].getType();
            //这里因为需要放进作用域让别人查找,所以需要新搞个节点,之前的不用,所以直接就表达式了
            // Ici, comme il faut l’ajouter à la portée pour que les autres puissent le rechercher,
// on doit créer un nouveau nœud. L’ancien n’est plus utilisé, donc on garde directement l’expression.
	          tvars[i] = new TASTvariable(name, t);
	      }
        //进入到新的作用域
	      enterScope();
	      try {
	          for (int i = 0; i < tvars.length; i++) {
                //注册进去
                //enregistre
	              bindVariableAs(tvars[i].getName(), tvars[i]);
	          }
            //getbody里面有lookup,在作用域栈里面找变量,返回带类型的body
	          ITASTexpression tbody = iast.getBody().accept(this, context);
	          ITASTblock.ITASTbinding[] tbindings = new ITASTblock.ITASTbinding[bindings.length];
	          for (int i = 0; i < bindings.length; i++) {
	              tbindings[i] = new TASTblock.TASTbinding(tvars[i], tinits[i]);
	          }
	          return new TASTblock(tbindings, tbody, tbody.getType());

	      } finally {
	          leaveScope();
	      }
	  }

  
  //param是当在fonction里面自己调用了自己,然后这样第一次遇到的时候是不知道类型的,所以可能会有问题,所以这时候返回的类型就是
  //param?所以这里要改吗
  

  @Override
  public ITASTexpression visit(IASTinvocation iast, Void context)
    throws TypingException {
	  /// 1) type function expression
	    ITASTexpression tf = iast.getFunction().accept(this, context);
	    if (!(tf instanceof ITASTvariable)) {
	        throw new TypingException("Invoked expression is not a function name");
	    }

	    String fname = ((ITASTvariable) tf).getName();

	    IASTexpression[] args = iast.getArguments();
	    ITASTexpression[] targs = new ITASTexpression[args.length];
	    for (int i = 0; i < args.length; i++) {
	        targs[i] = args[i].accept(this, context);
	    }

	    Type returnType = functionTypes.get(fname);
	    if (returnType == null) {
	        throw new TypingException("Unknown function: " + fname);
	    }

	    return new TASTinvocation(tf, targs, returnType);
  }
}
