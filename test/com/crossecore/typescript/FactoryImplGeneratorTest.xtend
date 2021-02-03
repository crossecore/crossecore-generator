package com.crossecore.typescript

import antlr.typescript.TypeScriptLexer
import antlr.typescript.TypeScriptParser
import com.crossecore.TreeUtils
import java.util.Arrays
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.xpath.XPath
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*
import com.crossecore.AntlrTestUtil

class FactoryImplGeneratorTest {

	EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		epackage.EClassifiers.add(eclass)
		
		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDatatype"
		
		epackage.EClassifiers.add(edatatype)
				
		val eenum = EcoreFactory.eINSTANCE.createEEnum();
		eenum.name = "MyEnum"
		val literal = EcoreFactory.eINSTANCE.createEEnumLiteral();
		literal.name = "LITERAL"
		literal.value = 13
		
		epackage.EClassifiers.add(eenum)
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val generator = new FactoryImplGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		//System.out.println(result)
		//Assert
		val xpath = "//classElement/propertyMemberDeclaration/propertyName/identifierName";
		val nodes = AntlrTestUtil.xpath(result, xpath)
		
		assertTrue(nodes.exists[t|t.text.equals("convertMyEnumToString")])
		assertTrue(nodes.exists[t|t.text.equals("createMyEnumFromString")])
		assertTrue(nodes.exists[t|t.text.equals("convertMyDatatypeToString")])
		assertTrue(nodes.exists[t|t.text.equals("createMyDatatypeFromString")])
		
	}

	
}
