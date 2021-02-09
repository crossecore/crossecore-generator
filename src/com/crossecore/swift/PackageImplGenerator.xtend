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

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EAttribute
import com.crossecore.DependencyManager
import org.eclipse.emf.ecore.EStructuralFeature
import com.crossecore.Utils
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider
import java.util.Collection
import java.util.ArrayList

class PackageImplGenerator extends EcoreVisitor{
	
	IdentifierProvider id = new SwiftIdentifier();
	//private CSharpLiteralIdentifier literalId = new CSharpLiteralIdentifier();
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	
	
	
	override caseEPackage(EPackage epackage){
		var sortedEClasses = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
		
		var Collection<EClass> eclasses =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
		var Collection<EEnum> enums =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EENUM);
		var Collection<EDataType> edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses.addAll(edatatypes);
	
		'''
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
			class «id.EPackagePackageImpl(epackage)» : EPackageImpl, «id.EPackagePackage(epackage)»{
					let eNAME = "«epackage.name»";
					
					let eNS_URI = "«epackage.nsURI»";
					
					let eNS_PREFIX = "«epackage.nsPrefix»";
					
					static let eINSTANCE = initialize(); //TODO as? «id.EPackagePackage(epackage)»
					
					/*
					override init()
					{
						super.init(packageURI: eNS_URI, factory: «id.EPackageFactoryImpl(epackage)».eINSTANCE);

					}
					*/
					
		            static func initialize() -> «id.EPackagePackage(epackage)»
		            {
		                // Obtain or create and register package
		                let the«id.EPackagePackage(epackage)» = «id.EPackagePackageImpl(epackage)»();
		
		                // Create package meta-data objects
		                the«id.EPackagePackage(epackage)».createPackageContents();
		
		                // Initialize created meta-data
		                the«id.EPackagePackage(epackage)».initializePackageContents();
		
				        return the«id.EPackagePackage(epackage)»;
			        }
			        
			        var isCreated = false;//TODO private
		            func createPackageContents()
		            {
		                if (isCreated){return;}
		                isCreated = true;
						«FOR EClass eclass:eclasses»
							«id.EClassEClass(eclass)» = createEClass(id: «id.EPackagePackageImpl(epackage)».«id.literal(eclass)»);
							«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
								«IF feature instanceof EReference»
								createEReference(owner: «id.EClassEClass(eclass)»!, id: «id.EPackagePackageImpl(epackage)».«id.literal(feature)»);
								«ELSEIF feature instanceof EAttribute»
								createEAttribute(owner: «id.EClassEClass(eclass)»!, id: «id.EPackagePackageImpl(epackage)».«id.literal(feature)»);
								«ENDIF»
							«ENDFOR»
						«ENDFOR»
						
						«FOR EEnum eenum:enums»
							«id.EEnumEEnum(eenum)» = createEEnum(id: «id.EPackagePackageImpl(epackage)».«id.literal(eenum)»);
						«ENDFOR»
			        }
			        
			        private var isInitialized = false;
			        func initializePackageContents()
			        {
		                if (isInitialized){return;}
		                isInitialized = true;
			            // Initialize package
			            name = eNAME;
			            nsPrefix = eNS_PREFIX;
			            nsURI = eNS_URI;
			
						«FOR EClass e:eclasses»
							
							«FOR EClass super_:e.ESuperTypes»
								//TODO as! EClassImpl
								«id.EClassEClass(e)»?.eSuperTypes?.add(element: «id.getEClass(super_)»() as! EClassImpl);
							«ENDFOR»
						«ENDFOR»
						
						«FOR EClass e:eclasses»
							initEClass(c: «id.EClassEClass(e)»!, 
							instanceClass: Mirror(reflecting: «id.doSwitch(e)»), 
							name:"«id.doSwitch(e)»", 
							isAbstract: «IF !e.abstract»!«ENDIF»IS_ABSTRACT, 
							isInterface: «IF !e.interface»!«ENDIF»IS_INTERFACE, 
							isGenerated: IS_GENERATED_INSTANCE_CLASS);
							
							«FOR EAttribute a:e.EAttributes»
							initEAttribute(a: «id.getEAttribute(a)»()!, 
								type:«IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()!«ELSE»self.«id.getEClassifier(a.EType)»()!«ENDIF», 
								name: "«id.doSwitch(a)»", 
								defaultValue: «IF a.defaultValue===null»nil«ELSE»"«a.defaultValue»"«ENDIF», 
								lowerBound: «a.lowerBound», 
								upperBound: «a.upperBound», 
								containerClass: Mirror(reflecting: EAttribute), 
								isTransient: «IF !a.transient»!«ENDIF»IS_TRANSIENT, 
								isVolatile: «IF !a.volatile»!«ENDIF»IS_VOLATILE, 
								isChangeable: «IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
								isUnsettable: «IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
								isID: «IF !a.isID»!«ENDIF»IS_ID, 
								isUnique: «IF !a.unique»!«ENDIF»IS_UNIQUE, 
								isDerived: «IF !a.derived»!«ENDIF»IS_DERIVED, 
								isOrdered: «IF !a.ordered»!«ENDIF»IS_ORDERED);
							«ENDFOR»
							
							«FOR EReference a:e.EReferences»
							initEReference(
								r: «id.getEReference(a)»()!, 
								type: «IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()!«ELSE»self.«id.getEClassifier(a.EType)»()!«ENDIF», 
								otherEnd: «IF a.EOpposite!==null»«id.getEReference(a.EOpposite)»()«ELSE»nil«ENDIF», 
								name: "«id.doSwitch(a)»", 
								defaultValue: «IF a.defaultValue !== null»«a.defaultValue»«ELSE»nil«ENDIF», 
								lowerBound: «a.lowerBound», 
								upperBound: «a.upperBound», 
								containerClass: Mirror(reflecting: «e.name»), 
								isTransient: «IF !a.transient»!«ENDIF»IS_TRANSIENT, 
								isVolatile: «IF !a.volatile»!«ENDIF»IS_VOLATILE, 
								isChangeable: «IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
								isContainment: «IF !a.containment»!«ENDIF»IS_COMPOSITE, 
								isResolveProxies: «IF !a.resolveProxies»!«ENDIF»IS_RESOLVE_PROXIES, 
								isUnsettable: «IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
								isUnique: «IF !a.unique»!«ENDIF»IS_UNIQUE, 
								isDerived: «IF !a.derived»!«ENDIF»IS_DERIVED, 
								isOrdered: «IF !a.ordered»!«ENDIF»IS_ORDERED);
							«ENDFOR»
							
						«ENDFOR»
			        }
			        
					
					«FOR EClass eclass:eclasses»
						private var «id.EClassEClass(eclass)» : EClass? = nil;
					«ENDFOR»
					
					
					«FOR EEnum eenum:enums»
						private var «id.EEnumEEnum(eenum)» : EEnum? = nil;
					«ENDFOR»
					
					«FOR EDataType edatatype:edatatypes»
						private var «id.EDataTypeEDataType(edatatype)» : EDataType? = nil;
					«ENDFOR»
					
					
					«FOR EClassifier eclassifier: sortedEClasses»
						«metaobjectid.doSwitch(eclassifier)»
					«ENDFOR»
					
					
					«FOR EClassifier eclassifier: sortedEClasses»
						«doSwitch(eclassifier)»
					«ENDFOR»
					
					class Literals{
						«FOR EClassifier eclassifier: sortedEClasses»
							«literals.doSwitch(eclassifier)»
						«ENDFOR»
					}
			 
		}
		'''
	
	}
	
	var metaobjectid = new EcoreVisitor(epackage){
		

		
		
		override caseEEnum(EEnum enumeration){
			'''
			static var «id.literal(enumeration)» = «enumeration.classifierID»;
			'''
			
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			static var «id.literal(edatatype)» = «edatatype.classifierID»;
			'''
		}
		
		override caseEClass(EClass eclassifier){

			var i = 0;

			'''
			static var «id.literal(eclassifier)» = «eclassifier.classifierID»;
			static var «id.EClassifier_FEATURE_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EClassifier_FEATURE_COUNT(_super)»«ENDFOR»«eclassifier.EStructuralFeatures.size»;
			static var «id.EClassifier_OPERATION_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EClassifier_OPERATION_COUNT(_super)»«ENDFOR»«eclassifier.EOperations.size»;
			
			«FOR EStructuralFeature feature:eclassifier.EAllStructuralFeatures»
				static var «id.literal(eclassifier,feature)» = «i++»;
			«ENDFOR»
			'''
		
		}
		
		
		
	}
	
	val literals = new EcoreVisitor(epackage) {
		
		
		
		override caseEClass(EClass eclass){
			'''
			
			static let «id.literal(eclass)» = «id.EPackagePackageImpl(eclass.EPackage)».eINSTANCE.«id.getEClass(eclass)»();//TODO as? EClass casting required?
			
			«FOR EReference ereference:eclass.EReferences»
				«doSwitch(ereference)»
			«ENDFOR»
			
			«FOR EAttribute eattribute:eclass.EAttributes»
				«doSwitch(eattribute)»
			«ENDFOR»
			'''
		}
		
		override caseEEnum(EEnum enumeration){
			'''
			static let «id.literal(enumeration)» = «id.EPackagePackageImpl(enumeration.EPackage)».eINSTANCE.«id.getEEnum(enumeration)»();
			'''
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			static let «id.literal(edatatype)» = «id.EPackagePackageImpl(edatatype.EPackage)».eINSTANCE.«id.getEDataType(edatatype)»();
			'''
		}
	
		override caseEReference(EReference ereference){
			'''
			static let «id.literal(ereference)» = «id.EPackagePackageImpl(ereference.EContainingClass.EPackage)».eINSTANCE.«id.getEReference(ereference)»();
			'''
		}
		
		override caseEAttribute(EAttribute eattribute){
			'''
			static let «id.literal(eattribute)» = «id.EPackagePackageImpl(eattribute.EContainingClass.EPackage)».eINSTANCE.«id.getEAttribute(eattribute)»() as? EAttribute;
			'''
		}
		
	
	};
	
	override caseEDataType(EDataType edatatype){
		'''
		func «id.getEDataType(edatatype)»() -> EDataType?{return «id.EDataTypeEDataType(edatatype)»;}
		'''
		
	}
	
	override caseEEnum(EEnum enumeration){
		'''
		func «id.getEEnum(enumeration)»() -> EEnum?{return «id.EEnumEEnum(enumeration)»;}
		'''
		
	}
	
	override caseEClass(EClass eclass){
		var featureIdx = 0;
		'''
		func «id.getEClass(eclass)»() -> EClass?{return «id.EClassEClass(eclass)»;}
		
		«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
			«IF feature instanceof EAttribute»
			func «id.getEAttribute(feature as EAttribute)»() -> EAttribute?{return «id.EClassEClass(feature.EContainingClass)»?.eStructuralFeatures?.at(i:«featureIdx++») as! EAttribute;}
			«ELSEIF feature instanceof EReference»
			func «id.getEReference(feature as EReference)»() -> EReference?{return «id.EClassEClass(feature.EContainingClass)»?.eStructuralFeatures?.at(i:«featureIdx++») as! EReference;}
			«ENDIF»
		«ENDFOR»
		'''
	
	}
	
}