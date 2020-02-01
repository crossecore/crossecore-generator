package com.crossecore.java

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor

class FactoryGenerator extends EcoreVisitor {
	
	private IdentifierProvider id = new JavaIdentifier();
	private JavaTypeTranslator t = new JavaTypeTranslator(id);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	
	
	
	override caseEPackage (EPackage epackage) {
	
		var eclasses = epackage.EClassifiers.filter[c|c instanceof EClass].map[c|c as EClass].filter[c|!c.interface && !c.abstract];
		
		'''
		package «epackage.name»;
		public interface «id.EPackageFactory(epackage)» extends org.eclipse.emf.ecore.EFactory{
			
			«FOR EClassifier classifier: eclasses»
				«doSwitch(classifier)»
			«ENDFOR»
		}
		
		'''
	}

	override caseEClass(EClass eclass){
		if(!eclass.interface){
			'''
				«t.translateType(eclass)» «id.createEClass(eclass)»();
			'''
		}
	}
	
	
	
}