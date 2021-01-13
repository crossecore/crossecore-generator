package com.crossecore

import static org.junit.Assert.*
import org.junit.Test
import com.crossecore.typescript.FactoryGenerator
import org.eclipse.emf.ecore.EcoreFactory
import org.junit.Before
import org.eclipse.emf.ecore.EPackage
import org.antlr.v4.runtime.tree.xpath.XPath
import antlr.typescript.TypeScriptParser
import org.antlr.v4.runtime.ANTLRInputStream
import antlr.typescript.TypeScriptLexer
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.CharStreams
import org.eclipse.emf.ecore.EcorePackage

class UtilsTest {


	@Test def void testIsEcoreEPackage() {
		var result = Utils.isEcoreEPackage(EcorePackage.eINSTANCE)
		assertTrue(result)
		
		val result2 = Utils.isEcoreEPackage(EcoreFactory.eINSTANCE.createEPackage())
		assertFalse(result2)
	}


	
	
}