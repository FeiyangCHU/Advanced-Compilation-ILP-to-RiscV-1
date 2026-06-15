package com.paracamplus.ilp1.treecompiler;

import com.paracamplus.ilp1.ast.ASToperator;
import com.paracamplus.ilp1.compiler.interfaces.*;
import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.interfaces.ITASTblock.ITASTbinding;
import com.paracamplus.ilp1.treecompiler.tast.*;
import com.paracamplus.ilp1.treecompiler.tast.TASTblock.TASTbinding;

import java.util.ArrayList;
import java.util.List;

public class Resolver implements ITASTvisitor<ITASTexpression, Void, ResolutionException> {

  protected final IOperatorEnvironment operatorEnvironment;
  protected final IGlobalVariableEnvironment globalVariableEnvironment;

  public Resolver(IOperatorEnvironment ioe, IGlobalVariableEnvironment igve) {
    this.operatorEnvironment = ioe;
    this.globalVariableEnvironment = igve;
  }

  public TASTprogram resolve(TASTprogram program) throws ResolutionException {
    ITASTexpression newBody = program.getBody().accept(this, null);
    return new TASTprogram(newBody, newBody.getType());
  }

  private TASTstring trueString = new TASTstring("true",Type.STRING);
  private TASTstring falseString = new TASTstring("false",Type.STRING);

  private ITASTexpression unaryInvocation(String name, ITASTexpression arg, Type retType) {
    TASTvariable fn = new TASTvariable(name, retType);
    ITASTexpression[] args = new ITASTexpression[]{ arg };
    return new TASTinvocation(fn, args, retType);
  }

  private ITASTexpression
    binaryCast(String name,
               ITASTexpression l, Type lt,
               ITASTexpression r, Type rt,
               Type returnType) {
    ITASTexpression lcast = castIfNeeded(l, lt);
    ITASTexpression rcast = castIfNeeded(r, rt);
    return new TASTbinaryOperation(new ASToperator(name),lcast,rcast,returnType);
  }

  /**
     Wraps a typed expression `expr` into an invocation that converts it to target type.
     If no conversion is needed (from == to), returns the original expr.
  */
  private ITASTexpression castIfNeeded(ITASTexpression expr, Type to) {
    Type from = expr.getType();
    if (from == to) return expr;

    String fnName = null;
    if (to == Type.STRING) {
      if (from == Type.INT) fnName = "string_of_int";
      else if (from == Type.FLOAT) fnName = "string_of_float";
      else if (from == Type.BOOL)
        return new TASTalternative(expr,trueString,falseString,Type.STRING);
    } else if (to == Type.FLOAT) {
      if (from == Type.INT) fnName = "float_of_int";
      else if (from == Type.STRING) fnName = "float_of_string";
    } else if (to == Type.INT) {
      if (from == Type.FLOAT) fnName = "int_of_float";
      else if (from == Type.STRING) fnName = "int_of_string";
    } else if (to == Type.BOOL) {
      ITASTexpression[] arr = new ITASTexpression[2];
      arr[0] = expr;
      arr[1] = new TASTboolean("true", Type.BOOL);
      return new TASTsequence(arr,Type.BOOL);
    }
    if (fnName == null) return expr;
    ITASTvariable fnVar = new TASTvariable(fnName, Type.FUNCTION);
    return new TASTinvocation(fnVar, new ITASTexpression[]{expr}, to);
  }

  @Override
  public ITASTexpression visit(ITASTboolean iast, Void data) throws ResolutionException {
    return iast;
  }

  @Override
  public ITASTexpression visit(ITASTinteger iast, Void data) throws ResolutionException {
    return iast;
  }

  @Override
  public ITASTexpression visit(ITASTfloat iast, Void data) throws ResolutionException {
    return iast;
  }

  @Override
  public ITASTexpression visit(ITASTstring iast, Void data) throws ResolutionException {
    return iast;
  }

