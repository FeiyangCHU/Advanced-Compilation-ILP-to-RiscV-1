package com.paracamplus.ilp1.treecompiler.tast;
import com.paracamplus.ilp1.treecompiler.TypingException;

public enum Type {
  INT,
  STRING,
  FLOAT,
  BOOL,
  FUNCTION,
  PARAM;

  public static Type unify(Type t1, Type t2, String msg) throws TypingException {
    if (t1 == t2) return t2;
    if (t1 == PARAM) return t2;
    if (t2 == PARAM) return t1;
    if (t1 == BOOL || t2 == BOOL) return BOOL;
    if (t1 == STRING || t2 == STRING) return STRING;
    if (t1 == INT && t2 == FLOAT || t2 == INT && t1 == FLOAT) return FLOAT;
    throw new TypingException(msg);
  }

  public static Type unify(Type t1, Type t2) throws TypingException {
    return unify(t1,t2,("cannot unify " + t1 + " and " + t2));
  }

  public static boolean isNumeric(Type t) {
    return t == INT || t == FLOAT || t == PARAM;
  }
}
