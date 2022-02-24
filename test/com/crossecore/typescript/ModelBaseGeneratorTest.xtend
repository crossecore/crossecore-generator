package com.crossecore.typescript

import antlr.typescript.TypeScriptLexer
import antlr.typescript.TypeScriptParser
import com.crossecore.TreeUtils
import java.util.Arrays
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.xpath.XPath
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.util.Diagnostician
import org.junit.Before
import org.junit.Test
import com.crossecore.AntlrTestUtil
import static org.junit.Assert.*

class ModelBaseGeneratorTest {

	EPackage epackage
	static String PIVOT = "http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot"



	
	@Test def void test_caseEClass2() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/typeName")
		assertTrue(nodes.get(0).text.equals("BasicEObjectImpl"))
		
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/implementsClause/classOrInterfaceTypeList/typeReference/typeName")
		assertTrue(nodes2.get(0).text.equals("MyClass"))
	}

	@Test def void test_caseEClass3() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val interface = EcoreFactory.eINSTANCE.createEClass();
		interface.name = "Interface"
		interface.interface = true
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(interface)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/typeName")
		assertTrue(nodes.get(0).text.equals("BasicEObjectImpl"))
		
	}
	@Test def void test_caseEClass4() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val superclass = EcoreFactory.eINSTANCE.createEClass();
		superclass.name = "Superclass"
		
		eclass.ESuperTypes.add(superclass)
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(superclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classHeritage/classExtendsClause/typeReference/typeName")
		assertTrue(nodes.get(0).text.equals("SuperclassImpl"))
		
	}
	
	@Test def void test_caseEClass5() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val etypeparameter = EcoreFactory.eINSTANCE.createETypeParameter
		etypeparameter.name = "T"
		
		eclass.ETypeParameters.add(etypeparameter)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/typeParameters/typeParameterList/typeParameter")
		assertTrue(nodes.get(0).text.equals("T"))
		
	}

	@Test def void test_caseEClass6() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("_attribute")])
			
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/getter/propertyName/identifierName")
		assertTrue(nodes2.exists[n|n.text.equals("attribute")])
		
	}
	/*
	@Test def void test_caseEClass7() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val classa_derivedoclattribute = EcoreFactory.eINSTANCE.createEAttribute()
		classa_derivedoclattribute.name = "derivedOclAttributeSingle"
		classa_derivedoclattribute.derived = true
		classa_derivedoclattribute.EType = EcorePackage.Literals.ESTRING
		val eannotation = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation.source = PIVOT
		eannotation.details.put("derivation", "'hi'")
		classa_derivedoclattribute.EAnnotations.add(eannotation)
		eclass.EStructuralFeatures.add(classa_derivedoclattribute)
		
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/literal")
		assertTrue(nodes.exists[n|n.text.equals("\"hi\"")])
		
	}
	*/
	
	/*
@Test def void test_caseEClass99() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val classa_derivedoclattribute = EcoreFactory.eINSTANCE.createEAttribute()
		classa_derivedoclattribute.name = "derivedOclAttributeSingle"
		classa_derivedoclattribute.derived = true
		classa_derivedoclattribute.upperBound = -1
		classa_derivedoclattribute.EType = EcorePackage.Literals.ESTRING
		val eannotation = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation.source = PIVOT
		eannotation.details.put("derivation", "OrderedSet{'hi','tschuess'}")
		classa_derivedoclattribute.EAnnotations.add(eannotation)
		eclass.EStructuralFeatures.add(classa_derivedoclattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/block/statementList/statement/expressionStatement/expressionSequence/singleExpression/literal")
		assertTrue(nodes.get(0).text.equals("\"hi\""))
		assertTrue(nodes.get(1).text.equals("\"tschuess\""))
	}
	*/

	@Test def void test_caseEClass8() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.upperBound = -1
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")
		assertTrue(nodes.get(0).text.equals("OrderedSet"))
	}

	@Test def void test_caseEClass9() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.changeable = false
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//setter")
		assertTrue(nodes.size===0)
	}
	
	@Test def void test_caseEClass10() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.changeable = false
		eattribute.upperBound = -1
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//setter")
		assertTrue(nodes.size===0)
	}
	@Test def void test_caseEClass11() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.derived = true
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		eclass.EStructuralFeatures.add(eattribute)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/identifierName/reservedWord")
		assertTrue(nodes.get(0).text.equals("null"))
	}
	
	@Test def void test_caseEClass12() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation"
		
		eclass.EOperations.add(eoperation)
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.get(0).text.equals("operation"))

		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/predefinedType")
		assertTrue(nodes2.get(0).text.equals("void"))
	}
	
	@Test def void test_caseEClass13() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation"
		eoperation.EType = EcorePackage.Literals.ESTRING
		
		eclass.EOperations.add(eoperation)
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.get(0).text.equals("operation"))
		
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/predefinedType")
		assertTrue(nodes2.get(0).text.equals("string"))
	}
	
	@Test def void test_caseEClass14() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation"
		
		val param = EcoreFactory.eINSTANCE.createEParameter()
		param.name = "p"
		param.EType = EcorePackage.Literals.ESTRING
		
		eoperation.EParameters.add(param)
		eclass.EOperations.add(eoperation)
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.get(0).text.equals("operation"))
		
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/callSignature/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/predefinedType")
		assertTrue(nodes2.get(0).text.equals("void"))
		
		val nodes3 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/callSignature/parameterList/parameter/requiredParameter/identifierOrPattern/identifierName")
		assertTrue(nodes3.get(0).text.equals("p"))
	}
	
	@Test def void test_caseEClass15() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation"
		
		val eannotation4 = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation4.source = PIVOT
		eannotation4.details.put("body", "'hi'")
		eoperation.EAnnotations.add(eannotation4)
		
		eclass.EOperations.add(eoperation)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/literal")
		assertTrue(nodes.get(0).text.equals("'hi'"))
	}
	@Test def void test_caseEClass16() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val operation1 = EcoreFactory.eINSTANCE.createEOperation()
		operation1.name = "operation_overload"
		
		val classa_operation_param1 = EcoreFactory.eINSTANCE.createEParameter()
		classa_operation_param1.name = "p1"
		classa_operation_param1.EType = EcorePackage.Literals.ESTRING
		operation1.EParameters.add(classa_operation_param1)
		
		val operation2 = EcoreFactory.eINSTANCE.createEOperation()
		operation2.name = "operation_overload"
		operation2.EType = EcorePackage.Literals.ESTRING

		val classa_operation2_param1 = EcoreFactory.eINSTANCE.createEParameter()
		classa_operation2_param1.name = "p1"
		classa_operation2_param1.EType = EcorePackage.Literals.EINT
		operation2.EParameters.add(classa_operation2_param1)
		
		eclass.EOperations.add(operation2)
		eclass.EOperations.add(operation1)
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("operation_overload_EInt")])
		assertTrue(nodes.exists[n|n.text.equals("operation_overload_EString")])
		assertTrue(nodes.exists[n|n.text.equals("operation_overload")])
	}
	
	@Test def void test_caseEClass17() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "reference"
		ereference.EType = referencedType
		eclass.EStructuralFeatures.add(ereference)
		
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("_reference")])
			
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/getter/propertyName/identifierName")
		assertTrue(nodes2.exists[n|n.text.equals("reference")])
	
	}
	@Test def void test_caseEClass18() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "reference"
		ereference.EType = referencedType
		ereference.upperBound = -1
		eclass.EStructuralFeatures.add(ereference)
		
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("_reference")])
			
		val nodes2 = AntlrTestUtil.xpath(result, "//classDeclaration/classTail/classElement/propertyMemberDeclaration/getAccessor/getter/propertyName/identifierName")
		assertTrue(nodes2.exists[n|n.text.equals("reference")])
	
	}
	/*
	@Test def void test_caseEClass19() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val reference = EcoreFactory.eINSTANCE.createEReference()
		reference.name = "reference"
		reference.derived = true
		reference.EType = referencedType
		val eannotation2 = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation2.source = PIVOT
		eannotation2.details.put("derivation", "null")
		reference.EAnnotations.add(eannotation2)
		eclass.EStructuralFeatures.add(reference)
		
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/identifierName/reservedWord")
		assertTrue(nodes.get(0).text.equals("null"))	
	
	}
	*/

	/*
	@Test def void test_caseEClass20() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val reference = EcoreFactory.eINSTANCE.createEReference()
		reference.name = "reference"
		reference.derived = true
		reference.EType = referencedType
		reference.upperBound = -1
		val eannotation2 = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation2.source = PIVOT
		eannotation2.details.put("derivation", "OrderedSet{}")
		reference.EAnnotations.add(eannotation2)
		eclass.EStructuralFeatures.add(reference)
		
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classTail/classElement/propertyMemberDeclaration/getAccessor/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")
		assertTrue(nodes.get(0).text.equals("OrderedSet"))
	
		val nodes2 = AntlrTestUtil.xpath(result, "//classTail/classElement/propertyMemberDeclaration/getAccessor/typeAnnotation/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/nestedTypeGeneric/typeGeneric/typeArgumentList/typeArgument/type_/unionOrIntersectionOrPrimaryType/primaryType/typeReference/typeName")
		assertTrue(nodes2.get(0).text.equals("Reference"))
	}
	*/

	@Test def void test_caseEClass21() {
		
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		
		val ereference_map = EcoreFactory.eINSTANCE.createEReference()
		ereference_map.name = "referenceMap"
		ereference_map.EType = EcorePackage.Literals.ESTRING_TO_STRING_MAP_ENTRY
		ereference_map.upperBound = -1
		ereference_map.containment = true
		eclass.EStructuralFeatures.add(ereference_map)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		//TODO grammar does not allow this valid TypeScript cast: (<EcoreEMap<string, string>>this.referenceMap).set(newValue);
	
	}

	@Test def void test_caseEClass22() {
		
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val erference = EcoreFactory.eINSTANCE.createEReference()
		erference.name = "reference"
		erference.EType = referencedType
		erference.derived = true
		eclass.EStructuralFeatures.add(erference)
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/identifierName/reservedWord")
		assertTrue(nodes.get(0).text.equals("null"))
	}
	
	
	@Test def void test_caseEClass23() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "reference"
		ereference.EType = referencedType
		ereference.derived = true
		ereference.upperBound = -1
		eclass.EStructuralFeatures.add(ereference)
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/getAccessor/functionBody/sourceElements/sourceElement/statement/returnStatement/expressionSequence/singleExpression/identifierName/reservedWord")
		assertTrue(nodes.get(0).text.equals("null"))
	}
	
	@Test def void test_caseEClass24() {
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"

		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "Reference"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "reference"
		ereference.EType = referencedType
		ereference.containment = true
		eclass.EStructuralFeatures.add(ereference)
		
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(referencedType)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/setAccessor/setter/propertyName/identifierName")
		assertTrue(nodes.get(0).text.equals("reference"))
	}
	
	@Test def void test_caseEClass25() {
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val classA = EcoreFactory.eINSTANCE.createEClass();
		classA.name = "ClassA"

		val classB = EcoreFactory.eINSTANCE.createEClass();
		classB.name = "ClassB"
		
		val refA = EcoreFactory.eINSTANCE.createEReference()
		refA.name = "classA"
		refA.EType = classB
		refA.containment = true
		
		classB.EStructuralFeatures.add(refA)

		val refB = EcoreFactory.eINSTANCE.createEReference()
		refB.name = "classB"
		refB.EType = classB
		refB.containment = true
		refB.EOpposite = refA
		classA.EStructuralFeatures.add(refB)
		
		epackage.EClassifiers.add(classA)
		epackage.EClassifiers.add(classB)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(classA).toString()
		System.out.println(result)
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("basicSetClassB")])
	}

	@Test def void test_caseEClass28() {
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val classA = EcoreFactory.eINSTANCE.createEClass();
		classA.name = "ClassA"

		val classB = EcoreFactory.eINSTANCE.createEClass();
		classB.name = "ClassB"
		
		val refA = EcoreFactory.eINSTANCE.createEReference()
		refA.name = "classA"
		refA.EType = classB
		classB.EStructuralFeatures.add(refA)

		val refB = EcoreFactory.eINSTANCE.createEReference()
		refB.name = "classB"
		refB.EType = classB
		refB.EOpposite = refA
		classA.EStructuralFeatures.add(refB)
		
		epackage.EClassifiers.add(classA)
		epackage.EClassifiers.add(classB)
		
		val generator = new ModelBaseGenerator("","",epackage);
		
		//Action
		val result = generator.caseEClass(classA).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("eInverseAdd")])
		assertTrue(nodes.exists[n|n.text.equals("eInverseRemove")])
	}

	@Test def void test_caseEClass26() {
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val classA = EcoreFactory.eINSTANCE.createEClass();
		classA.name = "ClassA"

		val classB = EcoreFactory.eINSTANCE.createEClass();
		classB.name = "ClassB"
		
		val classC = EcoreFactory.eINSTANCE.createEClass();
		classC.name = "ClassC"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING
		
		classC.EStructuralFeatures.add(eattribute)
		
		classA.ESuperTypes.add(classB)
		classA.ESuperTypes.add(classC)
		
		epackage.EClassifiers.add(classA)
		epackage.EClassifiers.add(classB)
		epackage.EClassifiers.add(classC)
		
		val generator = new ModelBaseGenerator("","",epackage);
		

		//Action
		val result = generator.caseEClass(classA).toString()
		System.out.println(result)
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("eBaseStructuralFeatureID")])
		assertTrue(nodes.exists[n|n.text.equals("eDerivedStructuralFeatureID_number_Function")])
	}
	
	@Test def void test_caseEClass27() {
		
		
		//Arrange
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eannotation = EcoreFactory.eINSTANCE.createEAnnotation()
		eannotation.source = PIVOT
		eannotation.details.put("invariant", "true")
		eclass.EAnnotations.add(eannotation)

		epackage.EClassifiers.add(eclass)
		
		val generator = new ModelBaseGenerator("","",epackage);

		//Action
		val result = generator.caseEClass(eclass).toString()
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//classElement/propertyMemberDeclaration/propertyName/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("invariant")])
	}	
	
	
	
	
}
