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

class PackageGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name ="attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING;
		eclass.EStructuralFeatures.add(eattribute)
		
		val ereference = EcoreFactory.eINSTANCE.createEAttribute()
		ereference.name ="ereference"
		ereference.EType = eclass
		eclass.EStructuralFeatures.add(ereference)
		
		epackage.EClassifiers.add(eclass)
		
		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDatatype"
		edatatype.instanceClassName = "java.util.String"
		
		epackage.EClassifiers.add(edatatype)
		
		val eenum = EcoreFactory.eINSTANCE.createEEnum()
		eenum.name = "MyEnum"
		
		val literal = EcoreFactory.eINSTANCE.createEEnumLiteral()
		literal.name = "EINS"
		literal.value = 1
		eenum.ELiterals.add(literal)
		
		epackage.EClassifiers.add(eenum)
		
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val generator = new PackageGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		System.out.println(result)
		
		//Assert
		//https://github.com/antlr/antlr4/blob/master/doc/tree-matching.md
		
		val xpath = "//methodSignature";
		val lexer = new TypeScriptLexer(CharStreams.fromString(result));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		
		
		
		parser.setBuildParseTree(true);
		val tree = parser.program();
		val ruleNamesList = Arrays.asList(parser.getRuleNames());
		val prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
		System.out.println(prettyTree)
		
		val x = XPath.findAll(tree, xpath, parser).toSet;
		
		assertTrue(x.size===5)

		
	}

	
}
