package com.crossecore.java;

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.EcoreVisitor
import com.crossecore.TypeTranslator

class SwitchGenerator extends EcoreVisitor {
	
	private IdentifierProvider id = new JavaIdentifier();
	private TypeTranslator t = new JavaTypeTranslator(id);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	
	override caseEPackage(EPackage epackage)
		'''
		package «epackage.name»;
		
		import org.eclipse.emf.ecore.*;
		
		public class «id.doSwitch(epackage)»Switch<T> extends org.eclipse.emf.ecore.util.Switch<T> {

			protected static «id.doSwitch(epackage)»Package modelPackage;
			
			@Override
			protected boolean isSwitchFor(EPackage ePackage)
			{
				return ePackage == modelPackage;
			}
	
			public «id.doSwitch(epackage)»Switch()
			{
				if (modelPackage == null)
				{
					modelPackage = «id.doSwitch(epackage)»PackageImpl.eINSTANCE;
				}
			}
			
			@Override
			protected T doSwitch(int classifierID, EObject theEObject) {
				switch (classifierID) {
					«FOR EClassifier eclassifier: epackage.EClassifiers»
						«cases.doSwitch(eclassifier)»
					«ENDFOR»
					default: return defaultCase(theEObject);
				}
			}
			
			
			«FOR EClassifier eclassifier: epackage.EClassifiers»
				«doSwitch(eclassifier)»
			«ENDFOR»
			
		}
		
	'''
	
	override caseEClass(EClass eclassifier)'''
		public T case«id.doSwitch(eclassifier)»(«t.translateType(eclassifier)» theEObject) {
			return null;
		}
	'''
	
	var cases = new EcoreVisitor(){
	
		override caseEClass(EClass eclassifier){
			var sortedEClasses = DependencyManager.sortEClasses(eclassifier.ESuperTypes)
			'''
			case «id.doSwitch(eclassifier.EPackage)»PackageImpl.«id.doSwitch(eclassifier).toUpperCase»: {
				«t.translateType(eclassifier)» obj = («t.translateType(eclassifier)») theEObject;
				T result = case«id.doSwitch(eclassifier)»(obj);
				
				«FOR EClass supertype: sortedEClasses»
				if (result == null) result = case«id.doSwitch(supertype)»(obj);
				«ENDFOR»
				
				if (result == null) result = defaultCase(theEObject);
				return result;
			}
			'''
		
		}
	
	}
	
}