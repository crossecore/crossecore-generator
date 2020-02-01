package com.crossecore.swift

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor

class FactoryImplGenerator extends EcoreVisitor {
	
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
		class «id.EPackageFactoryImpl(epackage)» : EFactoryImpl, «id.EPackageFactory(epackage)» {
			
			static let eINSTANCE:«id.EPackageFactory(epackage)» = «id.EPackageFactoryImpl(epackage)».init_();
			static func init_() -> «id.EPackageFactory(epackage)»
			{
				return «id.EPackageFactoryImpl(epackage)»();
			}
			«FOR EClassifier classifier: epackage.EClassifiers»
				«doSwitch(classifier)»
			«ENDFOR»
		}
		'''
	}

	
	override caseEClass(EClass e){
		if(!e.interface){
			'''
			func «id.createEClass(e)»() -> «id.doSwitch(e)»{
				let «id.variable(e)» = «id.EClassImpl(e)»();
				return «id.variable(e)»;
			}
			'''
		}
	
	}
	
	
}