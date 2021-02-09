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

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.util.EcoreUtil
import com.crossecore.EcoreVisitor

class PackageGenerator extends EcoreVisitor{
	
	IdentifierProvider id = new JavaIdentifier();
	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){
		var sortedEClasses = DependencyManager.sortEClasses(epackage); 
		var edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses.addAll(edatatypes);
		'''
		package «epackage.name»;
		
		import org.eclipse.emf.ecore.*;
		
		public interface «id.doSwitch(epackage)»Package extends org.eclipse.emf.ecore.EPackage {
				
			«FOR EClassifier eclassifier: sortedEClasses»
				«doSwitch(eclassifier)»
			«ENDFOR»
				
		 
		}
		
		'''
	}
	
	override caseEEnum(EEnum enumeration)'''
		EEnum «id.getEEnum(enumeration)»();
	'''
	
	override caseEDataType(EDataType datatype)'''
		EDataType «id.getEDataType(datatype)»();
	'''
	
	override caseEClass(EClass eclass)'''
		EClass «id.getEClass(eclass)»();
		«FOR EReference ereference:eclass.EReferences»
			«doSwitch(ereference)»
		«ENDFOR»
		
		«FOR EAttribute eattribute:eclass.EAttributes»
			«doSwitch(eattribute)»
		«ENDFOR»
	'''
	
	override caseEReference(EReference ereference)'''
		EReference «id.getEReference(ereference)»();
	'''
	
	override caseEAttribute(EAttribute eattribute)'''
		EAttribute «id.getEAttribute(eattribute)»();
	'''
	
}