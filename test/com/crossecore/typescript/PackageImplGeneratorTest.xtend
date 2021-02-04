package com.crossecore.typescript

import antlr.typescript.TypeScriptLexer
import antlr.typescript.TypeScriptParser
import com.crossecore.TreeUtils
import java.util.Arrays
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.xpath.XPath
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*
import com.crossecore.AntlrTestUtil

class PackageImplGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		val supertype = EcoreFactory.eINSTANCE.createEClass();
		supertype.name = "Supertype"
		
		epackage.EClassifiers.add(supertype)
		
		eclass.ESuperTypes.add(supertype)
		
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
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name ="ereference"
		ereference.EType = eclass
		eclass.EStructuralFeatures.add(ereference)
		
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
		
		
		val einterface = EcoreFactory.eINSTANCE.createEClass();
		einterface.name = "MyInterface"
		einterface.interface = true
		epackage.EClassifiers.add(einterface)
		
		val abstractclass = EcoreFactory.eINSTANCE.createEClass();
		abstractclass.name = "MyAbstractClass"
		abstractclass.interface = true
		abstractclass.abstract = true
		epackage.EClassifiers.add(abstractclass)
		
		
		val edatatype = EcoreFactory.eINSTANCE.createEDataType();
		edatatype.name = "MyDatatype"
		edatatype.instanceClassName = "java.util.String"
		
		epackage.EClassifiers.add(edatatype)
		
		val eenum = EcoreFactory.eINSTANCE.createEEnum()
		eenum.name = "MyEnum"
		
		val literal = EcoreFactory.eINSTANCE.createEEnumLiteral()
		literal.name = "EINS"
		literal.value = 1
		eenum.ELiterals.add(literal)
		
		epackage.EClassifiers.add(eenum)
		
	}

	@Test def void test_caseEPackage() {
		
		//Arrange
		val generator = new PackageImplGenerator();
		
		//Action
		val result = generator.caseEPackage(epackage).toString()
		//System.out.println(result)
		
		//Assert
		//https://github.com/antlr/antlr4/blob/master/doc/tree-matching.md
		
		val xpath = "//methodSignature";
		val lexer = new TypeScriptLexer(CharStreams.fromString(result));
		val tokens = new CommonTokenStream(lexer);
		val parser = new TypeScriptParser(tokens);
		
		
		
		parser.setBuildParseTree(true);
		val tree = parser.program();
		val ruleNamesList = Arrays.asList(parser.getRuleNames());
		val prettyTree = TreeUtils.toPrettyTree(tree, ruleNamesList);
		//System.out.println(prettyTree)
		
		val x = XPath.findAll(tree, xpath, parser).toSet;
		
		assertTrue(true)

		
	}

	@Test def void test_caseEPackage2() {
		
		//Arrange
		
		val epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		
		epackage.EClassifiers.add(eclass)
		
		val generator = new PackageImplGenerator();

		//Action
		val result = generator.caseEPackage(epackage).toString
		System.out.println(result)
		
		//Assert
		assertTrue(result.contains("this.createEClass(MyPackagePackageImpl.MYCLASS)"))		
		
	}
	
}
