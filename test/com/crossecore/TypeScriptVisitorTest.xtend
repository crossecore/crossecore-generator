package com.crossecore

import com.crossecore.typescript.TypeScriptVisitor
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.junit.Before
import org.junit.Test

import static org.junit.Assert.*

class TypeScriptVisitorTest {

	EPackage epackage

	@Before def void setup(){
		
		epackage = EcorePackage.eINSTANCE
	}
	
	@Test def void test_generate(){
		//Arrange
		val baseDir = "src/"
		val visitor = new TypeScriptVisitor(baseDir, epackage)
		
		//Action
		val result = visitor.generate("src/EClassImpl.ts")
		
		//Assert
		assertNotNull(result)
		assertNotEquals("", result)
		
	}
	
	@Test def void test_index() {
		//Arrange
		val baseDir = "src/"
		val visitor = new TypeScriptVisitor(baseDir, epackage)
		
		//Action
		val index = visitor.index()
		
		
		//Assert
		assertNotNull(index)
		assertTrue(index.get(EcorePackage.eINSTANCE)
			.containsAll(#[
			"src/EcoreFactory.ts", 
			"src/EcoreFactoryImpl.ts", 
			"src/EcorePackage.ts", 
			"src/EcorePackageImpl.ts", 
			"src/EcorePackageLiterals.ts",
			"src/EcoreSwitch.ts",
			"src/tsconfig.json",
			"src/package.json"
			]))
		
		assertNotNull(index.get(EcorePackage.Literals.EOBJECT))
		assertTrue(index.get(EcorePackage.Literals.EOBJECT)
			.containsAll(#[
			"src/EObject.ts", 
			"src/EObjectBase.ts", 
			"src/EObjectImpl.ts"
			])
		)
			
	}
	
	
	
}