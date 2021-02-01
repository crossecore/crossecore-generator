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
package com.crossecore.csharp;

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
import java.util.Set

class ModelGenerator extends CSharpVisitor{
	
	CSharpIdentifier id = new CSharpIdentifier();
	TypeTranslator t = new CSharpTypeTranslator(id);
	
	String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''	
	
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
		var List<EClass> sortedEClasses_ = DependencyManager.sortEClasses(epackage);
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		var Set<EClassifier> eclassifiers = new HashSet<EClassifier>(sortedEClasses.toSet);
		eclassifiers.addAll(epackage.EClassifiers);	
		
		
		for(EClassifier classifier: eclassifiers){
			var contents =
				'''
				«header» 	
				using System;
				using System.Collections.Generic;
				using System.Linq;
				using System.Text;
				using oclstdlib;
			 	«IF !Utils.isEcoreEPackage(epackage)»
				using Ecore;
			 	«ENDIF»
				namespace «id.doSwitch(epackage)»{
					«doSwitch(classifier)»
				}
				'''
			write(classifier, contents);
		}
	
		return "";
	
	}
	
	override caseEClass(EClass e) '''
		
		public interface «id.doSwitch(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
		«IF e.ESuperTypes.empty && !Utils.isEClassifierForEObject(e)»
			: EObject
		«ELSEIF (Utils.isEClassifierForEObject(e))»
			: Notifier
		«ELSE»
			«FOR EClassifier supertype:e.ESuperTypes BEFORE ': ' SEPARATOR ', '»«IF !e.EPackage.equals(supertype.EPackage)»«id.doSwitch(supertype.EPackage)».«ENDIF»«id.doSwitch(supertype)»«ENDFOR»
		«ENDIF»
		{
			«FOR EStructuralFeature feature:e.EStructuralFeatures»«doSwitch(feature)»«ENDFOR»
			«FOR EOperation operation:e.EOperations»«doSwitch(operation)»«ENDFOR»
		}
	'''
		
	override caseEEnum(EEnum eenum) {
		return 
		'''
	    public class «id.doSwitch(eenum)» : EEnumerator
	    {
	    	
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				public const int «eenumliteral.name.toUpperCase»_VALUE = «eenumliteral.value»;
			«ENDFOR»
			
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				public static «id.doSwitch(eenum)» «eenumliteral.name.toUpperCase» = new «id.doSwitch(eenum)»(«eenumliteral.value», "«eenumliteral.name»", "«eenumliteral.literal»");
			«ENDFOR»
	
			private static «id.doSwitch(eenum)»[] VALUES_ARRAY =
				new «id.doSwitch(eenum)»[] {
				«FOR EEnumLiteral eenumliteral : eenum.ELiterals SEPARATOR ', '»
					«eenumliteral.name.toUpperCase»
				«ENDFOR»
			};
	
	        public static «id.doSwitch(eenum)» get(string literal)
	        {
	            for (int i = 0; i < VALUES_ARRAY.Length; ++i)
	            {
	                «id.doSwitch(eenum)» result = VALUES_ARRAY[i];
	                if (result.ToString() == literal)
	                {
	                    return result;
	                }
	            }
	            return null;
	        }
	
	        public static «id.doSwitch(eenum)» getByName(string name)
	        {
	            for (int i = 0; i < VALUES_ARRAY.Length; ++i)
	            {
	                «id.doSwitch(eenum)» result = VALUES_ARRAY[i];
	                if (result.getName()==name)
	                {
	                    return result;
	                }
	            }
	            return null;
	        }
	
	        public static «id.doSwitch(eenum)» get(int value)
	        {
	            switch (value)
	            {
				«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				case «eenumliteral.name.toUpperCase»_VALUE: return «eenumliteral.name.toUpperCase»;
				«ENDFOR»
	            }
	            return null;
	        }
	
	        private int value;
	        private string name;
		    private string literal;
	
	        private «id.doSwitch(eenum)»(int value, string name, string literal)
	        {
	            this.value = value;
	            this.name = name;
	            this.literal = literal;
	        }
	
	        public string getLiteral()
	        {
	            return literal;
	        }
	
	        public string getName()
	        {
	            return name;
	        }
	
	        public int getValue()
	        {
	            return value;
	        }
	        
			public override string ToString()
			{
				return literal;
			}
	    }
		'''
	
	}
	
	override caseEEnumLiteral(EEnumLiteral eenumliteral){
		'''«id.doSwitch(eenumliteral)» = «eenumliteral.value»'''
	}
	
	override caseEAttribute(EAttribute eattribute){
		
		var listType = t.listType(eattribute.unique, eattribute.ordered);
		
		'''
		«IF eattribute.many»
			«listType»<«t.translateType(eattribute.EGenericType)»> «id.doSwitch(eattribute)»
			{
				get;
				«IF (!eattribute.derived && eattribute.changeable)»
				set;
				«ENDIF»
			}
		«ELSE»
			«t.translateType(eattribute.EGenericType)» «id.doSwitch(eattribute)»
			{
				get;
			«IF (!eattribute.derived && eattribute.changeable)»
				set;
			«ENDIF»
			}
		«ENDIF»
		'''
	}
	
	override caseEParameter(EParameter parameter){
		'''«t.translateType(parameter.EGenericType)» «id.doSwitch(parameter)»'''
	}
	
	override caseEReference(EReference ereference){
		var listType = t.listType(ereference.unique, ereference.ordered);
		
		'''
		«IF ereference.containment && ereference.EType?.instanceClassName?.equals("java.util.Map$Entry")»
		EMap<«t.translateType((ereference.EType as EClass).getEStructuralFeature("key").EType)», «t.translateType((ereference.EType as EClass).getEStructuralFeature("value").EType)»> «id.doSwitch(ereference)»
		{
			get;

		}
		«ELSEIF ereference.many»
		«listType»<«t.translateType(ereference.EGenericType)»> «id.doSwitch(ereference)»
		{
			get;

		}
		«ELSE»
		«t.translateType(ereference.EGenericType)» «id.doSwitch(ereference)»
		{
			get;
			«IF !ereference.derived && ereference.changeable»
			set;
			«ENDIF»
		}
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