package com.crossecore

import static org.junit.Assert.*
import java.io.File
import java.util.HashMap
import java.util.HashSet
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.impl.EcorePackageImpl
import org.junit.Ignore
import org.junit.Test
import com.crossecore.CrossEcore
import com.crossecore.EcoreLoader
import com.crossecore.Utils

class CrossEcoreTest {
	/*
	@Test def void testGenerate() {
		var CrossEcore crossecore = new CrossEcore()
		var EPackage epackage = (new EcoreLoader().load(new File("model/Ecore.ecore")) as EPackage)
		System.out.println(crossecore.generate(epackage, "EClassifierBase.cs"))
		assertNotNull(CrossEcore::generate(epackage, "EClassifier.cs"))
		assertNotNull(CrossEcore.generate(epackage, "EcorePackage.cs"))
	}

	@Test @Ignore def void test() {
		EcorePackageImpl.init()
		var HashMap<EClass, HashSet<EClass>> closure = Utils.getSubclassClosure(EcorePackage.eINSTANCE)
		var HashSet<EClass> subclasses = closure.get(EcorePackage.eINSTANCE.getEModelElement())
		System.out.println(subclasses)
	}
	*/

}
