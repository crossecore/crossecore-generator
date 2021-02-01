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

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.IdentifierProvider
import com.crossecore.EcoreVisitor
import com.crossecore.TypeTranslator
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.ecore.EDataType

class FactoryImplGenerator extends EcoreVisitor {
	
	IdentifierProvider id = new JavaIdentifier();
	TypeTranslator t = new JavaTypeTranslator(id);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage (EPackage epackage) {
		
		var eclasses = epackage.EClassifiers.filter[c|c instanceof EClass].map[c|c as EClass].filter[c|!c.interface && !c.abstract];
		var edatatypes = epackage.EClassifiers.filter[c|c instanceof EDataType].map[c|c as EDataType];
		
		'''
		package «epackage.name»;
		import org.eclipse.emf.ecore.*;
		public class «id.EPackageFactoryImpl(epackage)» extends org.eclipse.emf.ecore.impl.EFactoryImpl implements «id.EPackageFactory(epackage)» {
			
			public static «id.EPackageFactory(epackage)» eINSTANCE = «id.EPackageFactoryImpl(epackage)».init();
			public static «id.EPackageFactory(epackage)» init()
			{
				
				try {
					«id.EPackageFactory(epackage)» factory = («id.EPackageFactory(epackage)»)EPackage.Registry.INSTANCE.getEFactory(«id.EPackagePackageImpl(epackage)».eNS_URI);
					if (factory != null) {
						return factory;
					}
				}
				catch (Exception exception) {
					
				}
				return new «id.EPackageFactoryImpl(epackage)»();
			}
			
			«FOR EClassifier classifier: epackage.EClassifiers»
				«doSwitch(classifier)»
			«ENDFOR»
			
			«IF !eclasses.empty»
			@Override
			public EObject create(EClass eClass) {
				switch (eClass.getClassifierID()) {
					«FOR EClass c:eclasses»
						case «id.EPackagePackageImpl(epackage)».«id.literal(c)»: return «id.createEClass(c)»();
					«ENDFOR»
					default:
						throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			«IF !edatatypes.empty»
			@Override
			public Object createFromString(EDataType eDataType, String initialValue) {
				switch (eDataType.getClassifierID()) {
				«FOR EDataType e : edatatypes»
				case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
					return «id.createEDataTypeFromString(e)»(eDataType, initialValue);
				«ENDFOR»
				default:
					throw new IllegalArgumentException("The datatype '" + eDataType.getName() + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			«IF !edatatypes.empty»
			@Override
			public String convertToString(EDataType eDataType, Object instanceValue) {
				switch (eDataType.getClassifierID()) {
				«FOR EDataType e : edatatypes»
				case «id.EPackagePackageImpl(epackage)».«id.literal(e)»:
					return «id.convertEDataTypeToString(e)»(eDataType, instanceValue);
				«ENDFOR»
				default:
					throw new IllegalArgumentException("The datatype '" + eDataType.getName() + "' is not a valid classifier");
				}
			}
			«ENDIF»
			
			«FOR EDataType e : edatatypes»
			public «id.doSwitch(e)» «id.createEDataTypeFromString(e)»(EDataType eDataType, String initialValue) {
				«id.doSwitch(e)» result = «id.doSwitch(e)».get(initialValue);
				if (result == null)
					throw new IllegalArgumentException(
							"The value '" + initialValue + "' is not a valid enumerator of '" + eDataType.getName() + "'");
				return result;
			}
			
			public String «id.convertEDataTypeToString(e)»(EDataType eDataType, Object instanceValue) {
				return instanceValue == null ? null : instanceValue.toString();
			}
			«ENDFOR»
			
			public «id.EPackagePackage(epackage)» «id.getEPackage(epackage)»() {
				return («id.EPackagePackage(epackage)») getEPackage();
			}			
		}
		'''
	}
	
	override caseEClass(EClass e){
		
		var superclasses = new BasicEList<EClass>(e.EAllSuperTypes);
		superclasses.add(e);
		
		
		if(!e.interface && !e.abstract){
			'''
			public «t.translateType(e)» «id.createEClass(e)»(){
				«id.EClassImpl(e)» «id.variable(e)» = new «id.EClassImpl(e)»();
				
				«id.doSwitch(e)».allInstances_.add(«id.variable(e)»);
				/*
				«FOR sup: superclasses»
					«id.doSwitch(sup)».allInstances.add(«id.variable(e)»);
				«ENDFOR»
				*/
				
				return «id.variable(e)»;
			}
			'''
		}
	
	}
	
	
}