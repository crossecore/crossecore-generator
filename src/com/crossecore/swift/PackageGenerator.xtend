package com.crossecore.swift;

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import com.crossecore.DependencyManager
import com.crossecore.Utils
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider

class PackageGenerator extends EcoreVisitor{
	
	private IdentifierProvider id = new SwiftIdentifier();
	
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	
	
	override caseEPackage(EPackage epackage){
		var sortedEClasses = DependencyManager.sortEClasses(epackage); 
		var edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses.addAll(edatatypes);
		'''
	 	«IF !Utils.isEcoreEPackage(epackage)»
	 	using Ecore;
	 	«ENDIF»
		protocol «id.doSwitch(epackage)»Package : EPackage {
				
			«FOR EClassifier eclassifier: sortedEClasses»
				«doSwitch(eclassifier)»
			«ENDFOR»
				
		 
		}
		'''
	}
	
	override caseEEnum(EEnum enumeration)'''
		func «id.getEEnum(enumeration)»()->EEnum?;
	'''
	
	override caseEDataType(EDataType datatype)'''
		func «id.getEDataType(datatype)»()->EDataType?;
	'''
	
	override caseEClass(EClass eclass)'''
		func «id.getEClass(eclass)»()->EClass?;
		«FOR EReference ereference:eclass.EReferences»
			«doSwitch(ereference)»
		«ENDFOR»
		
		«FOR EAttribute eattribute:eclass.EAttributes»
			«doSwitch(eattribute)»
		«ENDFOR»
	'''
	
	override caseEReference(EReference ereference)'''
		func «id.getEReference(ereference)»()->EReference?;
	'''
	
	override caseEAttribute(EAttribute eattribute)'''
		func «id.getEAttribute(eattribute)»()->EAttribute?;
	'''
	
}