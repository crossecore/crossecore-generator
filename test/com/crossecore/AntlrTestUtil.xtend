package com.crossecore

import antlr.typescript.TypeScriptLexer
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import antlr.typescript.TypeScriptParser
import org.antlr.v4.runtime.tree.xpath.XPath
import java.util.Arrays

class AntlrTestUtil {
	
	
	static def xpath (String sourcecode, String xpath){
		
		val lexer = new TypeScriptLexer(CharStreams.fromString(sourcecode));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		parser.setBuildParseTree(true);
		val tree = parser.program();
		
		val ruleNamesList = Arrays.asList(parser.getRuleNames());
		val prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
		//System.out.println(prettyTree)
		
		return XPath.findAll(tree, xpath, parser);
	}
}