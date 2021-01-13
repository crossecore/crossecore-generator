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
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val factory = new FactoryGenerator();
		
		//Action
		val result = factory.caseEPackage(epackage).toString()
		
		//Assert
		//https://github.com/antlr/antlr4/blob/master/doc/tree-matching.md
		
		val xpath = "//classDeclaration";
		val lexer = new TypeScriptLexer(CharStreams.fromString(result));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		val x = XPath.findAll(parser.classDeclaration, xpath, parser).toSet;
		
		assertTrue(x.length===1)
		
		assertTrue(result.contains("export interface MyPackageFactory extends EFactory"))
	}
	
	
}
