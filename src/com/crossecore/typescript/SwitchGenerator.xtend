package com.crossecore.typescript;

import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import com.crossecore.DependencyManager
import com.crossecore.ImportManager
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.TypeTranslator

class SwitchGenerator extends TypeScriptVisitor {
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	private TypeTranslator t = new TypeScriptTypeTranslator(id);
	private ImportManager imports = new ImportManager(t);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage(EPackage epackage){
		imports.add(EcorePackage.eINSTANCE,"Switch");
		imports.add(EcorePackage.eINSTANCE,"EPackage");
		imports.add(EcorePackage.eINSTANCE,"EObject");
		imports.add(epackage, id.EPackagePackage(epackage));
		imports.add(epackage, id.EPackagePackageImpl(epackage));
		
		var body = 
		'''
		export class «id.EPackageSwitch(epackage)»<T> extends Switch<T> {
			protected static modelPackage:«id.EPackagePackage(epackage)»;
			
			constructor(){
				super();
				if («id.EPackageSwitch(epackage)».modelPackage == null) {
					«id.EPackageSwitch(epackage)».modelPackage = «id.EPackagePackageImpl(epackage)».eINSTANCE;
				}	
			}
			
			public isSwitchFor(ePackage:EPackage):boolean{
				return ePackage === «id.EPackageSwitch(epackage)».modelPackage;
			}
			
			public doSwitch(classifierID:number, theEObject:EObject):T {
				switch (classifierID) {
					«FOR EClassifier eclassifier: epackage.EClassifiers»
						«cases.doSwitch(eclassifier)»
					«ENDFOR»
					default: return this.defaultCase(theEObject);
				}
			}
			
			
			«FOR EClassifier eclassifier: epackage.EClassifiers»
				«doSwitch(eclassifier)»
			«ENDFOR»
			
		}
		
		'''
		
		var imports = 
		'''
		«FOR String path : imports.fullyQualifiedImports»
			«IF imports.getPackage(path).nsURI.equals(epackage.nsURI)»
			import {«imports.getLocalName(path)»} from "./«imports.getLocalName(path)»";
			«ELSE»
			import {«imports.getLocalName(path)»} from "«path»";
			«ENDIF»
		«ENDFOR»
		'''
		
		return
		'''
		«imports»
		«body»
		'''
	
	}
	
	override caseEClass(EClass eclassifier){
		imports.filter(eclassifier);
		'''
		public case«id.doSwitch(eclassifier)»(object:«id.doSwitch(eclassifier)»):T {
			return null;
		}
		'''
		
	}
	
	var cases = new TypeScriptVisitor(){
	
		override caseEClass(EClass eclassifier){
			var sortedEClasses_ = DependencyManager.sortEClasses(eclassifier.EAllSuperTypes);
			var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
			
			'''
				case «id.EPackagePackageImpl(eclassifier.EPackage)».«id.literal(eclassifier)»: {
					let obj:«eclassifier.name» = <«eclassifier.name»>theEObject;
					let result:T = this.case«eclassifier.name»(obj);
					«FOR EClassifier supertype: sortedEClasses»
					if (result == null) result = this.case«supertype.name»(obj);
					«ENDFOR»
					if (result == null) result = this.defaultCase(theEObject);
					return result;
				}
			'''
		
		}
	
	
	}
	
}