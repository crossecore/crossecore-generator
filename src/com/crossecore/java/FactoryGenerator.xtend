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
package com.crossecore.java

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor

class FactoryGenerator extends EcoreVisitor {
	
	IdentifierProvider id = new JavaIdentifier();
	JavaTypeTranslator t = new JavaTypeTranslator(id);
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	
	
	
	override caseEPackage (EPackage epackage) {
	
		var eclasses = epackage.EClassifiers.filter[c|c instanceof EClass].map[c|c as EClass].filter[c|!c.interface && !c.abstract];
		
		'''
		package «epackage.name»;
		public interface «id.EPackageFactory(epackage)» extends org.eclipse.emf.ecore.EFactory{
			
			«FOR EClassifier classifier: eclasses»
				«doSwitch(classifier)»
			«ENDFOR»
		}
		
		'''
	}

	override caseEClass(EClass eclass){
		if(!eclass.interface){
			'''
				«t.translateType(eclass)» «id.createEClass(eclass)»();
			'''
		}
	}
	
	
	
}