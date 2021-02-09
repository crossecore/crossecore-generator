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
package com.crossecore.csharp

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider

class FactoryGenerator extends CSharpVisitor {
	
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
	

	override caseEPackage (EPackage epackage) {
		
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
		namespace «id.doSwitch(epackage)»{
			public interface «id.EPackageFactory(epackage)» : EFactory{
				
				«FOR EClassifier classifier: epackage.EClassifiers»
					«doSwitch(classifier)»
				«ENDFOR»
			}
		}
		'''
	
	}

	
	override caseEClass(EClass eclass){
		if(!eclass.interface){
			'''
				«id.doSwitch(eclass)» «id.createEClass(eclass)»();
			'''
		}
	}
	
	
	
	
}