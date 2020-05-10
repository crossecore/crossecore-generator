package com.crossecore

import com.crossecore.EcoreVisitor
import java.util.List
import org.eclipse.emf.ecore.EClassifier
import java.util.Formatter
import org.eclipse.emf.ecore.EObject
import java.util.Map
import java.util.HashMap
import org.eclipse.emf.ecore.EPackage

abstract class PerClassVisitor extends EcoreVisitor {
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	abstract def List<EClassifier> getEClassifiers()
	
	override Map<EObject, List<String>> index(){
		
		val result = new HashMap<EObject, List<String>>()
		for(EClassifier eclassifier: this.EClassifiers){
			var sb = new StringBuilder();
			var formatter = new Formatter(sb);
			formatter.format(this.path+this.filenamePattern, eclassifier.name.toFirstUpper);		
			result.put(eclassifier, #[sb.toString])
			
		}	
		
		
		return result
	}
}