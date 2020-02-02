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
package com.crossecore.swift

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor

class FactoryImplGenerator extends EcoreVisitor {
	
	private IdentifierProvider id = new SwiftIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	


	
	override caseEPackage (EPackage epackage) {
		'''
	 	«IF !Utils.isEcoreEPackage(epackage)»
	 	using Ecore;
	 	«ENDIF»
		class «id.EPackageFactoryImpl(epackage)» : EFactoryImpl, «id.EPackageFactory(epackage)» {
			
			static let eINSTANCE:«id.EPackageFactory(epackage)» = «id.EPackageFactoryImpl(epackage)».init_();
			static func init_() -> «id.EPackageFactory(epackage)»
			{
				return «id.EPackageFactoryImpl(epackage)»();
			}
			«FOR EClassifier classifier: epackage.EClassifiers»
				«doSwitch(classifier)»
			«ENDFOR»
		}
		'''
	}

	
	override caseEClass(EClass e){
		if(!e.interface){
			'''
			func «id.createEClass(e)»() -> «id.doSwitch(e)»{
				let «id.variable(e)» = «id.EClassImpl(e)»();
				return «id.variable(e)»;
			}
			'''
		}
	
	}
	
	
}