package com.crossecore.typescript

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EPackage

abstract class TypeScriptVisitor extends EcoreVisitor {
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	
}