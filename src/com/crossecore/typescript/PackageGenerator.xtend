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

import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EEnum
import com.crossecore.IdentifierProvider
import com.crossecore.DependencyManager
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.Utils
import com.crossecore.ImportManager
import com.crossecore.TypeTranslator
import java.util.ArrayList

class PackageGenerator extends TypeScriptVisitor{
	
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
		var sortedEClasses_ = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
		var edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses_.addAll(edatatypes);
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		
		
		tt.import_(EcorePackage.eINSTANCE,"EPackage");
		var body = 
		'''
		export interface «id.EPackagePackage(epackage)» extends EPackage {
			«FOR EClassifier eclassifier: sortedEClasses»
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
	
	override caseEEnum(EEnum enumeration){
		tt.import_(EcorePackage.eINSTANCE,"EEnum");
		'''«id.getEEnum(enumeration)»():EEnum;'''
	}
	
	override caseEDataType(EDataType datatype){
		tt.import_(EcorePackage.eINSTANCE,"EDataType");
		'''«id.getEDataType(datatype)»():EDataType;'''
	
	}
	
	override caseEClass(EClass eclass){
		tt.import_(EcorePackage.eINSTANCE,"EClass");
		'''
		«id.getEClass(eclass)»():EClass;
		«FOR EReference ereference:eclass.EReferences»
			«doSwitch(ereference)»
		«ENDFOR»
		
		«FOR EAttribute eattribute:eclass.EAttributes»
			«doSwitch(eattribute)»
		«ENDFOR»
		'''
		
	}
	
	override caseEReference(EReference ereference){
		tt.import_(EcorePackage.eINSTANCE, "EReference");
		'''«id.getEReference(ereference)»():EReference;'''
		
	}
	
	override caseEAttribute(EAttribute eattribute){
		tt.import_(EcorePackage.eINSTANCE,"EAttribute");
		'''«id.getEAttribute(eattribute)»():EAttribute;'''
		
	}
}