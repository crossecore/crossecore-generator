package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Test

import static org.junit.Assert.*

class FactoryGeneratorTest {



	@Test def void test_caseEPackage() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)	
				
		val factory = new FactoryGenerator("","",epackage);
		
		//Action
		val result = factory.caseEPackage(epackage).toString()
	
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature")
		assertTrue(nodes.size===1)
		
	}	
	
	@Test def void test_caseEPackage2() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		val abstractclass = EcoreFactory.eINSTANCE.createEClass()
		abstractclass.name = "MyAbstractClass"
		abstractclass.abstract = true
		epackage.EClassifiers.add(abstractclass)	
				
		val factory = new FactoryGenerator("","",epackage);
		
		//Action
		val result = factory.caseEPackage(epackage).toString()
	
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature")
		assertTrue(nodes.size===1)
		
	}
	
	@Test def void test_caseEPackage3() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		val einterface = EcoreFactory.eINSTANCE.createEClass()
		einterface.name = "MyInterface"
		einterface.interface = true
		epackage.EClassifiers.add(einterface)	
				
		val factory = new FactoryGenerator("","",epackage);
		
		//Action
		val result = factory.caseEPackage(epackage).toString()
	
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature")
		assertTrue(nodes.size===0)
		
	}
	
}
