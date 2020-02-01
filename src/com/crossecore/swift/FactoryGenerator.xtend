package com.crossecore.swift

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor

class FactoryGenerator extends EcoreVisitor {
	
	private IdentifierProvider id = new SwiftIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
		
	override caseEPackage (EPackage epackage) {
		
		'''
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
		protocol «id.EPackageFactory(epackage)» : EFactory{
			
			«FOR EClassifier classifier: epackage.EClassifiers»
				«doSwitch(classifier)»
			«ENDFOR»
		}
		'''
	
	}

	
	override caseEClass(EClass eclass){
		if(!eclass.interface){
			'''
				func «id.createEClass(eclass)»() -> «id.doSwitch(eclass)»;
			'''
		}
	}
	
	
	
	
	
}