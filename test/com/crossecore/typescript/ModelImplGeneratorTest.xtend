package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Test

import static org.junit.Assert.*

class ModelImplGeneratorTest {


	@Test def void test_caseEClass1() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelImplGenerator();
		
		//Action
		val result = generator.caseEClass(eclass).toString	
		//Assert
		
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/typeName")
		assertTrue("EClassImpl inherits from EClassBase", nodes.get(0).text.equals("MyClassBase"))

	}
	@Test def void test_caseEClass2() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val etypeparam = EcoreFactory.eINSTANCE.createETypeParameter()
		etypeparam.name = "T"
		eclass.ETypeParameters.add(etypeparam)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelImplGenerator();
		
		//Action
		val result = generator.caseEClass(eclass).toString	
		//Assert
		
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/typeName")
		assertTrue("EClassImpl inherits from EClassBase", nodes.get(0).text.equals("MyClassBase"))
		
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/typeParameters/typeParameterList/typeParameter")
		assertTrue("EClassImpl has generic type parameter", nodes2.get(0).text.equals("T"))

		val nodes3 = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/nestedTypeGeneric/typeGeneric/typeArgumentList/typeArgument/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")
		assertTrue("EClassImpl has generic type parameter", nodes3.get(0).text.equals("T"))


	}

	
}
