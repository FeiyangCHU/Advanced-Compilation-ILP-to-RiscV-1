package com.paracamplus.ilp1.treecompiler;

import java.io.*;
import java.util.*;


import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.interfaces.*;
import com.paracamplus.ilp1.treecompiler.interfaces.*;
import com.paracamplus.ilp1.treecompiler.tast.*;

public class CompilerTree implements ITASTvisitor<Void, Void, CompilationException>{

  protected Writer out;

  public CompilerTree () {
    this.labelCounter = 1;
    this.tempCounter = 1;
    this.envStack = new ArrayDeque<>();
    enterScope();
    strCollect= new StringCollector();
  }

  protected StringCollector strCollect;

  private long labelCounter;
  private long tempCounter;

  //Produce a fresh label name (e.g. L0, L1, ...)
  protected String newLabel() {
    long n = labelCounter++;
    return "L" + n;
  }

  // Produce a fresh temporary name (e.g. t0, t1, ...)
  protected String newTemp() {
    long n = tempCounter++;
    return "t" + n;
  }

  // Produce a fresh temporary name (e.g. t0, t1, ...)
  protected String newFloatTemp() {
    long n = tempCounter++;
    return "f" + n;
  }

  // ---------- Scoped environment mapping variable name -> temp name ----------
  // We use a stack of maps so we can enter/leave scopes easily.
  protected final Deque<Map<String,String>> envStack;

  protected void enterScope() {
    envStack.push(new HashMap<String,String>());
  }

  protected void leaveScope() {
    if (envStack.isEmpty()) throw new IllegalStateException("Scope stack underflow");
    envStack.pop();
  }

  /**
   * Bind a variable name in the current scope to a fresh temporary and
   * return that temporary name. If the variable already exists in the
   * current scope, it will be shadowed by the new temp.
   */
  protected String bindFloatVariable(String varName) {
    String temp = newFloatTemp();
    envStack.peek().put(varName, temp);
    return temp;
  }


  // Lookup a variable name searching from innermost scope outwards.
  // Returns the temp name or null if not found.
  protected String lookupVariable(String varName) {
    for (Map<String,String> scope : envStack) {
      if (scope.containsKey(varName)) return scope.get(varName);
    }
    return null;
  }

  private int indentlevel = 0;

  protected void indent(){indentlevel++;}
  protected void dedent(){indentlevel--;}

  public void emit (String s) throws CompilationException {
    try {
      for (int i = 0; i < 2 * indentlevel; i++) {
        out.append(' ');
      }
      out.append(s);
    } catch (IOException e) {
      throw new CompilationException(e);
    }
  }

  protected void enterSeq() throws CompilationException {emit("seq\n"); indent();}
  protected void exitSeq() throws CompilationException {dedent(); emit("seq end\n");}

  protected void emitMoveConst(String temp, int v) throws CompilationException {
    emit("move\n");
    emit("temp " + temp + "\n");
    emit("const " + v + "\n");
  }

  protected void emitMoveToTemp(String temp, ITASTexpression e)
    throws CompilationException {
    emit("move\n");
    emit("temp " + temp + "\n");
    e.accept(this, null);
    emit("\n");
  }

  public String compile(ITASTprogram program)
    throws CompilationException {

    StringWriter sw = new StringWriter();
    try {
      out = new BufferedWriter(sw);
      visit(program, null);
      out.flush();
    } catch (IOException exc) {
      throw new CompilationException(exc);
    }
    return sw.toString();
  }

  protected String treeProgramPrefix =
    "/* == High Level Intermediate representation. == */\n";

  protected String escape(String s){
    return s.replace("\\", "\\\\")
      .replace("\"", "\\\"");
  }
  //给注册字符串map添加布尔类型的true 和 false
  // Ajouter les valeurs booléennes true et false à la map des chaînes enregistrées.
  protected String ensureStringLiteral(String value) {
    Map<String,String> table = strCollect.getStringTable();
    String label = table.get(value);
    if (label == null) {
      label = "L_str_" + table.size();
      while (table.containsValue(label)) {
        label = "L_str_" + (table.size() + 1);
      }
      table.put(value, label);
    }
    return label;
  }
  //这里是parser的东西,我们定义了参数前要显式加一下是int还是float类型
  // Partie liée au parser : avant chaque paramètre, on ajoute explicitement son type,
  // c'est-à-dire int ou float.
  protected void emitTypedArg(ITASTexpression arg, Void context)
    throws CompilationException {
    if (arg.getType() == Type.FLOAT) {
      emit("float ");
    } else {
      emit("int ");
    }
    arg.accept(this, context);
  }
  // 生成函数调用表达式。
  // Génère une expression d'appel de fonction
  protected void emitCallExpr(String name, Type returnType, ITASTexpression[] args)
    throws CompilationException {
    emit(returnType == Type.FLOAT ? "callF\n" : "call\n");
    indent();
    emit("name " + name + "\n");

    if (args == null) {
      throw new CompilationException("Function " + name + " has null arguments");
    }

    for (ITASTexpression arg : args) {
      emitTypedArg(arg, null);
      emit("\n");
    }

    dedent();
    emit("call end");
  }
    // 将条件跳转 cjump 转换成一个返回布尔值的 Tree/HIR 表达式。
  // 比较成立时结果为 1，否则结果为 0。
  // 这里使用 eseq 先执行控制流代码，把结果写入临时变量 r，
  // 然后返回 temp r，使比较表达式可以在普通表达式位置使用

