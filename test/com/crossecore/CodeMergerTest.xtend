package com.crossecore

import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*
import antlr.typescript.TypeScriptLexer
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import antlr.typescript.TypeScriptParser
import org.antlr.v4.runtime.misc.Interval
import java.util.Arrays
import org.antlr.v4.runtime.Token
import org.antlr.v4.runtime.tree.TerminalNode

class CodeMergerTest {


	@Test def void test() {
		
		val sourcecode = 
		'''
		export class MyClass{
		    /**
		     * @generated NOT
		     */
		    public fun(){}
		}
		'''
		val lexer = new TypeScriptLexer(CharStreams.fromString(sourcecode));
		val tokens = new CommonTokenStream(lexer);
		
		
		
		val parser = new TypeScriptParser(tokens);
		parser.setBuildParseTree(true);
		val tree = parser.program()
		
		for(Token k: tokens.tokens){
				
			System.out.println(k)
		}
		
		/* 
		val start = tree.start.getStartIndex()
		val stop = tree.stop.getStopIndex()
		val interval = new Interval(start, stop)
		val text = tree.start.getInputStream().getText(interval);
		System.out.println(text)
		*/
		

	}


	
	
}