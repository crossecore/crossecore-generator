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
package com.crossecore.swift;

import com.crossecore.DependencyManager
import com.crossecore.EcoreVisitor
import com.crossecore.Utils
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter

class ModelImplGenerator extends EcoreVisitor{
	
	SwiftIdentifier id = new SwiftIdentifier();
	
	
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
				«IF !Utils.isEcoreEPackage(epackage)»
				using Ecore;
			 	«ENDIF»
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
			class «id.EClassImpl(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			: «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				//implement your generated class here	
			}
			'''
		
		}
	}
	

}