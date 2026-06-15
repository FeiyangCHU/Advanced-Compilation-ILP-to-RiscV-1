/* *****************************************************************
 * ILP9 - Implantation d'un langage de programmation.
 * by Christian.Queinnec@paracamplus.com
 * See http://mooc.paracamplus.com/ilp9
 * GPL version 3
 ***************************************************************** */
package com.paracamplus.ilp1.interpreter.test;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.util.stream.Stream;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import com.paracamplus.ilp1.ast.ASTfactory;
import com.paracamplus.ilp1.interfaces.IASTfactory;
import com.paracamplus.ilp1.interpreter.GlobalVariableEnvironment;
import com.paracamplus.ilp1.interpreter.GlobalVariableStuff;
import com.paracamplus.ilp1.interpreter.Interpreter;
import com.paracamplus.ilp1.interpreter.OperatorEnvironment;
import com.paracamplus.ilp1.interpreter.OperatorStuff;
import com.paracamplus.ilp1.interpreter.interfaces.EvaluationException;
import com.paracamplus.ilp1.interpreter.interfaces.IGlobalVariableEnvironment;
import com.paracamplus.ilp1.interpreter.interfaces.IOperatorEnvironment;
import com.paracamplus.ilp1.parser.ParseException;
import com.paracamplus.ilp1.parser.ilpml.ILPMLParser;
import com.paracamplus.ilp1.parser.xml.IXMLParser;
import com.paracamplus.ilp1.parser.xml.XMLParser;

public class InterpreterTest {
    
    private static String[] samplesDirName = { "SamplesILP1" }; 
    private static String pattern = ".*\\.ilpml";
    private static String XMLgrammarFile = "XMLGrammars/grammar1.rng";

    public static InterpreterRunner createRunner() throws EvaluationException {
    	InterpreterRunner run = new InterpreterRunner();
    	
    	// configuration du parseur
        IASTfactory factory = new ASTfactory();
        IXMLParser xmlParser = new XMLParser(factory);
        xmlParser.setGrammar(new File(XMLgrammarFile));
        run.setXMLParser(xmlParser);
        run.setILPMLParser(new ILPMLParser(factory));

        // configuration de l'interprète
        StringWriter stdout = new StringWriter();
        run.setStdout(stdout);
        IGlobalVariableEnvironment gve = new GlobalVariableEnvironment();
        GlobalVariableStuff.fillGlobalVariables(gve, stdout);
        IOperatorEnvironment oe = new OperatorEnvironment();
        OperatorStuff.fillUnaryOperators(oe);
        OperatorStuff.fillBinaryOperators(oe);
        Interpreter interpreter = new Interpreter(gve, oe);        
        run.setInterpreter(interpreter);
        
        return run;
    }
    
    @ParameterizedTest
    @MethodSource("getFiles")
    public void processFile(File file) throws EvaluationException, ParseException, IOException {
    	InterpreterRunner run = createRunner();
       	run.testFile(file);
    	run.checkPrintingAndResult(file);
    }  
    
    private static Stream<File>getFiles() throws Exception {
    	return InterpreterRunner.getFileList(samplesDirName, pattern);
    }
}
