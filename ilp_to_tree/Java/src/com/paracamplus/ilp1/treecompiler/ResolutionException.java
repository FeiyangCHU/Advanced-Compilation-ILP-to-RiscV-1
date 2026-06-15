package com.paracamplus.ilp1.treecompiler;

@SuppressWarnings("serial")
public class ResolutionException extends Exception {

    public ResolutionException(String msg) {
        super(msg);
    }

    public ResolutionException(Exception e) {
        super(e);
    }
}
