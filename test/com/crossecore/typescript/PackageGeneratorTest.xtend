package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*

class PackageGeneratorTest {

	
	@Test def void test_caseEPackage3() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eenum = EcoreFactory.eINSTANCE.createEEnum();
		eenum.name = "MyEnum"
		
		epackage.EClassifiers.add(eenum)
		
		val generator = new PackageGenerator("","",epackage);
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature/propertyName/identifierName")	
		assertTrue(nodes.get(0).text.equals("getMyEnum"))	

		val nodes2 = AntlrTestUtil.xpath(result, "//methodSignature/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")	
		assertTrue(nodes2.get(0).text.equals("EEnum"))	
		
	}
	@Test def void test_caseEPackage4() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDataType"
		edatatype.instanceClassName = "java.lang.String"
		
		epackage.EClassifiers.add(edatatype)
		
		val generator = new PackageGenerator("","",epackage);
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature/propertyName/identifierName")	
		assertTrue(nodes.get(0).text.equals("getMyDataType"))	

		val nodes2 = AntlrTestUtil.xpath(result, "//methodSignature/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")	
		assertTrue(nodes2.get(0).text.equals("EDataType"))	
		
	}

	@Test def void test_caseEPackage5() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageGenerator("","",epackage);
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature/propertyName/identifierName")	
		assertTrue(nodes.exists[n|n.text.equals("getMyClass_Attribute")])	

		val nodes2 = AntlrTestUtil.xpath(result, "//methodSignature/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")	
		assertTrue(nodes2.exists[n|n.text.equals("EAttribute")])	
		
	}

	@Test def void test_caseEPackage6() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val referencetype = EcoreFactory.eINSTANCE.createEClass();
		referencetype.name = "ReferenceType"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "reference"
		ereference.EType = referencetype
		
		eclass.EStructuralFeatures.add(ereference)
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencetype)
		
		val generator = new PackageGenerator("","",epackage);
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature/propertyName/identifierName")	
		assertTrue(nodes.exists[n|n.text.equals("getMyClass_Reference")])	

		val nodes2 = AntlrTestUtil.xpath(result, "//methodSignature/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")	
		assertTrue(nodes2.exists[n|n.text.equals("EReference")])	
		
	}


	@Test def void test_caseEPackage() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageGenerator("","",epackage);
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature/propertyName/identifierName")	
		assertTrue(nodes.get(0).text.equals("getMyClass"))	

		val nodes2 = AntlrTestUtil.xpath(result, "//methodSignature/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")	
		assertTrue(nodes2.get(0).text.equals("EClass"))	
		
	}


	
}
