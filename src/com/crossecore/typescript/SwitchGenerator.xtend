/* 
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.crossecore.typescript;

import com.crossecore.DependencyManager
import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage

class SwitchGenerator extends EcoreVisitor {
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	//private TypeTranslator t = new TypeScriptTypeTranslator(id);
	//private ImportManager imports = new ImportManager(t);
	private TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage(EPackage epackage){
		tt.import_(EcorePackage.eINSTANCE,"Switch");
		tt.import_(EcorePackage.eINSTANCE,"EPackage");
		tt.import_(EcorePackage.eINSTANCE,"EObject");
		tt.import_(epackage, id.EPackagePackage(epackage));
		tt.import_(epackage, id.EPackagePackageImpl(epackage));
		
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
		

		
		return
		'''
		«tt.printImports(epackage)»
		«body»
		'''
	
	}
	
	override caseEClass(EClass eclassifier){
		tt.import_(eclassifier);
		'''
		public case«id.doSwitch(eclassifier)»(object:«id.doSwitch(eclassifier)»):T {
			return null;
		}
		'''
		
	}
	
	var cases = new EcoreVisitor(){
	
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