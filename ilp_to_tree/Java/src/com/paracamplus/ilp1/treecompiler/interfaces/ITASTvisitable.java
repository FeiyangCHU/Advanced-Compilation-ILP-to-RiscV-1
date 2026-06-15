package com.paracamplus.ilp1.treecompiler.interfaces;

public interface ITASTvisitable {

  <Result, Data, Anomaly extends Throwable>
    Result accept(ITASTvisitor<Result, Data, Anomaly> visitor, Data data) throws Anomaly;
}
