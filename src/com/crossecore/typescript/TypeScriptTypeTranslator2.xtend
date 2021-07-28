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

import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.HashSet
import java.util.Set
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.ocl.ecore.AnyType
import org.eclipse.ocl.ecore.BagType
import org.eclipse.ocl.ecore.CollectionType
import org.eclipse.ocl.ecore.OrderedSetType
import org.eclipse.ocl.ecore.PrimitiveType
import org.eclipse.ocl.ecore.SequenceType
import org.eclipse.ocl.ecore.SetType
import org.eclipse.emf.ecore.EDataType
import com.crossecore.Utils

class TypeScriptTypeTranslator2 {
	
	// the classifier, which the code is currently generated for
	EClassifier currentClassifier = null;

	HashMap<EPackage, Set<String>> packages2 = new HashMap<EPackage, Set<String>>();

	def clearImports() {
		packages2.clear;
	}
	
	
	def clearCurrentClassifier() {
		currentClassifier = null;
	}

	def setCurrentClassifier(EClassifier classifier){
		currentClassifier = classifier;
	}

	def void import_(EPackage context, EPackage epackage, String name) {
		if(!context.nsURI.equals(epackage.nsURI)){
			import_(epackage, name)
		}
	}

	def void import_(EPackage epackage, String name) {
		// TODO name conflicts from different packages
		var epackage_ = if(epackage.nsURI.equals("http://www.eclipse.org/emf/2002/Ecore")) EcorePackage.eINSTANCE else epackage;
		if (!packages2.containsKey(epackage_)) {
			packages2.put(epackage_, new HashSet<String>());
		}
		var eClassifierNames = packages2.get(epackage_);
		eClassifierNames.add(name);
		packages2.put(epackage_, eClassifierNames);
	}
	
	def void import_(EClassifier eclassifier) {

		if(eclassifier instanceof EDataType === false){
			
			import_(eclassifier.EPackage, eclassifier.name);
		}
	}

	def String printImports(EPackage self_) {

		var result = new StringBuffer();

		for (EPackage epackage : packages2.keySet) {

			var list = new ArrayList<String>(packages2.get(epackage));

			Arrays.sort(list);

			for (String name : list) {
				// add import only iff the TypeScript class which is currently under construction does not match the class, which is to be imported
				if(!name.equals(currentClassifier === null ? null : currentClassifier.name)){
					// if the package which is to be imported is part of the crossecore-lib, import it directly from node_modules
					if(Utils.isEcoreEPackage(epackage)){
						result.append('''import {«name»} from "crossecore";'''+"\n");
					}
					// otherwise, resolve it via tsconfig/paths
					else{
						result.append('''import {«name»} from "«epackage.name»/«name»";'''+"\n");
					}
				}					
			}

		}

		return result.toString;

	}
	
	def String translateType(EClassifier eClassifier) {
		if (eClassifier !== null) {
			if (eClassifier instanceof CollectionType) {

				var listtype = "";
				if (eClassifier instanceof SequenceType) {
					import_(EcorePackage.eINSTANCE, "Sequence");
					listtype = "Sequence";
				} else if (eClassifier instanceof BagType) {
					import_(EcorePackage.eINSTANCE, "Bag");
					listtype = "Bag";
				} else if (eClassifier instanceof OrderedSetType) {
					import_(EcorePackage.eINSTANCE, "OrderedSet");
					listtype = "OrderedSet";
				} else if (eClassifier instanceof SetType) {
					import_(EcorePackage.eINSTANCE, "Set");
					listtype = "Set";
				}

				var elementtype = (eClassifier as CollectionType).elementType;

				if (elementtype instanceof AnyType) {
					return '''«listtype»<any>''';
				} else if (elementtype instanceof PrimitiveType) {

					switch (elementtype.name) {
						case "Integer": return '''«listtype»<number>'''
						case "String": return '''«listtype»<string>'''
						case "Real": return '''«listtype»<number>'''
						case "Boolean": return '''«listtype»<boolean>'''
					}
				} else {
					// TODO import if from different package	
					return '''«listtype»<«elementtype.name»>'''
				}

			// TODO other types possible here like ocl's TypeType, InvalidType, VoidType etc.?
			}

			else if (eClassifier.instanceClassName !== null && !eClassifier.instanceClassName.isEmpty) {

				switch eClassifier.instanceClassName {
					case 'java.math.BigDecimal':
						return 'number'
					case 'java.math.BigInteger':
						return 'number'
					case 'boolean':
						return 'boolean'
					case 'java.lang.Boolean':
						return 'boolean'
					case 'byte':
						return 'number'
					case 'byte[]':
						return 'Array<number>'
					case 'java.lang.Byte':
						return 'number'
					case 'char':
						return 'string'
					case 'java.lang.Character':
						return 'string'
					case 'java.util.Date':
						return 'Date'
					case 'org.eclipse.emf.common.util.DiagnosticChain': {
						this.import_(EcorePackage.eINSTANCE, "DiagnosticChain");
						return 'DiagnosticChain'
					}
					case 'double':
						return 'number'
					case 'java.lang.Double':
						return 'number'
					case 'org.eclipse.emf.common.util.Enumerator': {
						this.import_(EcorePackage.eINSTANCE, "Enumerator");
						return 'Enumerator'
					}
					case 'org.eclipse.emf.ecore.util.FeatureMap': {
						this.import_(EcorePackage.eINSTANCE, "FeatureMap");
						return 'FeatureMap'
					}
					case 'org.eclipse.emf.ecore.util.FeatureMap$Entry': {
						this.import_(EcorePackage.eINSTANCE, "FeatureMapEntry");
						return 'FeatureMapEntry'
					}
					case 'float':
						return 'number'
					case 'java.lang.Float':
						return 'number'
					case 'int':
						return 'number'
					case 'java.lang.Integer':
						return 'number'
					case 'java.lang.Class':
						return 'Function'
					case 'java.lang.Object':
						return 'any'
					case 'long':
						return 'number'
					case 'java.lang.Long':
						return 'number'

					case 'java.util.Map$Entry': {
						return '?'
					}
					case 'org.eclipse.emf.ecore.resource.Resource': {
						this.import_(EcorePackage.eINSTANCE, "Resource");
						return 'Resource'
					}
					case 'org.eclipse.emf.ecore.resource.ResourceSet': {
						this.import_(EcorePackage.eINSTANCE, "ResourceSet");
						return 'ResourceSet'
					}
					case 'short':
						return 'number'
					case 'java.lang.Short':
						return 'number'
					case 'java.lang.String':
						return 'string'
					case 'java.lang.reflect.InvocationTargetException': {
						return 'Error'

					}
					
				}
				
				//imports from different ePackage
				import_(eClassifier.EPackage, eClassifier.name);
				return '''«eClassifier.name»'''				

			}			else{
				
				//EEnums
				import_(eClassifier.EPackage, eClassifier.name);
				return '''«eClassifier.name»'''
			} 
		}
		else{
			return "void";
		}
	}


