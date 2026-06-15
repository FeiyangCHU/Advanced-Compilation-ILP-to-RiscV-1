/* *****************************************************************
 * ilp1 - Implantation d'un langage de programmation.
 * by Christian.Queinnec@paracamplus.com
 * See http://mooc.paracamplus.com/ilp1
 * GPL version 3
 ***************************************************************** */
package com.paracamplus.ilp1.compiler.test;

import java.io.File;
import java.io.IOException;
import java.util.stream.Stream;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import com.paracamplus.ilp1.ast.ASTfactory;
import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.compiler.Compiler;
import com.paracamplus.ilp1.compiler.GlobalVariableEnvironment;
import com.paracamplus.ilp1.compiler.GlobalVariableStuff;
import com.paracamplus.ilp1.compiler.OperatorEnvironment;
import com.paracamplus.ilp1.compiler.OperatorStuff;
import com.paracamplus.ilp1.compiler.interfaces.IGlobalVariableEnvironment;
import com.paracamplus.ilp1.compiler.interfaces.IOperatorEnvironment;
import com.paracamplus.ilp1.compiler.optimizer.IdentityOptimizer;
import com.paracamplus.ilp1.interfaces.IASTfactory;
import com.paracamplus.ilp1.parser.ParseException;
import com.paracamplus.ilp1.parser.ilpml.ILPMLParser;
import com.paracamplus.ilp1.parser.xml.IXMLParser;
import com.paracamplus.ilp1.parser.xml.XMLParser;

public class CompilerTest {
    
    private static String[] samplesDirName = { "SamplesILP1" };
    private static String pattern = ".*\\.ilpml";
    private static String scriptCommand = "C/compileThenRun.sh +gc";
    private static String XMLgrammarFile = "XMLGrammars/grammar1.rng";
    
    public static CompilerRunner createRunner() throws CompilationException {
    	CompilerRunner run = new CompilerRunner();

    	// configuration du parseur
        IASTfactory factory = new ASTfactory();
        IXMLParser xmlparser = new XMLParser(factory);
        xmlparser.setGrammar(new File(XMLgrammarFile));
        run.setXMLParser(xmlparser);
        run.setILPMLParser(new ILPMLParser(factory));
  	
        // configuration du compilateur
        IOperatorEnvironment ioe = new OperatorEnvironment();
        OperatorStuff.fillUnaryOperators(ioe);
        OperatorStuff.fillBinaryOperators(ioe);
        IGlobalVariableEnvironment gve = new GlobalVariableEnvironment();
        GlobalVariableStuff.fillGlobalVariables(gve);
        Compiler compiler = new Compiler(ioe, gve);
        compiler.setOptimizer(new IdentityOptimizer());
        run.setCompiler(compiler);

        // configuration du script de compilation et exécution
        run.setRuntimeScript(scriptCommand);
       
        return run;
    }
    
    @ParameterizedTest
    @MethodSource("getFiles")
    public void testFile(File file) throws CompilationException, ParseException, IOException {
        // compilation, execution et vérification du résultat
    	CompilerRunner run = createRunner();
    	run.checkPrintingAndResult(file, run.compileAndRun(file));	
    }
    
    private static Stream<File>getFiles() throws Exception {
    	return CompilerRunner.getFileList(samplesDirName, pattern);
    }
}
