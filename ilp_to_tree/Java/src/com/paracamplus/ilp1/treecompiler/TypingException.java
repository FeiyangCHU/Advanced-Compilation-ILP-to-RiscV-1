package com.paracamplus.ilp1.treecompiler;

@SuppressWarnings("serial")
public class TypingException extends Exception {

    public TypingException(String msg) {
        super(msg);
    }

    public TypingException(Exception e) {
        super(e);
    }
}
