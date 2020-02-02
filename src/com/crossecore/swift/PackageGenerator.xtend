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