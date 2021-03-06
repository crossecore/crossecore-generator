package com.crossecore.typescript

import com.crossecore.AntlrTestUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Test

import static org.junit.Assert.*

class PackageImplGeneratorTest {


	@Test def void test_caseEPackage2() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val abstractclass = EcoreFactory.eINSTANCE.createEClass();
		abstractclass.name = "MyAbstractClass"
		abstractclass.interface = true
		abstractclass.abstract = true
		
		val enum = EcoreFactory.eINSTANCE.createEEnum();
		enum.name = "MyEnum"
		
		val literal = EcoreFactory.eINSTANCE.createEEnumLiteral()
		literal.name = "EINS"
		literal.value = 1
		enum.ELiterals.add(literal)

		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDataType"
		
		epackage.EClassifiers.add(abstractclass)
		epackage.EClassifiers.add(eclass)
		epackage.EClassifiers.add(enum)
		epackage.EClassifiers.add(edatatype)
		
		val generator = new PackageImplGenerator("","",epackage);

		//Action
		val result = generator.caseEPackage(epackage).toString
		System.out.println(result)
		
		//Assert
		assertTrue(result.contains("this.createEClass(MyPackagePackageImpl.MYCLASS)"))
		assertTrue(result.contains("this.createEEnum(MyPackagePackageImpl.MYENUM)"))	
		assertTrue(result.contains("this.createEDataType(MyPackagePackageImpl.MYDATATYPE)"))		
		assertTrue(result.contains("this.createEClass(MyPackagePackageImpl.MYABSTRACTCLASS)"))		
		
	}
	
	@Test def void test_caseEPackage3() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name ="attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING;
		eattribute.transient = true
		eattribute.volatile = true
		eattribute.changeable = true
		eattribute.unsettable = true
		eattribute.ID = true
		eattribute.unique = true
		eattribute.derived = true
		eattribute.ordered = true
		eclass.EStructuralFeatures.add(eattribute)
		
		val eattribute2 = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute2.name ="attribute_with_default"
		eattribute2.EType = EcorePackage.Literals.ESTRING;
		eattribute2.defaultValue = "hello"
		eattribute2.transient = false
		eattribute2.volatile = false
		eattribute2.changeable = false
		eattribute2.unsettable = false
		eattribute2.ID = false
		eattribute2.unique = false
		eattribute2.derived = false
		eattribute2.ordered = false
		eclass.EStructuralFeatures.add(eattribute2)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageImplGenerator("","",epackage);

		//Action
		val result = generator.caseEPackage(epackage).toString
		
		//Assert
		assertTrue(result.contains("this.createEAttribute(this.MyClassEClass, MyPackagePackageImpl.MY_CLASS__ATTRIBUTE);"))
		assertTrue(result.contains("this.createEAttribute(this.MyClassEClass, MyPackagePackageImpl.MY_CLASS__ATTRIBUTE_WITH_DEFAULT);"))
		
	}
	
	@Test def void test_caseEPackage44() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name ="reference"
		ereference.EType = eclass
		eclass.EStructuralFeatures.add(ereference)
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageImplGenerator("","",epackage);

		//Action
		val result = generator.caseEPackage(epackage).toString
		System.out.println(result)
		
		//Assert
		assertTrue(result.contains("this.createEReference(this.MyClassEClass, MyPackagePackageImpl.MY_CLASS__REFERENCE);"))
		
	}

	@Test def void test_caseEPackage4() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation"
		eoperation.unique = true
		eoperation.ordered = true
		eclass.EOperations.add(eoperation)
		
		val param = EcoreFactory.eINSTANCE.createEParameter()
		param.name = "p"
		param.EType = EcorePackage.Literals.ESTRING
		eoperation.EParameters.add(param)		
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageImplGenerator("","",epackage);

		//Action
		val result = generator.caseEPackage(epackage).toString
		
		//Assert
		assertTrue(result.contains("this.createEOperation(this.MyClassEClass, MyPackagePackageImpl.MYCLASS___OPERATION__P);"))
		
	}

	@Test def void test_caseEPackage34() {
		
		//Arrange
		val generator = new PackageImplGenerator("","",EcorePackage.eINSTANCE);

		//Action
		val result = generator.caseEPackage(EcorePackage.eINSTANCE).toString
		
		//Assert
		val nodes = AntlrTestUtil.xpath(result, "//importStatement/fromBlock/multipleImportStatement/identifierName")
		assertTrue(nodes.exists[n|n.text.equals("EcoreFactoryImpl")])
		
	}
	
}