  // Si la comparaison est vraie, le résultat vaut 1 ; sinon il vaut 0.
  // on met le resultat dans temp
  protected void emitBoolFromCjump(String relop, ITASTexpression left,
                                   ITASTexpression right, Void context)
    throws CompilationException {
    String r = newTemp();
    String lTrue = newLabel();
    String lFalse = newLabel();
    String lEnd = newLabel();

    emit("eseq\n");
    indent();
    enterSeq();
    emit("cjump\n");
    indent();
    emit(relop + "\n");
    left.accept(this, context);
    emit("\n");
    right.accept(this, context);
    emit("\n");
    emit("name " + lTrue + "\n");
    emit("name " + lFalse + "\n");
    dedent();

    emit("label " + lTrue + "\n");
    emitMoveConst(r, 1);
    emit("jump name " + lEnd + "\n");

    emit("label " + lFalse + "\n");
    emitMoveConst(r, 0);

    emit("label " + lEnd + "\n");
    exitSeq();
    emit("temp " + r + "\n");
    dedent();
  }

  protected void emitStringName(String value) throws CompilationException {
    emit("name " + ensureStringLiteral(value));
  }


  public Void visit(ITASTprogram iast, Void context)
    throws CompilationException {
    emit(treeProgramPrefix);
    strCollect.collect(iast);
    ensureStringLiteral("true");
    ensureStringLiteral("false");
    for (Map.Entry<String,String> e : strCollect.getStringTable().entrySet()) {
      emit("label " + e.getValue() + " \"" + escape(e.getKey()) + "\"\n");
    }
    emit("label main\n");
    emit("sxp\n");
    indent();
    iast.getBody().accept(this, context);
    dedent();
    emit("\nlabel end\n");
    return null;
  }
//
  @Override
	public Void visit(ITASTboolean iast, Void context)
    throws CompilationException {
       emit("const " + (iast.getValue() ? "1" : "0"));
       return null;
  }

  @Override
	public Void visit(ITASTinteger iast, Void context)
    throws CompilationException {
    emit("const " + iast.getValue().toString());
    return null;
  }

  @Override
	public Void visit(ITASTfloat iast, Void context)
    throws CompilationException {
    emit("constF "+iast.getDescription().toString());
    return null;
  }
//
  @Override
  public Void visit(ITASTstring iast, Void context)
    throws CompilationException {
	  String label=strCollect.getStringTable().get(iast.getValue());
	  if(label==null) {throw new CompilationException("String not exists"+iast.getValue());}
	  emit("name " + label);
	  return null;
  }
//
  @Override
	public Void visit(ITASTvariable iast, Void context)
    throws CompilationException {
       String tmp=lookupVariable(iast.getName());
       if(tmp==null) {throw new CompilationException("Variable not exists"+iast.getName());}
       emit("temp " + tmp);
       return null;
  }
//
  @Override
	public Void visit(ITASTunaryOperation iast, Void context)
    throws CompilationException {
       String op=iast.getOperator().getName();
       switch (op) {
       case "ILP_Not"://case不一定对
           emitBoolFromCjump("eq", iast.getOperand(), new TASTinteger("0", Type.INT), context);
           return null;

       case "ILP_Opposite_INT":
           emit("binop\nsub\n");
           emit("const 0\n");
           iast.getOperand().accept(this, context);
           return null;

       case "ILP_Opposite_FLOAT":
           emit("binop\nsubF\n");
           emit("constF 0.\n");
           iast.getOperand().accept(this, context);
           return null;

       default:
           throw new CompilationException("Unknown unary operator " + op);
       }
  }
//
  private void emitStringCompare(ITASTbinaryOperation iast, Void context, String relop)
    throws CompilationException {
    String strcmpTemp = newTemp();

    emit("eseq\n");
    indent();
    enterSeq();
    emit("move\n");
    emit("temp " + strcmpTemp + "\n");
    emitCallExpr("strcmp", Type.INT, new ITASTexpression[] {
      iast.getLeftOperand(),
      iast.getRightOperand()
    });
    emit("\n");

    String r = newTemp();
    String lTrue = newLabel();
    String lFalse = newLabel();
    String lEnd = newLabel();

    emit("cjump\n");
    emit(relop + "\n");
    emit("temp " + strcmpTemp + "\n");
    emit("const 0\n");
    emit("name " + lTrue + "\n");
    emit("name " + lFalse + "\n");

    emit("label " + lTrue + "\n");
    emitMoveConst(r, 1);
    emit("jump name " + lEnd + "\n");

    emit("label " + lFalse + "\n");
    emitMoveConst(r, 0);
    emit("label " + lEnd + "\n");
    exitSeq();
    emit("temp " + r + "\n");
    dedent();
  }