  @Override
  public ITASTexpression visit(ITASTvariable iast, Void data) throws ResolutionException {
    if (iast.getName().equals("pi")) return new TASTfloat("3.1415926535",Type.FLOAT);
    return iast;
  }

  @Override
  public ITASTexpression visit(ITASTunaryOperation iast, Void data) throws ResolutionException {
    try {
      ITASTexpression operand = iast.getOperand().accept(this, data);
      String op = operatorEnvironment.getUnaryOperator(iast.getOperator());
      Type opt = operand.getType();

      Type returnType;
      ASToperator opresolved;
      if ("ILP_Opposite".equals(op)){
        if (opt == Type.INT) opresolved = new ASToperator(op+"_INT");
        else if (opt == Type.FLOAT) opresolved = new ASToperator(op+"_FLOAT");
        else throw new ResolutionException("ILP_Opposite with bad type: "+opt);
        return new TASTunaryOperation(opresolved, operand,opt);
      } else if ("ILP_Not".equals(op)){
        if (opt == Type.BOOL) opresolved = new ASToperator(op);
        else return new TASTboolean("false", Type.BOOL);
        return new TASTunaryOperation(opresolved, operand,opt);
      }
      throw new ResolutionException("operator "+op+" cannot be resolved");
    } catch (CompilationException e) {
      throw new ResolutionException(e);
    }
  }

  public ITASTexpression resolvePlus(ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
	  Type lt = l.getType();
	  Type rt = r.getType();
	  //if one is string we turns into concatenation
	  if (lt == Type.STRING || rt == Type.STRING) {
	    return binaryCast("ILP_Concat", l, Type.STRING, r, Type.STRING, Type.STRING);
	  }
	  if (Type.isNumeric(lt) && Type.isNumeric(rt)) {
	    if (lt == Type.FLOAT || rt == Type.FLOAT) {
	      return binaryCast("ILP_Plus_FLOAT", l, Type.FLOAT, r, Type.FLOAT, Type.FLOAT);
	    } else {
	        return binaryCast("ILP_Plus_INT", l, Type.INT, r, Type.INT, Type.INT);
	    }
	  }

	  throw new ResolutionException("ILP_Plus cannot be resolved for types: " + lt + " + " + rt);
  }

  // Numeric arithmetic (+ - * / except plus special-cased)
  private ITASTexpression resolveNumeric(String op, ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
    Type lt=l.getType();
    Type rt=r.getType();


    //Ensurer que l est r sont tous numeric
    if (!Type.isNumeric(lt) || !Type.isNumeric(rt)) {
      throw new ResolutionException("Numeric operator " + op + " requires numeric operands, got " + lt + " and " + rt);
    }

    //Logic general:priorite:float>int
    if (lt == Type.FLOAT || rt == Type.FLOAT) {
      //On utilise binaryCast pour realiser la conversion implicite:int->float
      return binaryCast(op + "_FLOAT", l, Type.FLOAT, r, Type.FLOAT, Type.FLOAT);
    }
    else {
      return binaryCast(op + "_INT", l, Type.INT, r, Type.INT, Type.INT);
    }
  }

  private ITASTexpression resolveEquality(String op, ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
    Type lt=l.getType();
    Type rt=r.getType();

    //Logic general:Vérifier d'abord si les types sont identiques, puis vérifier si les contenus sont identiques
    if (Type.isNumeric(lt) && Type.isNumeric(rt)) {
      if (lt == Type.FLOAT || rt == Type.FLOAT) {
        return binaryCast(op + "_FLOAT", l, Type.FLOAT, r, Type.FLOAT, Type.BOOL);
      } else {
        return binaryCast(op + "_INT", l, Type.INT, r, Type.INT, Type.BOOL);
      }
    }

    if (lt == rt) {
      return binaryCast(op + "_" + lt, l, lt, r, rt, Type.BOOL);
    }

    //Side effects:Si les type sont pas identiques, alors on le passer a traiter comme (e1;e2;false)
    //Verifier op est == ou !=;Retourne false si == et true sinon
    boolean resultValue = op.equals("ILP_Equal") ? false : true;

    ITASTexpression[] sequence = new ITASTexpression[] {
      l,
      r,
      new TASTboolean(String.valueOf(resultValue), Type.BOOL)
    };
    
    return new TASTsequence(sequence, Type.BOOL);
  }


