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

class ModelBaseGeneratorTest {

	private EPackage epackage

	@Before def void setup(){
		
		epackage = EcoreFactory.eINSTANCE.createEPackage()
		epackage.name = "MyPackage"
		epackage.nsURI = "com.mypackage"
		
		val supertype = EcoreFactory.eINSTANCE.createEClass();
		supertype.name = "SuperType"
		epackage.EClassifiers.add(supertype)
		
		val eattribute = EcoreFactory.eINSTANCE.createEAttribute()
		eattribute.name = "attribute"
		eattribute.EType = EcorePackage.Literals.ESTRING
		supertype.EStructuralFeatures.add(eattribute)
		
		val referencedType = EcoreFactory.eINSTANCE.createEClass();
		referencedType.name = "ReferencedType"
		epackage.EClassifiers.add(referencedType)
		
		val ereference2 = EcoreFactory.eINSTANCE.createEReference()
		ereference2.name = "superType"
		ereference2.EType = supertype
		referencedType.EStructuralFeatures.add(ereference2)
		
		
		val ereference = EcoreFactory.eINSTANCE.createEReference()
		ereference.name = "referencedType"
		ereference.EType = referencedType
		ereference.EOpposite = ereference2
		supertype.EStructuralFeatures.add(ereference)
		
		val eoperation = EcoreFactory.eINSTANCE.createEOperation()
		eoperation.name = "operation_overload"
		supertype.EOperations.add(eoperation)
		
		val eparam1 = EcoreFactory.eINSTANCE.createEParameter()
		eparam1.name = "p1"
		eparam1.EType = EcorePackage.Literals.ESTRING
		eoperation.EParameters.add(eparam1)
		
		val eoperation2 = EcoreFactory.eINSTANCE.createEOperation()
		eoperation2.name = "operation_overload"
		eoperation2.EType = EcorePackage.Literals.ESTRING
		supertype.EOperations.add(eoperation2)

		val eparam2 = EcoreFactory.eINSTANCE.createEParameter()
		eparam2.name = "p1"
		eparam2.EType = EcorePackage.Literals.EINT
		eoperation2.EParameters.add(eparam2)

		val superinterface = EcoreFactory.eINSTANCE.createEClass();
		superinterface.name = "SuperInterface"
		epackage.EClassifiers.add(superinterface)
		
		
		val eclass = EcoreFactory.eINSTANCE.createEClass();
		eclass.name = "MyClass"
		eclass.ESuperTypes.add(supertype)
		eclass.ESuperTypes.add(superinterface)
		
		val etypeparameter = EcoreFactory.eINSTANCE.createETypeParameter()
		etypeparameter.name="T"
		eclass.ETypeParameters.add(etypeparameter)
		epackage.EClassifiers.add(eclass)
		
	}

	@Test def void test_caseEClass() {
		
		//Arrange
		val generator = new ModelBaseGenerator();
		
		//Action
		val result = generator.caseEClass(epackage.EClassifiers.findFirst[e|e instanceof EClass && e.name.equals("MyClass")] as EClass).toString()
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
