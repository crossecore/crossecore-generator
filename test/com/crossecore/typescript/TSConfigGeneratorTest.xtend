package com.crossecore.typescript

import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Test

import static org.junit.Assert.*

class TSConfigGeneratorTest {


	@Test def void test_caseEPackage() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		val generator = new TSConfigGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		assertTrue(result.contains('''"MyPackage/*": ["./*"]'''))
	
	}
	
	
}
