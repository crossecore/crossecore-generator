package com.crossecore.swift;

import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import com.crossecore.EcoreVisitor
import com.crossecore.DependencyManager
import com.crossecore.Utils
import com.crossecore.IdentifierProvider

class SwitchGenerator extends EcoreVisitor {
	
	private IdentifierProvider id = new SwiftIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	
	override caseEPackage(EPackage epackage)
		'''
	 	«IF !Utils.isEcoreEPackage(epackage)»
	 	using Ecore;
	 	«ENDIF»
		class «id.doSwitch(epackage)»Switch<T> : Switch<T> {

			//TODO access control protected?
			var modelPackage:«id.doSwitch(epackage)»Package?;
			
			override func isSwitchFor(ePackage : EPackage?) -> Bool
			{
				return ePackage as? EPackageImpl == modelPackage as? EPackageImpl;
			}

			override init()
			{
				//if (modelPackage == nil)
				//{
					modelPackage = «id.doSwitch(epackage)»PackageImpl.eINSTANCE;
				//}
			}
			
			override func doSwitch(classifierID : Int, theEObject : EObject) -> T?{
				switch (classifierID) {
					«FOR EClassifier eclassifier: epackage.EClassifiers»
						«cases.doSwitch(eclassifier)»
					«ENDFOR»
					default: return defaultCase(eObject: theEObject);
				}
			}
			
			
			«FOR EClassifier eclassifier: epackage.EClassifiers»
				«doSwitch(eclassifier)»
			«ENDFOR»
			
		}
	'''
	
	override caseEClass(EClass eclassifier)'''
		func case«id.doSwitch(eclassifier)»(theEObject : «eclassifier.name») -> T?{
			return nil;
		}
	'''
	
	var cases = new EcoreVisitor(){
	
		override caseEClass(EClass eclassifier){
			var sortedEClasses = DependencyManager.sortEClasses(eclassifier.ESuperTypes)
			'''
			case «id.doSwitch(eclassifier.EPackage)»PackageImpl.«id.doSwitch(eclassifier).toUpperCase»: 
				var «id.doSwitch(eclassifier).toLowerCase»:«id.doSwitch(eclassifier)» = theEObject as! «id.doSwitch(eclassifier)» ;
				var result = case«id.doSwitch(eclassifier)»(theEObject: «id.doSwitch(eclassifier).toLowerCase»);
				
				«FOR EClass supertype: sortedEClasses»
				if let result_ = result{ 
					result = case«id.doSwitch(supertype)»(theEObject: «id.doSwitch(eclassifier).toLowerCase»);
				}
				«ENDFOR»
				
				if let result_ = result{
					result = defaultCase(eObject: theEObject);
				}
				return result;
			
			'''
		
		}
	
	}
	
}