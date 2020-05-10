package com.crossecore

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
import org.eclipse.emf.ecore.EcorePackage

class FactoryGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcorePackage.eINSTANCE
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
		
		assertTrue(result.contains("export interface EcoreFactory extends EFactory"))
	}
	
	@Test def void test_index() {
		//Arrange
		val baseDir = "src/"
		val factory = new FactoryGenerator(baseDir, "%sFactory.ts", epackage)
		
		//Action
		val index = factory.index()
		
		
		//Assert
		assertNotNull(index)
		assertTrue(index.size===1)
		System.out.println(index)
		assertTrue(index.containsKey(EcorePackage.eINSTANCE))
		assertArrayEquals(#["src/EcoreFactory.ts"], index.get(EcorePackage.eINSTANCE))
		
			
	}
	
	
	
}