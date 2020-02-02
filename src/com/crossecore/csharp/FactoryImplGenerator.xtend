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
package com.crossecore.csharp

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import com.crossecore.TypeTranslator

class FactoryImplGenerator extends CSharpVisitor {
	
	private IdentifierProvider id = new CSharpIdentifier();
	TypeTranslator tt = new CSharpTypeTranslator(id);
	
	private String header = '''
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
	
	
	override caseEPackage (EPackage epackage) {
		var eclasses = epackage.EClassifiers.filter[c|c instanceof EClass].map[c|c as EClass].filter[c|!c.interface && !c.abstract];
		var edatatypes = epackage.EClassifiers.filter[c|c instanceof EDataType].map[c|c as EDataType];
		//var eenums = epackage.EClassifiers.filter[c|c instanceof EEnum].map[c|c as EEnum];
		
		
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
		using System;
		using System.IO;
		using System.Runtime.Serialization.Formatters.Binary;	 	
		namespace «id.doSwitch(epackage)»{
			public class «id.EPackageFactoryImpl(epackage)» : EFactoryImpl, «id.EPackageFactory(epackage)» {
				
				public static «id.EPackageFactory(epackage)» eINSTANCE = «id.EPackageFactoryImpl(epackage)».init();
		
		        public static «id.EPackageFactory(epackage)» init()
		        {
		            return new «id.EPackageFactoryImpl(epackage)»();
		        }
				
				«FOR EClassifier classifier: epackage.EClassifiers»
					«doSwitch(classifier)»
				«ENDFOR»
				
				«IF !eclasses.empty»
				public override EObject create(EClass eClass) {
					switch (eClass.getClassifierID()) {
						«FOR EClass c:eclasses»
							case «id.EPackagePackageImpl(epackage)».«id.literal(c)»: return «id.createEClass(c)»();
						«ENDFOR»
						default:
							throw new ArgumentException("The class '" + eClass.name + "' is not a valid classifier");
					}
				}
				«ENDIF»
				
				«IF !edatatypes.empty»
				public override object createFromString(EDataType eDataType, string initialValue) {
					switch (eDataType.getClassifierID()) {
					«FOR EDataType e : edatatypes»
					case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
						return «id.createEDataTypeFromString(e)»(eDataType, initialValue);
					«ENDFOR»
					default:
						throw new ArgumentException("The datatype '" + eDataType.name + "' is not a valid classifier");
					}
				}
				«ENDIF»
				
				«IF !edatatypes.empty»
				public override String convertToString(EDataType eDataType, object instanceValue) {
					switch (eDataType.getClassifierID()) {
					«FOR EDataType e : edatatypes»
					case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
						return «id.convertEDataTypeToString(e)»(eDataType, instanceValue);
					«ENDFOR»
					default:
						throw new ArgumentException("The datatype '" + eDataType.name + "' is not a valid classifier");
					}
				}
				«ENDIF»
				
				
				«FOR EDataType e : edatatypes»
				«IF e instanceof EEnum»
				public «id.doSwitch(e)» «id.createEDataTypeFromString(e)»(EDataType eDataType, String initialValue) {
					«id.doSwitch(e)» result = «id.doSwitch(e)».get(initialValue);
					if (result == null)
						throw new ArgumentException(
							"The value '" + initialValue + "' is not a valid enumerator of '" + eDataType.name + "'");
					return result;
				}
				
				public String «id.convertEDataTypeToString(e)»(EDataType eDataType, object instanceValue) {
					return instanceValue == null ? null : instanceValue.ToString();
				}
				«ELSE»
				public «tt.translateType(e)» «id.createEDataTypeFromString(e)»(EDataType eDataType, String initialValue) {
					byte[] b = Convert.FromBase64String(initialValue);
					var stream = new MemoryStream(b);
					var formatter = new BinaryFormatter();
					stream.Seek(0, SeekOrigin.Begin);
					return («tt.translateType(e)») formatter.Deserialize(stream);
				}
				
				public String «id.convertEDataTypeToString(e)»(EDataType eDataType, object instanceValue) {
					MemoryStream memorystream = new MemoryStream();
					BinaryFormatter bf = new BinaryFormatter();
					bf.Serialize(memorystream, instanceValue);
					byte[] yourBytesToDb = memorystream.ToArray();
					return Convert.ToBase64String(yourBytesToDb);
				}				
				«ENDIF»
				«ENDFOR»
				
				
				/*
				public «id.EPackagePackage(epackage)» «id.getEPackage(epackage)»() {
					return («id.EPackagePackage(epackage)») getEPackage();
				}
				*/

			
			}
		}
		'''
	}

	
	override caseEClass(EClass e){
		if(!e.interface){
			'''
			public «id.doSwitch(e)» «id.createEClass(e)»(){
				var «id.variable(e)» = new «id.EClassImpl(e)»();
				«id.EClassImpl(e)».allInstances_.Add(«id.variable(e)»);
				
				return «id.variable(e)»;
			}
			'''
		
		}
	
	}
	
}