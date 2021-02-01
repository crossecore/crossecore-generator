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
package com.crossecore.java;

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
import com.crossecore.Utils
import com.crossecore.DependencyManager
import java.util.List
import java.util.HashSet
import com.crossecore.TypeTranslator

import com.crossecore.EcoreVisitor
import org.eclipse.emf.common.util.BasicEMap
import java.util.Set
import org.eclipse.emf.common.util.BasicEList

class ModelGenerator extends EcoreVisitor{
	
	JavaIdentifier id = new JavaIdentifier();
	TypeTranslator t = new JavaTypeTranslator(id);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override write(){
		doSwitch(epackage);
	}
	
	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		var Set<EClassifier> eclassifiers = new HashSet<EClassifier>(sortedEClasses);
		eclassifiers.addAll(epackage.EClassifiers);	
		
		for(EClassifier classifier: eclassifiers){
			var contents = 	
				'''
				package «epackage.name»;
				«doSwitch(classifier)»
				'''
			write(classifier, contents);
		}
	
		return "";
	
	}
	
	override caseEClass(EClass e) {
		var eAnnotation = e.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");
		var invariants = if(eAnnotation!==null) eAnnotation.getDetails() else new BasicEMap();
		
		var superclasses = new BasicEList<EClass>(e.EAllSuperTypes);
		superclasses.add(e);
		
		var closure = Utils.getSubclasses(e);
		
	'''
		public interface «id.doSwitch(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
		«IF e.ESuperTypes.empty && !Utils.isEClassifierForEObject(e)»
			extends org.eclipse.emf.ecore.EObject
		«ELSEIF (Utils.isEClassifierForEObject(e))»
			extends org.eclipse.emf.common.notify.Notifier
		«ELSE»
			«FOR EClassifier supertype:e.ESuperTypes BEFORE ' extends ' SEPARATOR ','»«id.doSwitch(supertype)»«ENDFOR»
		«ENDIF»
		{
			
			public static com.crossecore.ocl.QuickSet<«id.doSwitch(e)»> allInstances_ = new com.crossecore.ocl.QuickSet<«id.doSwitch(e)»>(«id.doSwitch(e)».class);
			
				
			public static com.crossecore.ocl.QuickSet<«id.doSwitch(e)»> allInstances(){
				
				com.crossecore.ocl.QuickSet<«id.doSwitch(e)»> result = new com.crossecore.ocl.QuickSet<«id.doSwitch(e)»>(«id.doSwitch(e)».class);
				result.addAll(«id.doSwitch(e)».allInstances_);
				
				«FOR s:closure»
				result.addAll(«id.doSwitch(s)».allInstances_);
				«ENDFOR»
				
				return result;
			}
			
			//public static com.crossecore.ocl.QuickSet<«id.doSwitch(e)»> allInstances = new com.crossecore.ocl.QuickSet<«id.doSwitch(e)»>(«id.doSwitch(e)».class);
			
			«FOR EStructuralFeature feature:e.EStructuralFeatures»«doSwitch(feature)»«ENDFOR»
			«FOR EOperation operation:e.EOperations»«doSwitch(operation)»«ENDFOR»
			«FOR String invariant:invariants.keySet»
			public boolean «invariant»(org.eclipse.emf.common.util.DiagnosticChain diagnostics, java.util.Map<Object, Object> context);
        	«ENDFOR»
			
		}
	'''
	
	}
		
	override caseEEnum(EEnum eenum) '''

		import java.util.Arrays;
		import java.util.Collections;
		import java.util.List;

		public enum «id.doSwitch(eenum)» implements org.eclipse.emf.common.util.Enumerator{
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals SEPARATOR ',' AFTER ';'»
				«eenumliteral.name.toUpperCase»(«eenumliteral.value», "«eenumliteral.name»", "«eenumliteral.literal»")
			«ENDFOR»
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				public static final int «eenumliteral.name.toUpperCase»_VALUE = «eenumliteral.value»;
			«ENDFOR»
			
			private static final «id.doSwitch(eenum)»[] VALUES_ARRAY =
				new «id.doSwitch(eenum)»[] {
				«FOR EEnumLiteral eenumliteral : eenum.ELiterals SEPARATOR ','»
					«eenumliteral.name.toUpperCase»
				«ENDFOR»
				};
			public static final List<«id.doSwitch(eenum)»> VALUES = Collections.unmodifiableList(Arrays.asList(VALUES_ARRAY));
			
			public static «id.doSwitch(eenum)» get(String literal) {
				for (int i = 0; i < VALUES_ARRAY.length; ++i) {
					«id.doSwitch(eenum)» result = VALUES_ARRAY[i];
					if (result.toString().equals(literal)) {
						return result;
					}
				}
				return null;
			}
			
			public static «id.doSwitch(eenum)» getByName(String name) {
				for (int i = 0; i < VALUES_ARRAY.length; ++i) {
					«id.doSwitch(eenum)» result = VALUES_ARRAY[i];
					if (result.getName().equals(name)) {
						return result;
					}
				}
				return null;
			}
			
			public static «id.doSwitch(eenum)» get(int value) {
				switch (value) {
					«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
						
						case «eenumliteral.name.toUpperCase»_VALUE: return «eenumliteral.name.toUpperCase»;
					«ENDFOR»
				}
				return null;
			}
			private final int value;
			private final String name;
			private final String literal;
			
			private «id.doSwitch(eenum)»(int value, String name, String literal) {
				this.value = value;
				this.name = name;
				this.literal = literal;
			}
		
			public int getValue() {
			  return value;
			}
		
			public String getName() {
			  return name;
			}
		
			public String getLiteral() {
			  return literal;
			}
		
			@Override
			public String toString() {
				return literal;
			}
					
		}
	'''
	
	override caseEEnumLiteral(EEnumLiteral eenumliteral){
		'''«id.doSwitch(eenumliteral)»(«eenumliteral.value»)'''
	}
	
	override caseEAttribute(EAttribute eattribute){
		
		var listType = t.listType(eattribute.unique, eattribute.ordered);
		
		'''
		«IF eattribute.many»
			«listType»<«t.translateType(eattribute.EGenericType)»> «id.getEStructuralFeature(eattribute)»();
			«IF (!eattribute.derived && eattribute.changeable)»
			void «id.setEStructuralFeature(eattribute)»(«listType»<«t.translateType(eattribute.EGenericType)»> value);
			«ENDIF»
		«ELSE»
			«t.translateType(eattribute.EGenericType)» «id.getEStructuralFeature(eattribute)»();
			«IF (!eattribute.derived && eattribute.changeable)»
			void «id.setEStructuralFeature(eattribute)»(«t.translateType(eattribute.EGenericType)» value);
			«ENDIF»
			«IF eattribute.EType.name.equals("EBoolean")»
			//public boolean is«eattribute.name.toFirstUpper»();
			«ENDIF»
		«ENDIF»
		'''
	}
	
	override caseEParameter(EParameter parameter){
		'''«t.translateType(parameter.EGenericType)» «id.doSwitch(parameter)»'''
	}
	
	override caseEReference(EReference ereference){
		var listType = t.listType(ereference.unique, ereference.ordered);
		
		'''
		«IF ereference.many»
		«listType»<«t.translateType(ereference.EGenericType)»> «id.getEStructuralFeature(ereference)»();
		«ELSE»
		
		«t.translateType(ereference.EGenericType)» «id.getEStructuralFeature(ereference)»();
		«IF !ereference.derived && ereference.changeable»
		void «id.setEStructuralFeature(ereference)»(«t.translateType(ereference.EGenericType)» value);
		«ENDIF»
		«ENDIF»
		'''
		
	}
	
	
	override caseEOperation(EOperation e){
		var returntype="";
		if(e.isMany){
			returntype = '''«t.listType(e.unique, e.ordered)»<«t.translateType(e.EGenericType)»>''';
		}
		else{
			returntype = '''«t.translateType(e.EGenericType)»'''
		}
		
		'''
		«returntype» «id.doSwitch(e)»(«FOR EParameter parameter:e.EParameters SEPARATOR ','»«doSwitch(parameter)»«ENDFOR»);
		'''
	}
	
}