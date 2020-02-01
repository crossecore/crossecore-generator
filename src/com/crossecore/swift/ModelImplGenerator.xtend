package com.crossecore.swift;

import com.crossecore.DependencyManager
import com.crossecore.EcoreVisitor
import com.crossecore.Utils
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter

class ModelImplGenerator extends EcoreVisitor{
	
	private SwiftIdentifier id = new SwiftIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		//var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		//eclassifiers.removeAll(sortedEClasses);
		
		for(EClass eclass : sortedEClasses){
			
			var contents = 	
				'''
				«IF !Utils.isEcoreEPackage(epackage)»
			 	using Ecore;
			 	«ENDIF»
				«doSwitch(eclass)»
			'''
			
			write(eclass, contents, false);
		}
	
		return "";
	
	}
	
	override write(){
		doSwitch(epackage);
	}
	
	override caseEClass(EClass e) 
	{
		if(!e.interface){

			'''
			class «id.EClassImpl(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			: «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				//implement your generated class here	
			}
			'''
		
		}
	}
	

}