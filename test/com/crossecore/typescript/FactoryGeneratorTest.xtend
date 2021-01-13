package com.crossecore.typescript

import static org.junit.Assert.*
import org.junit.Test
import com.crossecore.typescript.FactoryGenerator
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Before
import org.eclipse.emf.ecore.EPackage
import org.antlr.v4.runtime.tree.xpath.XPath
import antlr.typescript.TypeScriptParser
import org.antlr.v4.runtime.ANTLRInputStream
import antlr.typescript.TypeScriptLexer
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.CharStreams
import java.util.List
import java.util.Arrays
import com.crossecore.TreeUtils

class FactoryGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)	
				
		val einterface = EcoreFactory.eINSTANCE.createEClass()
		einterface.name = "MyInterface"
		einterface.interface = true
		epackage.EClassifiers.add(einterface)	
		
		val abstractclass = EcoreFactory.eINSTANCE.createEClass()
		abstractclass.name = "MyAbstractClass"
		abstractclass.abstract = true
		epackage.EClassifiers.add(abstractclass)				
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val factory = new FactoryGenerator();
		
		//Action
		val result = factory.caseEPackage(epackage).toString()
		
		System.out.println(result);
		//Assert
		//https://github.com/antlr/antlr4/blob/master/doc/tree-matching.md
		
		val xpath = "//interfaceDeclaration";
		val lexer = new TypeScriptLexer(CharStreams.fromString(result));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		
		parser.setBuildParseTree(true);
		val tree = parser.program();
		val ruleNamesList = Arrays.asList(parser.getRuleNames());
		val prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
		//System.out.println(prettyTree)
		
		
		val x = XPath.findAll(tree, xpath, parser).toSet;
		
		
		assertTrue(x.length===1)
		
		assertTrue(result.contains("export interface MyPackageFactory extends EFactory"))
	
		val xpath2 = "//methodSignature";
		val x2 = XPath.findAll(tree, xpath2, parser).toSet;
		
		
		assertTrue(x2.length===2)
	}
	
	
}