  // Comparisons (< <= > >=)
  private ITASTexpression resolveComparison(String op, ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
    Type lt = l.getType();
    Type rt = r.getType();

    if (Type.isNumeric(lt) && Type.isNumeric(rt)) {
        if (lt == Type.FLOAT || rt == Type.FLOAT) {
            return binaryCast(op + "_FLOAT", l, Type.FLOAT, r, Type.FLOAT, Type.BOOL);
        } else {
            return binaryCast(op + "_INT", l, Type.INT, r, Type.INT, Type.BOOL);
        }
    }

    if (lt == Type.STRING && rt == Type.STRING) {
        return binaryCast(op + "_STRING", l, Type.STRING, r, Type.STRING, Type.BOOL);
    }
    //Side effects
    ITASTexpression[] sequence = new ITASTexpression[] {
      l,
      r,
      new TASTboolean(String.valueOf(false), Type.BOOL)
    };
    
    return new TASTsequence(sequence, Type.BOOL);
  }

  // Logical operators: and / or / xor
  private ITASTexpression resolveBoolean(String op, ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
    return binaryCast(op, l, Type.BOOL, r, Type.BOOL, Type.BOOL);
  }

  // modulo
  private ITASTexpression resolveModulo(ITASTexpression l, ITASTexpression r)
    throws ResolutionException {
    return binaryCast("ILP_Modulo", l, Type.INT, r, Type.INT, Type.INT);
  }

  @Override
  public ITASTexpression visit(ITASTbinaryOperation iast, Void data)
    throws ResolutionException {

    try {
      ITASTexpression l = iast.getLeftOperand().accept(this, data);
      ITASTexpression r = iast.getRightOperand().accept(this, data);
      String op = operatorEnvironment.getBinaryOperator(iast.getOperator());

      switch (op) {
      case "ILP_Plus":
        return resolvePlus(l, r);

      case "ILP_Times":
      case "ILP_Minus":
      case "ILP_Divide":
        return resolveNumeric(op, l, r);

      case "ILP_Equal":
      case "ILP_NotEqual":
        return resolveEquality(op, l, r);

      case "ILP_GreaterThan":
      case "ILP_GreaterThanOrEqual":
      case "ILP_LessThan":
      case "ILP_LessThanOrEqual":
        return resolveComparison(op, l, r);

      case "ILP_And":
      case "ILP_Or":
      case "ILP_Xor":
        return resolveBoolean(op, l, r);

      case "ILP_Modulo":
        return resolveModulo(l, r);

      default:
        throw new ResolutionException(op + " operator cannot be resolved");
      }

    } catch (CompilationException e) {
      throw new ResolutionException(e);
    }
  }

  @Override
  public ITASTexpression visit(ITASTsequence iast, Void data) throws ResolutionException {
    ITASTexpression[] exprs = iast.getExpressions();
    if (exprs == null) return iast;
    List<ITASTexpression> out = new ArrayList<>(exprs.length);
    for (ITASTexpression e : exprs) {
      out.add(e.accept(this, data));
    }
    ITASTexpression[] arr = out.toArray(new ITASTexpression[0]);
    return new TASTsequence(arr, iast.getType());
  }

  @Override
  public ITASTexpression visit(ITASTalternative iast, Void data) throws ResolutionException {
    ITASTexpression condition   = iast.getCondition().accept(this, data);
    ITASTexpression consequence = iast.getConsequence().accept(this, data);
    ITASTexpression alternant   = iast.getAlternant() != null
                                  ? iast.getAlternant().accept(this, data) : null;
    if (condition.getType() != Type.BOOL) {
      condition = castIfNeeded(condition, Type.BOOL);
    }
    return new TASTalternative(condition, consequence, alternant, consequence.getType());

  }

