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
package com.crossecore.typescript

import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClassifier
import java.util.ArrayList
import com.crossecore.DependencyManager
import java.util.Collection
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import com.crossecore.ImportManager
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.EStructuralFeature
import com.crossecore.TypeTranslator

class PackageLiteralsGenerator extends TypeScriptVisitor{
	
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
	
		var sortedEClasses = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
	
		var Collection<EClass> eclasses =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
		var Collection<EEnum> enums =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EENUM);
		var Collection<EDataType> edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses.addAll(edatatypes);
		
	
		//imports.add(epackage, id.EPackagePackageImpl(epackage));
		
		var body = 
		'''
		export class «id.EPackagePackageLiterals(epackage)»{
			«FOR EClassifier eclassifier: sortedEClasses»
				«metaobjectid.doSwitch(eclassifier)»
			«ENDFOR»
		}
		'''
		
		var imports = '''
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
	

	override caseEClass(EClass eclass){
		imports.add(EcorePackage.eINSTANCE,"EClass");
		'''
			public static «id.literal(eclass)»:EClass = «id.EPackagePackageImpl(eclass.EPackage)».eINSTANCE.«id.getEClass(eclass)»();
			
			«FOR EReference ereference:eclass.EReferences»
				«doSwitch(ereference)»
			«ENDFOR»
			
			«FOR EAttribute eattribute:eclass.EAttributes»
				«doSwitch(eattribute)»
			«ENDFOR»
		'''
	}
	
	override caseEEnum(EEnum enumeration){
		
		imports.add(EcorePackage.eINSTANCE,"EEnum");
		'''public static «id.literal(enumeration)»:EEnum = «id.EPackagePackageImpl(enumeration.EPackage)».eINSTANCE.«id.getEEnum(enumeration)»();'''
	}
		
	
	
	override caseEDataType(EDataType edatatype){
		imports.add(EcorePackage.eINSTANCE,"EDataType");
		'''public static «id.literal(edatatype)»:EDataType = «id.EPackagePackageImpl(edatatype.EPackage)».eINSTANCE.«id.getEDataType(edatatype)»();'''
		
	}

	override caseEReference(EReference ereference){
		imports.add(EcorePackage.eINSTANCE,"EReference");
		'''public static «id.literal(ereference)»:EReference = «id.EPackagePackageImpl(ereference.EContainingClass.EPackage)».eINSTANCE.«id.getEReference(ereference)»();'''
	}
	
	override caseEAttribute(EAttribute eattribute){
		imports.add(EcorePackage.eINSTANCE,"EAttribute");			
		'''public static «id.literal(eattribute)»:EAttribute = «id.EPackagePackageImpl(eattribute.EContainingClass.EPackage)».eINSTANCE.«id.getEAttribute(eattribute)»();'''
	}
	
	
	var metaobjectid = new TypeScriptVisitor(){
		
		override caseEEnum(EEnum enumeration)'''
			public static «id.literal(enumeration)»:number = «enumeration.classifierID»;
			
		'''
		
		override caseEDataType(EDataType edatatype)'''
			public static «id.literal(edatatype)»:number = «edatatype.classifierID»;
			
		'''
		
		override caseEClass(EClass eclassifier){

			var i = 0;

		'''
			public static «id.literal(eclassifier)»:number = «eclassifier.classifierID»;
			public static «id.EClassifier_FEATURE_COUNT(eclassifier)»:number = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EPackagePackageLiterals(_super.EPackage)+"."+id.EClassifier_FEATURE_COUNT(_super)»«imports.add(_super.EPackage, id.EPackagePackageLiterals(_super.EPackage))»«ENDFOR»«eclassifier.EStructuralFeatures.size»;
			public static «id.EClassifier_OPERATION_COUNT(eclassifier)»:number = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EPackagePackageLiterals(_super.EPackage) + "." +id.EClassifier_OPERATION_COUNT(_super)»«imports.add(_super.EPackage, id.EPackagePackageLiterals(_super.EPackage))»«ENDFOR»«eclassifier.EOperations.size»;
			
			«FOR EStructuralFeature feature:eclassifier.EAllStructuralFeatures»
				public static «id.literal(eclassifier,feature)»:number = «i++»;
			«ENDFOR»
			
		'''
		
		}
		
	}
}