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

import com.crossecore.EcoreVisitor
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage

class FactoryImplGenerator extends EcoreVisitor{
	
	private IdentifierProvider id = new TypeScriptIdentifier();
	//private TypeTranslator t = new TypeScriptTypeTranslator(id);
	private TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	//private ImportManager imports = new ImportManager(t);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage (EPackage epackage) {
		var eclasses = epackage.EClassifiers.filter[c|c instanceof EClass].map[c|c as EClass].filter[c|!c.interface && !c.abstract];
		var edatatypes = epackage.EClassifiers.filter[c|c instanceof EDataType && (c as EDataType).serializable].map[c|c as EDataType];//TODO propagate serializable check
		tt.import_(epackage, id.EPackageFactory(epackage));
		tt.import_(EcorePackage.eINSTANCE, "EFactoryImpl");
		tt.import_(EcorePackage.eINSTANCE, "AllInstances");
		
		var body = '''
		export class «id.EPackageFactoryImpl(epackage)» extends EFactoryImpl implements «id.EPackageFactory(epackage)»{
			public static eINSTANCE : «id.EPackageFactory(epackage)» = «id.EPackageFactoryImpl(epackage)».init();
			public static init() : «id.EPackageFactory(epackage)» 
			{
				return new «id.EPackageFactoryImpl(epackage)»();
			}
			
			«FOR EClassifier classifier: epackage.EClassifiers»
				«doSwitch(classifier)»
			«ENDFOR»
			
			«IF !eclasses.empty»
			«{tt.import_(EcorePackage.Literals.EOBJECT)}»
			«{tt.import_(EcorePackage.Literals.ECLASS)}»
			public create(eClass:EClass):EObject {
				switch (eClass.getClassifierID()) {
					«FOR EClass c:eclasses»
						«IF Utils.isEcoreEPackage(epackage)»
						case «c.classifierID»: return this.«id.createEClass(c)»();
						«ELSE»
						case «id.EPackagePackageImpl(epackage)».«id.literal(c)»: return this.«id.createEClass(c)»();
						«ENDIF»
					«ENDFOR»
					default:
						throw new Error("The class '" + eClass.name + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			«IF !edatatypes.empty»
			«{tt.import_(EcorePackage.Literals.EDATA_TYPE)}»
			
			public createFromString(eDataType:EDataType, initialValue:string):any {
				switch (eDataType.getClassifierID()) {
				«FOR EDataType e : edatatypes»
				«{tt.import_(e)}»
				«IF Utils.isEcoreEPackage(epackage)»
				case «e.classifierID»: //«id.EPackagePackageImpl(epackage)».«id.literal(e)»
					return this.«id.createEDataTypeFromString(e)»(eDataType, initialValue);				
				«ELSE»
				case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
					return this.«id.createEDataTypeFromString(e)»(eDataType, initialValue);
				«ENDIF»
				«ENDFOR»
				default:
					throw new Error("The datatype '" + eDataType.name + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			«IF !edatatypes.empty»
			public convertToString(eDataType:EDataType, instanceValue:any):string {
				switch (eDataType.getClassifierID()) {
				«FOR EDataType e : edatatypes»
				«IF Utils.isEcoreEPackage(epackage)»
				case «e.classifierID»: //«id.EPackagePackageImpl(epackage)».«id.literal(e)»
					return this.«id.convertEDataTypeToString(e)»(eDataType, instanceValue);				
				«ELSE»
				case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
					return this.«id.convertEDataTypeToString(e)»(eDataType, instanceValue);
				«ENDIF»
				«ENDFOR»
				default:
					throw new Error("The datatype '" + eDataType.name + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			
			«FOR EDataType e : edatatypes»
			«IF e instanceof EEnum»
			public «id.createEDataTypeFromString(e)»(eDataType:EDataType, initialValue:string):«tt.translateType(e)» {
				let result:«id.doSwitch(e)» = «id.doSwitch(e)».get_string(initialValue);
				if (result == null)
					throw new Error(
	                        "The value '" + initialValue + "' is not a valid enumerator of '" + eDataType.name + "'");
				return result;
			}
			
			public «id.convertEDataTypeToString(e)»(eDataType:EDataType, instanceValue:any):string {
				return instanceValue === null ? null : instanceValue.toString();
			}
			«ELSE»
			public «id.createEDataTypeFromString(e)»(eDataType:EDataType, initialValue:string):«tt.translateType(e)» {

				return initialValue == null ? null : JSON.parse(initialValue);
			}
			
			public «id.convertEDataTypeToString(e)»(eDataType:EDataType, instanceValue:any):string {
				return instanceValue === null ? null : JSON.stringify(instanceValue);
			}
			«ENDIF»
			«ENDFOR»			
		}
		''';
		
		return 
		'''
		«tt.printImports(epackage)»
		«body»
		'''
		
	}

	
	override caseEClass(EClass e){
		if(!e.interface){
			tt.import_(e);
			tt.import_(e.EPackage, id.EClassImpl(e));
			
			if(!Utils.isEcoreEPackage(e.EPackage)){
				//prevent cyclic dependency
				tt.import_(e.EPackage, id.EPackagePackageImpl(e.EPackage));
			}
			
			'''
				public «id.createEClass(e)» = () : «id.doSwitch(e)» => {
					let «id.variable(e)» = new «id.EClassImpl(e)»();
					
					AllInstances.INSTANCE.put(«id.variable(e)», "«id.doSwitch(e)»");
					
					return «id.variable(e)»;
				}
			'''
		}

	
	}
	
	
	
}