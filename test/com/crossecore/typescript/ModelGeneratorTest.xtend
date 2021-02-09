package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*

class ModelGeneratorTest {

	
	@Test def void test_caseEClassx() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation_overload"
		eoperation.EType = EcorePackage.Literals.ESTRING
		
		val eparam1 = EcoreFactory.eINSTANCE.createEParameter()
		eparam1.name = "p1"
		eparam1.EType = EcorePackage.Literals.ESTRING
		eoperation.EParameters.add(eparam1)

		val eoperation2 = EcoreFactory.eINSTANCE.createEOperation()
		eoperation2.name = "operation_overload"
		eoperation2.EType = EcorePackage.Literals.ESTRING

		eclass.EOperations.add(eoperation)
		eclass.EOperations.add(eoperation2)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//methodSignature")
		assertTrue("Class should have 2 overloaded operations and 1 generic delegating operation", nodes.size===3)
		
	}
	
	@Test def void test_caseEClassy() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/interfaceExtendsClause/classOrInterfaceTypeList/typeReference/typeName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass with no supertypes extends InternalEObject", nodes.get(0).text.equals("InternalEObject"))
		
	}
	@Test def void test_caseEClassz() {
		
		//Arrange
		
		val modelGenerator = new ModelGenerator("","",EcorePackage.eINSTANCE);
		
		//Action
		val result = modelGenerator.caseEClass(EcorePackage.Literals.EOBJECT).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/interfaceExtendsClause/classOrInterfaceTypeList/typeReference/typeName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EObject extends Notifier", nodes.get(0).text.equals("Notifier"))
		
	}
	@Test def void test_caseEClassz2() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val supertype = EcoreFactory.eINSTANCE.createEClass();
		supertype.name = "SuperType"
		epackage.EClassifiers.add(supertype)
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		eclass.ESuperTypes.add(supertype)
		epackage.EClassifiers.add(eclass)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(EcorePackage.Literals.EOBJECT).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/interfaceExtendsClause/classOrInterfaceTypeList")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass with supertype extends supertype interface", nodes.size===1)	
	}
	
	@Test def void test_caseEClassz3() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val supertype = EcoreFactory.eINSTANCE.createEClass();
		supertype.name = "SuperType"
		epackage.EClassifiers.add(supertype)
		
		val supertype2 = EcoreFactory.eINSTANCE.createEClass();
		supertype2.name = "SuperType2"
		epackage.EClassifiers.add(supertype2)
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		eclass.ESuperTypes.add(supertype)
		eclass.ESuperTypes.add(supertype2)
		epackage.EClassifiers.add(eclass)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/interfaceExtendsClause/classOrInterfaceTypeList/typeReference")
		assertTrue("Interface for EClass with supertypes extends supertype interfaces", nodes.size==2)
	}
	
	@Test def void test_caseEClassz4() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val attribute = EcoreFactory.eINSTANCE.createEAttribute;
		attribute.name = "attribute"
		attribute.EType = EcorePackage.Literals.ESTRING
		eclass.EStructuralFeatures.add(attribute)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/objectType/typeBody/typeMemberList/typeMember/propertySignatur/propertyName/identifierName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass has EAttribute", nodes.get(0).text.equals("attribute"))
		
	}
	
	@Test def void test_caseEClassz99() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val attribute = EcoreFactory.eINSTANCE.createEAttribute;
		attribute.name = "attribute"
		attribute.EType = EcorePackage.Literals.ESTRING
		attribute.upperBound = -1
		eclass.EStructuralFeatures.add(attribute)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/objectType/typeBody/typeMemberList/typeMember/propertySignatur/propertyName/identifierName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass has EAttribute", nodes.get(0).text.equals("attribute"))
		
	}
	
	@Test def void test_caseEClassz89() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val reference = EcoreFactory.eINSTANCE.createEReference;
		reference.name = "reference"
		reference.EType = EcorePackage.Literals.ESTRING_TO_STRING_MAP_ENTRY
		reference.containment = true
		
		eclass.EStructuralFeatures.add(reference)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/objectType/typeBody/typeMemberList/typeMember/propertySignatur/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")
		assertTrue("EClass has EMap", nodes.get(0).text.equals("EMap"))
		
		val nodes2 = AntlrTestUtil.xpath(result, "//predefinedType")
		assertTrue(nodes2.size===2)
		assertTrue(nodes2.get(0).text.equals("string"))
		assertTrue(nodes2.get(1).text.equals("string"))
	}
	
	@Test def void test_caseEClassz5() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "ReferenceType"
		epackage.EClassifiers.add(referencedType)
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val reference = EcoreFactory.eINSTANCE.createEReference;
		reference.name = "reference"
		reference.EType = referencedType
		eclass.EStructuralFeatures.add(reference)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/objectType/typeBody/typeMemberList/typeMember/propertySignatur/propertyName/identifierName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass has EReference", nodes.get(0).text.equals("reference"))
		
	}
	
	@Test def void test_caseEClassz6() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "ReferenceType"
		epackage.EClassifiers.add(referencedType)
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val reference = EcoreFactory.eINSTANCE.createEReference;
		reference.name = "reference"
		reference.EType = referencedType
		reference.upperBound = -1
		eclass.EStructuralFeatures.add(reference)
		
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//interfaceDeclaration/objectType/typeBody/typeMemberList/typeMember/propertySignatur/propertyName/identifierName")
		assertTrue(nodes.size===1)
		assertTrue("Interface for EClass has EReference", nodes.get(0).text.equals("reference"))
		
	}


	
	@Test def void test_caseEEnum(){
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eenum = EcoreFactory.eINSTANCE.createEEnum();
		eenum.name = "MyEnum"
		
		val literal1 = EcoreFactory.eINSTANCE.createEEnumLiteral();
		literal1.name = "LITERAL"
		literal1.value = 3
		
		epackage.EClassifiers.add(eenum)
		val modelGenerator = new ModelGenerator("","",epackage);
		
		//Action
		val result = modelGenerator.caseEEnum(eenum).toString
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration")
		assertTrue("Class is generated from EEnum ", nodes.size===1)
			
	}
	
}
