package com.crossecore.swift

import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EObject

class SwiftIdentifier extends IdentifierProvider {
	
	
	
	override escapeKeyword(String identifier) {
		
		/*
		  
		 switch(identifier){
			case "object",
			case "volatile",
			case "abstract",
			case "interface": return identifier+"_"
			default: return identifier
			
		}
		*/
		
		return identifier
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
	
	
	
}