  @Override
  public ITASTexpression visit(ITASTblock iast, Void data) throws ResolutionException {
    ITASTbinding[] bs = iast.getBindings();
    ITASTbinding[] rbs = new ITASTbinding[bs.length];

    for (int i = 0; i < bs.length; i++) {
      ITASTbinding b = bs[i];

    ITASTvariable v = b.getVariable();

    ITASTexpression init = b.getInitialisation().accept(this, data);

    rbs[i] = new TASTbinding(v, init);
    }

    ITASTexpression body = iast.getBody().accept(this, data);

    return new TASTblock(rbs, body, body.getType());

  }

  private ITASTexpression resolveToString(ITASTexpression arg)
    throws ResolutionException {
    Type t = arg.getType();

    if (t == Type.STRING) {
        return arg;
    }

    String fnName;

    if (t == Type.INT) {
        fnName = "string_of_int";
    } else if (t == Type.FLOAT) {
        fnName = "string_of_float";
    } else if (t == Type.BOOL) {
        fnName = "string_of_bool";
    } else {
        throw new ResolutionException("Cannot convert type " + t + " to string");
    }

    TASTvariable fnVar = new TASTvariable(fnName, Type.FUNCTION);
    ITASTexpression[] args = new ITASTexpression[] { arg };
    
    return new TASTinvocation(fnVar, args, Type.STRING);
  }

  private ITASTexpression resolveTypeOf(ITASTexpression iast) throws ResolutionException {
    Type t = iast.getType();
    String typeName;

    if (t == Type.INT)    typeName = "INT";
    else if (t == Type.FLOAT) typeName = "FLOAT";
    else if (t == Type.BOOL)  typeName = "BOOL";
    else if (t == Type.STRING) typeName = "STRING";
    else if (t == Type.FUNCTION) typeName = "FUNCTION";
    else throw new ResolutionException("Unknown type for type_of primitive: " + t);

    TASTstring resultNode = new TASTstring(typeName, Type.STRING);
    if (iast instanceof ITASTvariable) {
      return resultNode;
    }
    return new TASTsequence(
        new ITASTexpression[] {
            iast,
            resultNode
        },
        Type.STRING
    );
  }

  private ITASTexpression resolvePrint(ITASTinvocation iast) throws ResolutionException {
    ITASTexpression[] args = resolveArguments(iast, null); 
    if (args.length != 1) {
        throw new ResolutionException("Print expects exactly one argument");
    }
    ITASTexpression arg = args[0];
    //Conversion explicite de type a string
    ITASTexpression stringArg = resolveToString(arg);
    //Retourne bool ar defaut
    TASTvariable printFn = new TASTvariable("print", Type.BOOL);
    ITASTexpression[] newArgs = new ITASTexpression[] { stringArg };

    return new TASTinvocation(printFn, newArgs, Type.BOOL);
  }

  private ITASTexpression[] resolveArguments(ITASTinvocation iast, Void data)
    throws ResolutionException {
    ITASTexpression[] raw = iast.getArguments();
    ITASTexpression[] targs = new ITASTexpression[raw.length];
    for (int i = 0; i < raw.length; i++) {
      targs[i] = raw[i].accept(this, data);
    }
    return targs;
  }

  @Override
  public ITASTexpression visit(ITASTinvocation iast, Void data)
    throws ResolutionException {
    // function must be a variable
    ITASTexpression func = iast.getFunction();
    if (!(func instanceof ITASTvariable))
      throw new ResolutionException("Only named functions can be invoked");
    String fname = ((ITASTvariable) func).getName();
    ITASTexpression[] targs = resolveArguments(iast, data);

    // primitives handled specially
    if ("type_of".equals(fname)) return resolveTypeOf(targs[0]);
    if ("to_string".equals(fname)) return resolveToString(targs[0]);
    if ("print".equals(fname)) return resolvePrint(iast);
    throw new ResolutionException("function " + fname + " not a primitive");
  }
}
