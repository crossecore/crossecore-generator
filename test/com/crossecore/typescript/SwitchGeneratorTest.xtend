package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Test

import static org.junit.Assert.*

class SwitchGeneratorTest {



	@Test def void test_caseEPackage() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new SwitchGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/functionBody")		
		assertTrue(nodes.size===3)		
		

		
	}

	
}
