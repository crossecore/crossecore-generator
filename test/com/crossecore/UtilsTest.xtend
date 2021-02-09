package com.crossecore

import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*

class UtilsTest {


	@Test def void testIsEcoreEPackage() {
		var result = Utils.isEcoreEPackage(EcorePackage.eINSTANCE)
		assertTrue(result)
		
		val result2 = Utils.isEcoreEPackage(EcoreFactory.eINSTANCE.createEPackage())
		assertFalse(result2)
	}


	
	
}