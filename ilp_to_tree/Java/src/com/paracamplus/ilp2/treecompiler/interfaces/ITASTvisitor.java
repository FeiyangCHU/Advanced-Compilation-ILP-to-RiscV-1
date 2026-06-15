package com.paracamplus.ilp2.treecompiler.interfaces;

public interface ITASTvisitor<Result, Data, Anomaly extends Throwable>
  extends com.paracamplus.ilp1.treecompiler.interfaces.ITASTvisitor <Result, Data, Anomaly>{

  Result visit(ITASTassignment iast, Data data) throws Anomaly;
  Result visit(ITASTloop iast, Data data) throws Anomaly;
}