  private void emitBoolOp(ITASTbinaryOperation iast, Void context)
    throws CompilationException {

    String op = iast.getOperator().getName();
    String r = newTemp();
    String lTrue = newLabel();
    String lFalse = newLabel();
    String lEnd = newLabel();

    emit("eseq\n");
    indent();
    enterSeq();
    if (op.equals("ILP_Or") || op.equals("ILP_And")) {
      boolean isOr = op.equals("ILP_Or");
      emit("cjump\n");
      emit(isOr ? "ne\n" : "eq\n");          // OR: a!=0, AND: a==0
      iast.getLeftOperand().accept(this, context);
      emit("\nconst 0\n");
      emit("name " + (isOr ? lTrue : lFalse) + "\n");
      emit("name " + (isOr ? lFalse : lTrue) + "\n");
      // short-circuit result
      emit("label " + (isOr ? lTrue : lFalse) + "\n");
      emitMoveConst(r, isOr ? 1 : 0);
      emit("jump name " + lEnd + "\n");
      // evaluate right operand
      emit("label " + (isOr ? lFalse : lTrue) + "\n");
      emitMoveToTemp(r, iast.getRightOperand());
    } else if (op.equals("ILP_Xor")) {

      String lBTrue = newLabel();
      String lBFalse = newLabel();

      // test A
      emit("cjump\n");
      emit("ne\n");
      iast.getLeftOperand().accept(this, context);
      emit("\nconst 0\n");
      emit("name " + lTrue + "\n");
      emit("name " + lFalse + "\n");

      // A true → test B
      emit("label " + lTrue + "\n");
      emit("cjump\n");
      indent();
      emit("ne\n");
      iast.getRightOperand().accept(this, context);
      emit("\nconst 0\n");
      emit("name " + lBTrue + "\n");
      emit("name " + lBFalse + "\n");
      dedent();

      emit("label " + lBTrue + "\n");
      emitMoveConst(r, 0);
      emit("jump name " + lEnd + "\n");
      emit("label " + lBFalse + "\n");
      emitMoveConst(r, 1);
      emit("jump name " + lEnd + "\n");

      // A false → result = B
      emit("label " + lFalse + "\n");
      emitMoveToTemp(r, iast.getRightOperand());
    }

    emit("label " + lEnd + "\n");
    exitSeq();
    emit("temp " + r + "\n");
    dedent();
  }

  private void emitRelOp(ITASTbinaryOperation iast, Void context, String relop)
    throws CompilationException {

    String r      = newTemp();
    String lTrue  = newLabel();
    String lFalse = newLabel();
    String lEnd   = newLabel();

    emit("eseq\n");
    indent();
    enterSeq();
    // cjump relop left right lTrue lFalse
    emit("cjump\n");
    indent();
    emit(relop + "\n");
    iast.getLeftOperand().accept(this, context);
    emit("\n");
    iast.getRightOperand().accept(this, context);
    emit("\n");
    emit("name " + lTrue + "\n");
    emit("name " + lFalse + "\n");
    dedent();
    // true branch → r := 1
    emit("label " + lTrue + "\n");
    emitMoveConst(r, 1);
    emit("jump name " + lEnd + "\n");
    // false branch → r := 0
    emit("label " + lFalse + "\n");
    emitMoveConst(r, 0);
    emit("label " + lEnd + "\n");
    exitSeq();
    emit("temp " + r + "\n");
    dedent();
  }

