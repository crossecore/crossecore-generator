package com.crossecore.typescript

import antlr.typescript.TypeScriptLexer
import antlr.typescript.TypeScriptParser
import com.crossecore.TreeUtils
import java.util.Arrays
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.xpath.XPath
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*

class ModelImplGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val etypeparam = EcoreFactory.eINSTANCE.createETypeParameter()
		etypeparam.name = "T"
		eclass.ETypeParameters.add(etypeparam)
		
		val einterface = EcoreFactory.eINSTANCE.createEClass();
		einterface.name = "MyInterface"
		einterface.interface = true
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(einterface)
		
	}

	@Test def void test_caseEClass() {
		
		//Arrange

		val generator = new ModelImplGenerator();
		
		//Action
		val result = generator.caseEClass(epackage.EClassifiers.findFirst[e|e.name.equals("MyClass")] as EClass).toString()
		//System.out.println(result)
		
		//Assert
		//https://github.com/antlr/antlr4/blob/master/doc/tree-matching.md
		
		val xpath = "//classDeclaration";
		val lexer = new TypeScriptLexer(CharStreams.fromString(result));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		
		
		parser.setBuildParseTree(true);
		val tree = parser.program();
		val ruleNamesList = Arrays.asList(parser.getRuleNames());
		val prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
		//System.out.println(prettyTree)
		
		val x = XPath.findAll(tree, xpath, parser).toSet;
		
		assertTrue(x.size===1)

		
	}

	
}
