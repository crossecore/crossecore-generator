package com.crossecore.typescript

import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Test

import static org.junit.Assert.*
import org.eclipse.emf.ecore.EDataType
import org.eclipse.ocl.ecore.CollectionType

class TypeScriptTypeTranslatorTest
 {


	@Test def void test_translateType() {
		
		//Arrange
		
		val edatatypes = org.eclipse.emf.ecore.EcorePackage.eINSTANCE.EClassifiers.filter[c|c instanceof EDataType]
		val tt = new TypeScriptTypeTranslator2()
				
		//Action
		for(dt : edatatypes){
			val result = tt.translateType(dt)
			//Assert
			assertTrue(!result.equals(""))
			assertTrue(!result.equals("void"))		
		}
	}
	@Test def void test_translateType2() {
		
		//Arrange
		org.eclipse.ocl.xtext.oclinecore.OCLinEcoreStandaloneSetup.doSetup()
		val tt = new TypeScriptTypeTranslator2()
				
		//Action
		val orderedset_ = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createOrderedSetType()
		orderedset_.elementType = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createPrimitiveType()
		orderedset_.elementType.name = "Integer"
		val orderedset = tt.translateType(orderedset_)
		
		val sequence_ = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createSequenceType()
		sequence_.elementType = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createPrimitiveType()
		sequence_.elementType.name = "String"
		val sequence = tt.translateType(sequence_)
		
		val bag_ = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createBagType()
		bag_.elementType = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createPrimitiveType
		bag_.elementType.name = "Real"
		val bag = tt.translateType(bag_)
		
		val set_ = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createSetType()
		set_.elementType = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createPrimitiveType
		set_.elementType.name = "Boolean"
		val set = tt.translateType(set_)
		
		val set__ = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createSetType()
		set__.elementType = org.eclipse.ocl.ecore.EcoreFactory.eINSTANCE.createAnyType()
		val any = tt.translateType(set__)
		
		//Assert
		assertTrue(orderedset.equals("OrderedSet<number>"))
		assertTrue(sequence.equals("Sequence<string>"))
		assertTrue(bag.equals("Bag<number>"))
		assertTrue(set.equals("Set<boolean>"))
		assertTrue(any.equals("Set<any>"))
		
	}
	
	@Test def void test_listType() {

		//Arrange
		val tt = new TypeScriptTypeTranslator2()
				
		//Action
		val bag = tt.listType(false, false)	
		val sequence = tt.listType(false, true)	
		val set = tt.listType(true, false)	
		val orderedset = tt.listType(true, true)
		
		//Assert
		assertTrue(bag.equals("Bag"))
		assertTrue(sequence.equals("Sequence"))
		assertTrue(set.equals("Set"))
		assertTrue(orderedset.equals("OrderedSet"))	
	}
	
	@Test def void test_defaultValue() {
		
		
		//Arrange
		
		val edatatypes = org.eclipse.emf.ecore.EcorePackage.eINSTANCE.EClassifiers.filter[c|c instanceof EDataType]
		val tt = new TypeScriptTypeTranslator2()
		
		//Action
		for(dt : edatatypes){
			val result = tt.defaultValue(dt)
			//Assert
			assertTrue(!result.equals(""))
		}
	}
	
	
}