	def String translateType(EGenericType eGenericType) {
		/*
		 * self.eClassifiers->select(e|e.oclIsTypeOf(EDataType))->collect(e|e.oclAsType(EDataType).instanceClassName)
		 */
		var eClassifier = eGenericType.ERawType;

		if (eClassifier !== null) {

			if (eClassifier.instanceClassName !== null && !eClassifier.instanceClassName.isEmpty) {

				switch eClassifier.instanceClassName {
					case 'java.util.Map': {
						// https://stackoverflow.com/questions/42211175/typescript-hashmap-dictionary-interface
						// https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Map
						// this.import_(EcorePackage.eINSTANCE, "Map");
						if (eGenericType.ETypeArguments.size == 2) {
							return '''Map<«translateType(eGenericType.ETypeArguments.get(0))», «translateType(eGenericType.ETypeArguments.get(1))»>'''
						} else if (eGenericType.ETypeArguments.size == 0) {
							return '''Map<any, any>'''
						} else {
							// TODO error
						}
						return 'Map'
					}
					case 'org.eclipse.emf.common.util.EList': {
						this.import_(EcorePackage.eINSTANCE, "EList");

						if (eGenericType.ETypeArguments.size == 1) {
							return '''EList<«translateType(eGenericType.ETypeArguments.get(0))»>'''
						}
						else if (eGenericType.ETypeArguments.size == 0) {
							return '''EList<any>'''
						} else {
							// TODO error
						}

						return 'EList'
					}
					case 'org.eclipse.emf.common.util.TreeIterator': {
						this.import_(EcorePackage.eINSTANCE, "TreeIterator");
						if (eGenericType.ETypeArguments.size == 1) {
							return '''TreeIterator<«translateType(eGenericType.ETypeArguments.get(0))»>'''
						}
						return 'TreeIterator'
					}
				}
				
			}
			
		}
		
		return translateType(eClassifier);
		



	}

	def listType(boolean unique, boolean ordered) {

		if (!unique && !ordered) {
			import_(EcorePackage.eINSTANCE, "Bag");
			return "Bag"
		} else if (!unique && ordered) {
			import_(EcorePackage.eINSTANCE, "Sequence");
			return "Sequence"
		} else if (unique && !ordered) {
			import_(EcorePackage.eINSTANCE, "Set");
			return "Set"
		} else if (unique && ordered) {
			import_(EcorePackage.eINSTANCE, "OrderedSet");
			return "OrderedSet"
		}

	}

	def String defaultValue(EClassifier type) {

		if (type.defaultValue !== null) {

			if (type instanceof EEnum) {

				var literal = type.defaultValue as EEnumLiteral;
				return type.name + "." + literal.name.toUpperCase;
			} else {
				return type.defaultValue.toString;
			}

		} else {

			switch type.instanceClassName {
				case 'java.math.BigDecimal': return '0'
				case 'java.math.BigInteger': return '0'
				case 'boolean': return 'false'
				case 'java.lang.Boolean': return 'false'
				case 'byte': return '0'
				case 'byte[]': return 'null'
				case 'java.lang.Byte': return '0'
				case 'char': return "''"
				case 'java.lang.Character': return "''"
				case 'java.util.Date': return 'null'
				case 'org.eclipse.emf.common.util.DiagnosticChain': return 'null'
				case 'double': return '0'
				case 'java.lang.Double': return '0'
				case 'org.eclipse.emf.common.util.EList': return 'null'
				case 'org.eclipse.emf.common.util.Enumerator': return 'null'
				case 'org.eclipse.emf.ecore.util.FeatureMap': return 'null'
				case 'org.eclipse.emf.ecore.util.FeatureMap$Entry': return 'null'
				case 'float': return '0'
				case 'java.lang.Float': return '0'
				case 'int': return '0'
				case 'java.lang.Integer': return '0'
				case 'java.lang.Class': return 'null'
				case 'java.lang.Object': return 'null'
				case 'long': return '0'
				case 'java.lang.Long': return '0'
				case 'java.util.Map': return 'null'
				case 'java.util.Map$Entry': return 'null'
				case 'org.eclipse.emf.ecore.resource.Resource': return 'null'
				case 'org.eclipse.emf.ecore.resource.ResourceSet': return 'null'
				case 'short': return '0'
				case 'java.lang.Short': return '0'
				case 'java.lang.String': return "''"
				case 'org.eclipse.emf.common.util.TreeIterator': return 'null'
				case 'java.lang.reflect.InvocationTargetException': return 'null'
			}

		}

	}
}
