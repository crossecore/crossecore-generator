package com.crossecore.typescript

import org.eclipse.emf.ecore.EcoreFactory
import static org.junit.Assert.*
import org.junit.Test
import com.crossecore.AntlrTestUtil

class PackageLiteralsGeneratorTest {
	
	@Test def void test_caseEPackage2() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val enum = EcoreFactory.eINSTANCE.createEEnum();
		enum.name = "MyEnum"
		
		val literal = EcoreFactory.eINSTANCE.createEEnumLiteral()
		literal.name = "EINS"
		literal.value = 1
		enum.ELiterals.add(literal)

		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDataType"
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(enum)
		epackage.EClassifiers.add(edatatype)
		
		val generator = new PackageLiteralsGenerator();

		//Action
		val result = generator.caseEPackage(epackage).toString
		System.out.println(result)
		
		//Assert
		
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("MYCLASS")])
		assertTrue(nodes.exists[n|n.text.equals("MYCLASS_FEATURE_COUNT")])
		assertTrue(nodes.exists[n|n.text.equals("MYCLASS_OPERATION_COUNT")])
		assertTrue(nodes.exists[n|n.text.equals("MYENUM")])
		assertTrue(nodes.exists[n|n.text.equals("MYDATATYPE")])
	}
}