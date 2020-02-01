package com.crossecore.java;

import com.crossecore.DependencyManager
import com.crossecore.Utils
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter
import com.crossecore.EcoreVisitor
import com.crossecore.csharp.CSharpOCLVisitor

class ModelImplGenerator extends EcoreVisitor{
	
	private JavaIdentifier id = new JavaIdentifier();
	//private CSharpLiteralIdentifier literalId = new CSharpLiteralIdentifier();
	private CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	
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
				package «epackage.name»;
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
			public class «id.EClassImpl(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			extends «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				//implement your generated class here
			}
			'''
		
		}
	}
	



}