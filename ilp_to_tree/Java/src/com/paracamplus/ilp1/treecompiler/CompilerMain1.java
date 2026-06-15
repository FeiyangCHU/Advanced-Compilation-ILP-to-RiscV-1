package com.paracamplus.ilp1.treecompiler;

import java.io.File;
import java.io.IOException;
import java.util.stream.Stream;

import com.paracamplus.ilp1.tools.FileTool;
import com.paracamplus.ilp1.tools.InputFromFile;
import com.paracamplus.ilp1.compiler.CompilationException;
import com.paracamplus.ilp1.compiler.GlobalVariableEnvironment;
import com.paracamplus.ilp1.compiler.GlobalVariableStuff;
import com.paracamplus.ilp1.compiler.OperatorEnvironment;
import com.paracamplus.ilp1.compiler.OperatorStuff;
import com.paracamplus.ilp1.compiler.interfaces.IGlobalVariableEnvironment;
import com.paracamplus.ilp1.compiler.interfaces.IOperatorEnvironment;
import com.paracamplus.ilp1.interfaces.IASTprogram;
import com.paracamplus.ilp1.interfaces.IASTfactory;
import com.paracamplus.ilp1.ast.ASTfactory;
import com.paracamplus.ilp1.parser.ParseException;
import com.paracamplus.ilp1.parser.ilpml.ILPMLParser;

import com.paracamplus.ilp1.treecompiler.CompilerTree;
import com.paracamplus.ilp1.treecompiler.Typer;
import com.paracamplus.ilp1.treecompiler.Resolver;
import com.paracamplus.ilp1.treecompiler.tast.TASTprogram;
import com.paracamplus.ilp1.treecompiler.TypingException;
import com.paracamplus.ilp1.treecompiler.ResolutionException;

public class CompilerMain1 {

  public static void main(String[] args) {

    IASTfactory factory = new ASTfactory();
    ILPMLParser parser = new ILPMLParser(factory);

    try {
      if (args.length < 1) {
        System.out.println("expecting an .ilpml file");
        System.exit(1);
      }

      // ---- Command-line parsing ----
      String inputFileName = null;
      String outputFileName = null;

      for (int i = 0; i < args.length; i++) {
        if ("-o".equals(args[i])) {
          if (i + 1 >= args.length) {
            System.out.println("missing output file after -o");
            System.exit(1);
          }
          outputFileName = args[i + 1];
          i++; // skip output file
        } else {
          inputFileName = args[i];
        }
      }

      if (inputFileName == null) {
        System.out.println("expecting an .ilpml file");
        System.exit(1);
      }

      // ---- Compiler configuration ----
      IOperatorEnvironment ioe = new OperatorEnvironment();
      OperatorStuff.fillUnaryOperators(ioe);
      OperatorStuff.fillBinaryOperators(ioe);

      IGlobalVariableEnvironment gve = new GlobalVariableEnvironment();
      GlobalVariableStuff.fillGlobalVariables(gve);

      Typer typer = new Typer(ioe, gve);
      Resolver resolver = new Resolver(ioe, gve);
      CompilerTree compiler = new CompilerTree();

      // ---- Parsing & compilation ----
      InputFromFile f = new InputFromFile(inputFileName);
      parser.setInput(f);

      IASTprogram program = (IASTprogram) parser.getProgram();
      TASTprogram typedProgram = typer.visit(program);
      TASTprogram resolvedProgram = resolver.resolve(typedProgram);
      String compiled = compiler.compile(resolvedProgram);

      // ---- Output handling ----
      File outputFile;
      if (outputFileName != null) {
        outputFile = new File(outputFileName);
      } else {
        File inputFile = new File(inputFileName);
        outputFile = FileTool.changeSuffix(inputFile, "hir");
      }

      FileTool.stuffFile(outputFile, compiled);
      System.exit(0);

    } catch (TypingException e) {
      System.out.println("error " + e);
      System.exit(1);
    } catch (ResolutionException e) {
      System.out.println("error " + e);
      System.exit(2);
    } catch (CompilationException e) {
      System.out.println("error " + e);
      System.exit(3);
    } catch (Exception e) {
      System.out.println("error " + e);
      System.exit(42);
    }
  }
}