  private void emitBinOp(ITASTbinaryOperation iast, Void context, String opcode)
    throws CompilationException {
    emit("binop\n");
    emit(opcode);
    emit("\n");
    iast.getLeftOperand().accept(this, context);
    emit("\n");
    iast.getRightOperand().accept(this, context);
  }



  @Override
  public Void visit(ITASTbinaryOperation iast, Void context)
    throws CompilationException {
    String cName = iast.getOperator().getName();

    if (cName.endsWith("_STRING")) {
      String opcode;
      switch (cName) {
      case "ILP_Equal_STRING":                opcode = "eq";  break;
      case "ILP_NotEqual_STRING":             opcode = "ne"; break;
      case "ILP_LessThan_STRING":             opcode = "lt";  break;
      case "ILP_LessThanOrEqual_STRING":      opcode = "le"; break;
      case "ILP_GreaterThan_STRING":          opcode = "gt";  break;
      case "ILP_GreaterThanOrEqual_STRING":   opcode = "ge"; break;
      default:
        throw new CompilationException("Operator " + cName + " cannot be compiled");
      }
      emitStringCompare(iast, context, opcode);
      return null;
    }

    if (cName.equals("ILP_Or") || cName.equals("ILP_And") || cName.equals("ILP_Xor")) {
      emitBoolOp(iast,context);
      return null;
    }
    //pour les strings
    if ("ILP_Concat".equals(cName)) {
      emitCall("concat", Type.STRING, new ITASTexpression[] {
          iast.getLeftOperand(),
          iast.getRightOperand()
      });
      return null;
    }

    /* ---------- arithmetic ---------- */

    switch (cName) {
    case "ILP_Plus_INT":       emitBinOp(iast, context, "add");  return null;
    case "ILP_Plus_FLOAT":     emitBinOp(iast, context, "addF"); return null;
    case "ILP_Minus_INT":      emitBinOp(iast, context, "sub");  return null;
    case "ILP_Minus_FLOAT":    emitBinOp(iast, context, "subF"); return null;
    case "ILP_Times_INT":      emitBinOp(iast, context, "mul");  return null;
    case "ILP_Times_FLOAT":    emitBinOp(iast, context, "mulF"); return null;
    case "ILP_Divide_INT":     emitBinOp(iast, context, "div");  return null;
    case "ILP_Divide_FLOAT":   emitBinOp(iast, context, "divF"); return null;
    case "ILP_Modulo":         emitBinOp(iast, context, "mod");  return null;
    case "ILP_LessThan_INT":             emitRelOp(iast, context, "lt");  return null;
    case "ILP_LessThanOrEqual_INT":      emitRelOp(iast, context, "le"); return null;
    case "ILP_GreaterThan_INT":          emitRelOp(iast, context, "gt");  return null;
    case "ILP_GreaterThanOrEqual_INT":   emitRelOp(iast, context, "ge"); return null;
    case "ILP_LessThan_FLOAT":           emitRelOp(iast, context, "ltF");  return null;
    case "ILP_LessThanOrEqual_FLOAT":    emitRelOp(iast, context, "leF"); return null;
    case "ILP_GreaterThan_FLOAT":        emitRelOp(iast, context, "gtF");  return null;
    case "ILP_GreaterThanOrEqual_FLOAT": emitRelOp(iast, context, "geF"); return null;
    case "ILP_Equal_INT":
    case "ILP_Equal_BOOL":               emitRelOp(iast, context, "eq");  return null;
    case "ILP_NotEqual_INT":
    case "ILP_NotEqual_BOOL":            emitRelOp(iast, context, "ne"); return null;
    case "ILP_Equal_FLOAT":              emitRelOp(iast, context, "eqF");  return null;
    case "ILP_NotEqual_FLOAT":           emitRelOp(iast, context, "neF"); return null;
    default:
      throw new CompilationException("Operator " + cName + " cannot be compiled");
    }
  }
//按顺序执行所有子表达式，只保留最后一个的值。前面的都是为了副作用
  @Override
	public Void visit(ITASTsequence iast, Void context)
    throws CompilationException {
       emit("eseq\n");
       enterSeq();
       
       ITASTexpression[] exprs=iast.getExpressions();
       for (int i=0; i<exprs.length-1; i++) {
         emit("sxp\n");
         indent();
         exprs[i].accept(this, context);
         emit("\n");
         dedent();
       }
       
       ITASTexpression last=exprs[exprs.length - 1];
       String r = last.getType() == Type.FLOAT ? newFloatTemp() : newTemp();
       emitMoveToTemp(r, last);
       exitSeq();
       emit("temp " + r + "\n");
       
       return null;
  }
//
  @Override
  public Void visit(ITASTalternative iast, Void context)
    throws CompilationException {

       String lThen=newLabel();
       String lElse=newLabel();
       String lEnd=newLabel();
       String r = iast.getType() == Type.FLOAT ? newFloatTemp() : newTemp();
       
       emit("eseq\n");
       indent();
       enterSeq();
       
       emit("cjump\n");
       emit("eq\n"); 
       iast.getCondition().accept(this, context);
       emit("\nconst 0\n"); 
       emit("name " + lElse + "\n");
       emit("name " + lThen + "\n");
       
       emit("label " + lThen + "\n");
       emitMoveToTemp(r, iast.getConsequence());
       emit("jump name " + lEnd + "\n");
       
       emit("label " + lElse + "\n");
       if (iast.getAlternant() != null) {
           emitMoveToTemp(r, iast.getAlternant());
       } else {
           emitMoveConst(r, 0);
       }
       
       emit("label " + lEnd + "\n");
       
       exitSeq();
       emit("temp " + r + "\n");
       dedent();
       
       return null;
  }

