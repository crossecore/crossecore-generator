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

class NpmPackageGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val generator = new NpmPackageGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		assertTrue(result.contains('''"name": "MyPackage"'''))
	
	}
	
	
}
