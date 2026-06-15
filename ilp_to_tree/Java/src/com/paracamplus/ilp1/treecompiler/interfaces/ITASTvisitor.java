package com.paracamplus.ilp1.treecompiler.interfaces;

import com.paracamplus.ilp1.treecompiler.tast.Type;
import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.interfaces.IASTvisitor;

public interface ITASTvisitor<Result, Data, Anomaly extends Throwable> {

    Result visit(ITASTboolean iast, Data data) throws Anomaly;
    Result visit(ITASTinteger iast, Data data) throws Anomaly;
    Result visit(ITASTfloat iast, Data data) throws Anomaly;
    Result visit(ITASTstring iast, Data data) throws Anomaly;

    Result visit(ITASTvariable iast, Data data) throws Anomaly;

    Result visit(ITASTunaryOperation iast, Data data) throws Anomaly;
    Result visit(ITASTbinaryOperation iast, Data data) throws Anomaly;

    Result visit(ITASTsequence iast, Data data) throws Anomaly;
    Result visit(ITASTalternative iast, Data data) throws Anomaly;
    Result visit(ITASTblock iast, Data data) throws Anomaly;

    Result visit(ITASTinvocation iast, Data data) throws Anomaly;
}