  /**
   * Bind a variable name in the current scope to a fresh temporary and
   * return that temporary name. If the variable already exists in the
   * current scope, it will be shadowed by the new temp.
   */
  protected String bindVariable(String varName) {
    String temp = newTemp();
    envStack.peek().put(varName, temp);
    return temp;
  }
// 
  @Override
  public Void visit(ITASTblock iast, Void context)
    throws CompilationException {
    enterScope();

    ITASTblock.ITASTbinding[] bs = iast.getBindings();

    if (bs != null && bs.length > 0) {
      emit("eseq\n");
      indent();
      enterSeq();

      String[] temps = new String[bs.length];

      for (int i = 0; i < bs.length; i++) {
        ITASTblock.ITASTbinding b = bs[i];
        String varName = b.getVariable().getName();
        ITASTexpression init = b.getInitialisation();
        String tmp;
        if (init.getType() == Type.FLOAT) {
          tmp = newFloatTemp();
        } else {
          tmp = newTemp();
        }
        temps[i] = tmp;
        emitMoveToTemp(tmp, init);
      }

      for (int i = 0; i < bs.length; i++) {
        envStack.peek().put(bs[i].getVariable().getName(), temps[i]);
      }

      exitSeq();
      iast.getBody().accept(this, context);
      emit("\n");
      dedent();
    } else {
      if (iast.getBody() == null)
        throw new CompilationException("Block body is null");
      iast.getBody().accept(this, context);
    }

    leaveScope();
    return null;
  }

  // handling of function returning bool, int, float and string.
  // functions that return void (e.g print) cant be handled here
  protected void emitCall(String name, Type returnType, ITASTexpression[] args)
    throws CompilationException {
    emitCallExpr(name, returnType, args);
  }

  @Override
	public Void visit(ITASTinvocation iast, Void context)
    throws CompilationException {
    ITASTexpression function =  iast.getFunction();
    ITASTvariable v = (ITASTvariable) function;
    String fname = v.getName();
    ITASTexpression[] args = iast.getArguments();
    if ("print".equals(fname)) {
      emit("eseq\n");
      indent();
      emit("sxp\n");
      indent();
      emit("call\n");
      indent();
      emit("name print\n");
      args[0].accept(this,null);
      emit("\n");
      dedent();
      emit("call end\n");
      dedent();
      emit("const 0");
      dedent();
    }//没出现在runtime中,需要特判 
    else if ("string_of_bool".equals(fname)) {
      if (args.length != 1) {
        throw new CompilationException("string_of_bool expects one argument");
      }
      String r = newTemp();
      String lTrue = newLabel();
      String lFalse = newLabel();
      String lEnd = newLabel();

      emit("eseq\n");
      indent();
      enterSeq();
      emit("cjump\n");
      emit("ne\n");
      args[0].accept(this, context);
      emit("\nconst 0\n");
      emit("name " + lTrue + "\n");
      emit("name " + lFalse + "\n");

      emit("label " + lTrue + "\n");
      emit("move\n");
      emit("temp " + r + "\n");
      emitStringName("true");
      emit("\n");
      emit("jump name " + lEnd + "\n");

      emit("label " + lFalse + "\n");
      emit("move\n");
      emit("temp " + r + "\n");
      emitStringName("false");
      emit("\n");

      emit("label " + lEnd + "\n");
      exitSeq();
      emit("temp " + r);
      dedent();
    } else {
      emitCall(fname, iast.getType(), iast.getArguments());
    }
    return null;
  }
}
