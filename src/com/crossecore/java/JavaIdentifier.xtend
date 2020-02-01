package com.crossecore.java

import org.eclipse.emf.ecore.EObject
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EStructuralFeature

class JavaIdentifier extends IdentifierProvider {
	
	
	
	override escapeKeyword(String identifier) {
		switch(identifier){
			case "object",
			case "volatile",
			case "package",
			case "abstract",
			case "interface": return identifier+"_"
			default: return identifier
			
		}
	}
	
	public def escapeIdentifier(String str){
		
		var s = str;
		s = s.replace("-","_");
		s = s.replace("/","_");
		return s;
	}
	
	override EObject(EObject eobject){
		
		return escapeIdentifier(super.EObject(eobject));
	}
	
	//TODO should be propagated to other languages
	override getEStructuralFeature(EStructuralFeature eStructuralFeature){
		
		if(eStructuralFeature.EType.name.equals("EBoolean")){
			return '''is«eStructuralFeature.name.toFirstUpper»'''
		}
		else{
			
			return '''get«eStructuralFeature.name.toFirstUpper»'''
		}
		
	}
	
}