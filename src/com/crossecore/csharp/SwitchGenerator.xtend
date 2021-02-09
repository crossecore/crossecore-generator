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
package com.crossecore.csharp;

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage

class SwitchGenerator extends CSharpVisitor {
	
	IdentifierProvider id = new CSharpIdentifier();
	String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage)
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
	 	using Ecore;
	 	«ENDIF»
		namespace «id.doSwitch(epackage)»{
			public class «id.doSwitch(epackage)»Switch<T> : Switch<T> {
				protected static «id.doSwitch(epackage)»Package modelPackage;
				
				protected override bool isSwitchFor(EPackage ePackage)
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
				
				protected override T doSwitch(int classifierID, EObject theEObject) {
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
		}
	'''
	
	override caseEClass(EClass eclassifier)'''
		public virtual T case«id.doSwitch(eclassifier)»(«eclassifier.name» theEObject) {
			return default(T);
		}
	'''
	
	var cases = new CSharpVisitor(epackage){
	
		override caseEClass(EClass eclassifier){
			var sortedEClasses = DependencyManager.sortEClasses(eclassifier.ESuperTypes)
			'''
			case «id.doSwitch(eclassifier.EPackage)»PackageImpl.«id.doSwitch(eclassifier).toUpperCase»: {
				var «id.variable(eclassifier)» = («id.doSwitch(eclassifier)») theEObject;
				var result = case«id.doSwitch(eclassifier)»(«id.variable(eclassifier)»);
				
				«FOR EClass supertype: sortedEClasses»
				if (result == null) result = case«id.doSwitch(supertype)»(«id.variable(eclassifier)»);
				«ENDFOR»
				
				if (result == null) result = defaultCase(theEObject);
				return result;
			}
			'''
		
		}
	
	
	}
	
}