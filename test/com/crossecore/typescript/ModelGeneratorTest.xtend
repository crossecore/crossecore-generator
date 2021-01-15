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
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*

class ModelGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val supertype = EcoreFactory.eINSTANCE.createEClass();
		supertype.name = "SuperType"
		epackage.EClassifiers.add(supertype)
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		eclass.ESuperTypes.add(supertype)
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
		
		val eoperation3 = EcoreFactory.eINSTANCE.createEOperation()
		eoperation3.name = "operation_void"
		eoperation3.EType = EcorePackage.Literals.ESTRING

		val eparam2 = EcoreFactory.eINSTANCE.createEParameter()
		eparam2.name = "p1"
		eparam2.EType = EcorePackage.Literals.EINT
		eoperation2.EParameters.add(eparam2)
		
		eclass.EOperations.add(eoperation)
		eclass.EOperations.add(eoperation2)	
		eclass.EOperations.add(eoperation3)
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute_string"
		eattribute.EType = EcorePackage.Literals.ESTRING
		eclass.EStructuralFeatures.add(eattribute)
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "ereference_single"
		ereference.upperBound = 1
		ereference.EType = supertype
		eclass.EStructuralFeatures.add(ereference)
				
		val ereference2 = EcoreFactory.eINSTANCE.createEReference()
		ereference2.name = "ereference_many"
		ereference2.upperBound = -1
		ereference2.EType = supertype
		eclass.EStructuralFeatures.add(ereference2)
		
		var map = EcoreFactory.eINSTANCE.createEClass()
		map.name = "StringToStringMap"
		map.instanceClassName = "java.util.Map$Entry"
		
		var key_attribute = EcoreFactory.eINSTANCE.createEAttribute()
		key_attribute.name = "key"
		key_attribute.EType = EcorePackage.Literals.ESTRING
		
		var value_attribute = EcoreFactory.eINSTANCE.createEAttribute()
		value_attribute.name = "value"
		value_attribute.EType = EcorePackage.Literals.ESTRING
		
		map.EStructuralFeatures.add(key_attribute)
		map.EStructuralFeatures.add(value_attribute)
		
		epackage.EClassifiers.add(map)
		
		val ereference3 = EcoreFactory.eINSTANCE.createEReference()
		ereference3.name = "ereference_map"
		ereference3.containment = true
		ereference3.upperBound = -1
		ereference3.EType = map
		eclass.EStructuralFeatures.add(ereference3)
	}

	@Test def void test_caseEClass() {
		
		//Arrange
		val modelGenerator = new ModelGenerator();
		
		//Action
		val result = modelGenerator.caseEClass(epackage.EClassifiers.findFirst[e|e instanceof EClass && e.name.equals("MyClass")] as EClass).toString()
		System.out.println(result)
		
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
		System.out.println(prettyTree)
		
		val x = XPath.findAll(tree, xpath, parser).toSet;
		
		assertTrue(x.size===4)
		
		val xpath2 = "//propertySignatur";
		val y = XPath.findAll(tree, xpath2, parser).toSet;
		
		System.out.println(y)
		assertTrue(y.size===4)
		
	}
	
	@Test def void test_caseEEnum(){
		
		val eenum = EcoreFactory.eINSTANCE.createEEnum();
		eenum.name = "MyEnum"
		
		val literal1 = EcoreFactory.eINSTANCE.createEEnumLiteral();
		literal1.name = "LITERAL"
		literal1.value = 3
		
		//Arrange
		val modelGenerator = new ModelGenerator();
		
		//Action
		val result = modelGenerator.caseEEnum(eenum)	
	}
	
}
