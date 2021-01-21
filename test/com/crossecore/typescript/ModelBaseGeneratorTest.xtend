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

class ModelBaseGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		epackage.nsPrefix = "mypackage"
		
		val class_supertype = EcoreFactory.eINSTANCE.createEClass();
		class_supertype.name = "SuperType"
		epackage.EClassifiers.add(class_supertype)
		
		val class_interface = EcoreFactory.eINSTANCE.createEClass();
		class_interface.name = "SuperInterface"
		epackage.EClassifiers.add(class_interface)

		val classa = EcoreFactory.eINSTANCE.createEClass();
		classa.name = "ClassA"
		classa.ESuperTypes.add(class_supertype)
		classa.ESuperTypes.add(class_interface)
		epackage.EClassifiers.add(classa)
		
		val classb = EcoreFactory.eINSTANCE.createEClass();
		classb.name = "referencedType"
		epackage.EClassifiers.add(classb)
		
		val classb_classa_single = EcoreFactory.eINSTANCE.createEReference()
		classb_classa_single.name = "myclass_single"
		classb_classa_single.EType = classa
		classb.EStructuralFeatures.add(classb_classa_single)
		
		val classb_classa_many = EcoreFactory.eINSTANCE.createEReference()
		classb_classa_many.name = "myclass_many"
		classb_classa_many.EType = classa
		classb_classa_many.upperBound = -1
		classb.EStructuralFeatures.add(classb_classa_many)
		
		val classa_attribute = EcoreFactory.eINSTANCE.createEAttribute()
		classa_attribute.name = "attribute"
		classa_attribute.EType = EcorePackage.Literals.ESTRING
		classa.EStructuralFeatures.add(classa_attribute)
		
		val classa_attribute_many = EcoreFactory.eINSTANCE.createEAttribute()
		classa_attribute_many.name = "attribute_many"
		classa_attribute_many.EType = EcorePackage.Literals.ESTRING
		classa_attribute_many.upperBound = -1
		classa.EStructuralFeatures.add(classa_attribute_many)
		
		val classa_classb_single = EcoreFactory.eINSTANCE.createEReference()
		classa_classb_single.name = "referencedType"
		classa_classb_single.EType = classb
		classa_classb_single.EOpposite = classb_classa_single
		classa.EStructuralFeatures.add(classa_classb_single)
		
		val classa_classb_many = EcoreFactory.eINSTANCE.createEReference()
		classa_classb_many.name = "containment"
		classa_classb_many.EType = classb
		classa_classb_many.containment = true
		classa_classb_many.upperBound = -1
		classa_classb_many.EOpposite = classb_classa_many
		classa.EStructuralFeatures.add(classa_classb_many)		
				
		val classa_operation = EcoreFactory.eINSTANCE.createEOperation()
		classa_operation.name = "operation_overload"
		classa.EOperations.add(classa_operation)
		
		val classa_operation_param1 = EcoreFactory.eINSTANCE.createEParameter()
		classa_operation_param1.name = "p1"
		classa_operation_param1.EType = EcorePackage.Literals.ESTRING
		classa_operation.EParameters.add(classa_operation_param1)
		
		val classa_operation2 = EcoreFactory.eINSTANCE.createEOperation()
		classa_operation2.name = "operation_overload"
		classa_operation2.EType = EcorePackage.Literals.ESTRING
		classa.EOperations.add(classa_operation2)

		val classa_operation2_param1 = EcoreFactory.eINSTANCE.createEParameter()
		classa_operation2_param1.name = "p1"
		classa_operation2_param1.EType = EcorePackage.Literals.EINT
		classa_operation2.EParameters.add(classa_operation2_param1)
		
		val classa_operation3 = EcoreFactory.eINSTANCE.createEOperation()
		classa_operation3.name = "operation"
		classa_operation3.EType = EcorePackage.Literals.ESTRING
		classa.EOperations.add(classa_operation3)
		
//		val classa_typeparameter = EcoreFactory.eINSTANCE.createETypeParameter()
//		classa_typeparameter.name="T"
//		classa.ETypeParameters.add(classa_typeparameter)
//		epackage.EClassifiers.add(classa)
		
	}

	@Test def void test_caseEClass() {
		
		val diagnostic = Diagnostician.INSTANCE.validate(epackage)

		
		//Arrange
		val generator = new ModelBaseGenerator();
		
		//Action
		val result = generator.caseEClass(epackage.EClassifiers.findFirst[e|e instanceof EClass && e.name.equals("ClassA")] as EClass).toString()
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
		
		
	}
	
}
