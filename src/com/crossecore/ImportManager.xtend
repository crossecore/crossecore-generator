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
package com.crossecore

import org.eclipse.emf.ecore.util.EcoreSwitch
import org.eclipse.emf.ecore.EClass
import java.util.HashSet
import com.crossecore.typescript.TypeScriptIdentifier
import org.eclipse.emf.ecore.EEnum
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import java.util.HashMap

class ImportManager extends EcoreSwitch<Boolean>{
	
	private char separator = '/';
	
	
	//qualified name to local name
	//private HashMap<String, EPackage> imports= new HashMap<String, String>();
	private HashSet<String> qualifiers = new HashSet<String>();
	private HashMap<String, EPackage> packages = new HashMap<String, EPackage>();
	
	
	private IdentifierProvider id= new TypeScriptIdentifier();
	private TypeTranslator t;
	
	new(TypeTranslator typetranslator){
		t = typetranslator
	}
	
	override defaultCase(EObject eobject){
		false;
	}
	
	def String getFullQualifiedName(EClassifier eclass){
		return getFullQualifiedName(eclass.EPackage, id.doSwitch(eclass));
	}
	
	def String getFullQualifiedName(EPackage pack, String name){
		return '''«pack.name»«this.separator»«name»''';
	}
	
	override caseEClass(EClass eclass){
		
		
//		imports.add(id.doSwitch(eclass));
//		imports.put(id.doSwitch(eclass.EPackage)+"/"+id.doSwitch(eclass), id.doSwitch(eclass));

		_add(eclass);
		
		
		
		return true;
	}
	
	override caseEEnum(EEnum eenum){
		
//		imports.add(id.doSwitch(eenum));
//		imports.put(id.doSwitch(eenum.EPackage)+"/"+id.doSwitch(eenum), id.doSwitch(eenum));
		//imports.put(eenum.EPackage, id.doSwitch(eenum));
		
		_add(eenum);
		
		return true;
	}
	
	public def void add(EPackage pack, String name){
		//imports.add('''«id.caseEPackage(pack)»/«name»''');
		//add(id.caseEPackage(pack), name);
//		add(id.caseEPackage(pack), name);
//		imports.put(pack, name);

		_add(pack, name);

	}
	
	private def void _add(EPackage pack, String name){
		var qualifier = getFullQualifiedName(pack, name);
		packages.put(qualifier, pack);
		qualifiers.add(qualifier);
	}
	
	private def void _add(EClassifier eclassifier){
		
		if(eclassifier instanceof EDataType == false){
			
			var qualifier = getFullQualifiedName(eclassifier.EPackage, id.doSwitch(eclassifier));
			packages.put(qualifier, eclassifier.EPackage);
			qualifiers.add(qualifier);
		}
		
	}
	


	
	public def clear(){
		//imports.clear();
		qualifiers.clear();
		packages.clear();
		
	}
			
	public def void filter(EGenericType generictype){
		//have to call a void method from the outside, because otherwise the return value can appear in template expressions
		//doSwitch(t.translateType(generictype.EClassifier));

		if(generictype.EClassifier!==null && 
			generictype.EClassifier instanceof EDataType &&
			t.mapPrimitiveType(generictype.EClassifier as EDataType)!=null
		){
			//case e.g. EInt => int (no import required)
			return;
		}
		else if(generictype.EClassifier!=null && 
			generictype.EClassifier instanceof EDataType &&
			t.mapComplexType(generictype.EClassifier as EDataType)!=null){
			//case e.g. Resource => Resource (import required)
			_add(generictype.EClassifier.EPackage, t.mapComplexType(generictype.EClassifier as EDataType));
		}
		else if(generictype.EClassifier!=null){
			//case e.g. MyClass => MyClass (import required)
			_add(generictype.EClassifier);
		}
		else{
			
		}

		/* 
		if(generictype.EClassifier!=null){
			
			
			if(generictype.EClassifier instanceof EDataType){
				var mappedType = t.mapPrimitiveType(generictype.EClassifier as EDataType);
			
				if(mappedType!=null){
					//Do not import primitive types
					return;
				}	
				
				mappedType = t.mapComplexType(generictype.EClassifier as EDataType);
				
				if(mappedType!=null){
					//imports.add(mappedType);
					//imports.put(generictype.EClassifier.EPackage+"/"+mappedType, mappedType);
					//imports.put(id.doSwitch(generictype.EClassifier.EPackage)+"/"+mappedType, mappedType);
					_add(generictype.EClassifier);
				}					
			}
			else{
				
			}
			
			
			//imports.put('''«id.doSwitch(generictype.EClassifier.EPackage)»/«id.doSwitch(generictype.EClassifier)»''', id.doSwitch(generictype.EClassifier));
			//imports.put(generictype.EClassifier.EPackage, id.doSwitch(generictype.EClassifier));
			
		}
		
		*/
		
		for(EGenericType parameter:generictype.ETypeArguments){
			//imports.add(id.doSwitch(parameter));
			
			//case e.g. X<Y<Z>> => X, Y, Z (imports required)
			filter(parameter);
		}
		
	}
	
	public def void filter(EClassifier eclassifier){
		//imports.add(id.doSwitch(eclassifier));
//		imports.put('''«id.doSwitch(eclassifier.EPackage)»/«id.doSwitch(eclassifier)»''',id.doSwitch(eclassifier));
//		imports.put(eclassifier.EPackage,id.doSwitch(eclassifier));

		if(eclassifier instanceof EDataType===false){
			
			_add(eclassifier);
		}
	}
	
	public def Set<String> getFullyQualifiedImports(){
		return qualifiers;
	}
	
	public def EPackage getPackage(String fullyQualifiedName){
		return packages.get(fullyQualifiedName);
	}
	
	public def String getLocalName(String fullyQualifiedName){
		return fullyQualifiedName.substring(fullyQualifiedName.indexOf(this.separator)+1);
	}
	
	
}