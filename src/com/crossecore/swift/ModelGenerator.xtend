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
import java.util.Collection
import java.util.HashSet
import java.util.List
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.ETypeParameter

class ModelGenerator extends EcoreVisitor{
	
	SwiftIdentifier id = new SwiftIdentifier();
	SwiftTypeTranslator t = new SwiftTypeTranslator(id);
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	
	override write(){
		doSwitch(epackage);
	}
	

	

	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		eclassifiers.removeAll(sortedEClasses);
		
		
		for(EClass classifier: sortedEClasses){
			var contents = 	
				'''
			 	«IF !Utils.isEcoreEPackage(epackage)»
				using Ecore;
			 	«ENDIF»
				«doSwitch(classifier)»
				'''
			write(classifier, contents);
		}


		
	
		return "";
	
	}
	
	override caseEClass(EClass e) '''
		
		protocol «id.doSwitch(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
		«IF e.ESuperTypes.empty && !Utils.isEClassifierForEObject(e)»
			: EObject
		«ELSEIF (Utils.isEClassifierForEObject(e))»
			: Notifier
		«ELSE»
			«FOR EClassifier supertype:e.ESuperTypes BEFORE ': ' SEPARATOR ','»«id.doSwitch(supertype)»«ENDFOR»
		«ENDIF»
		{
			«FOR EStructuralFeature feature:e.EStructuralFeatures»«doSwitch(feature)»«ENDFOR»
			«FOR EOperation operation:e.EOperations»«doSwitch(operation)»«ENDFOR»
		}
	'''
		
	override caseEEnum(EEnum eenum) '''

		enum «id.doSwitch(eenum)»{
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals SEPARATOR ','»
				«doSwitch(eenumliteral)»
			«ENDFOR»
		}
	'''
	
	override caseEEnumLiteral(EEnumLiteral eenumliteral){
		'''case «id.doSwitch(eenumliteral)» = «eenumliteral.value»'''
	}
	
	override caseEAttribute(EAttribute eattribute){
		
		var listType = t.listType(eattribute.unique, eattribute.ordered);
		
		'''
		«IF eattribute.many»
			var «id.doSwitch(eattribute)» : «listType»<«t.translateType(eattribute.EGenericType)»>?
			{
				get 
				«IF (!eattribute.derived && eattribute.changeable)»
				set
				«ENDIF»
			}
		«ELSE»
			var «id.doSwitch(eattribute)» : «t.translateType(eattribute.EGenericType)»?
			{
				get 
			«IF (!eattribute.derived && eattribute.changeable)»
				set
			«ENDIF»
			}
		«ENDIF»
		'''
	
	}
	
	override caseEParameter(EParameter parameter){
		'''«id.doSwitch(parameter)» : «t.translateType(parameter.EGenericType)»?'''
	}
	
	override caseEReference(EReference ereference){
		var listType = t.listType(ereference.unique, ereference.ordered);
		
		'''
		«IF ereference.many»
		var «id.doSwitch(ereference)» : «listType»<«t.translateTypeImpl(ereference.EGenericType)»>? 
		{
			get 

		}

		«ELSE»
		
		var «id.doSwitch(ereference)» : «t.translateType(ereference.EGenericType)»?
		{
			get 
			«IF !ereference.derived && ereference.changeable»
			set
			«ENDIF»
		}
		«ENDIF»
		'''
		
	}
	

	
	override caseEOperation(EOperation e){
		var returntype="";
		if(e.isMany){
			returntype = '''«t.listType(e.unique, e.ordered)»<«t.translateType(e.EGenericType)»>?''';
		}
		else{
			returntype = '''«t.translateType(e.EGenericType)»?'''
		}
		
		'''
		func «id.doSwitch(e)»(«FOR EParameter parameter:e.EParameters SEPARATOR ','»«doSwitch(parameter)»«ENDFOR»)«IF e.EType!==null» -> «returntype»«ENDIF»;
		'''
	}
	
	


}