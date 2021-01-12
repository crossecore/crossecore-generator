package com.crossecore

import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Before
import org.junit.Test
import static org.junit.Assert.assertNotEquals
import static org.junit.Assert.assertEquals
import org.eclipse.emf.ecore.EClass

class DependencyManagerTest {
	
	private EPackage epackage;
	private EClass root;
	private EClass subtype;
	
	@Before def void setup(){
		
		val fac = EcoreFactory.eINSTANCE;
		epackage = fac.createEPackage();
		
		root = fac.createEClass();
		root.name = "Root"
		subtype = fac.createEClass();
		subtype.name = "Subtype"
		subtype.ESuperTypes.add(root)
		
		epackage.EClassifiers.add(root)
		epackage.EClassifiers.add(subtype)
	}
	
	@Test def void testSortEClasses() {
		val list = DependencyManager.sortEClasses(epackage)
		
		assertEquals(2, list.size)
		assertEquals(root, list.get(0))
		assertEquals(subtype, list.get(1))
	
	}



}
