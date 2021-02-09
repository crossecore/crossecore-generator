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

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import java.util.Collection
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.util.EcoreUtil
import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.common.util.BasicEList

class PackageImplGenerator extends CSharpVisitor{
	
	IdentifierProvider id = new CSharpIdentifier();
	//private CSharpLiteralIdentifier literalId = new CSharpLiteralIdentifier();
	TypeTranslator tt = new CSharpTypeTranslator(id);
	
	String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage(EPackage epackage){
	var sortedEClasses_ = new BasicEList<EClassifier>();
	sortedEClasses_.addAll(DependencyManager.sortEClasses(epackage)); 
	
	var Collection<EClass> eclasses =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
	var Collection<EEnum> enums =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EENUM);
	var Collection<EDataType> edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
	
	sortedEClasses_.addAll(edatatypes);
	var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
	
	
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
	 	using Ecore;
	 	«ENDIF»
		namespace «id.doSwitch(epackage)»{
			public class «id.EPackagePackageImpl(epackage)» : EPackageImpl, «id.EPackagePackage(epackage)»{
					public const string eNAME = "«epackage.name»";
					
					public const string eNS_URI = "«epackage.nsURI»";
					
					public const string eNS_PREFIX = "«epackage.nsPrefix»";
					
					public static «id.EPackagePackage(epackage)» eINSTANCE = init();
					
					private «id.EPackagePackageImpl(epackage)»():base(eNS_URI, «id.EPackageFactoryImpl(epackage)».eINSTANCE)
					{
						
					}
					
		            public static «id.EPackagePackage(epackage)» init()
		            {
		                // Obtain or create and register package
		                var the«id.EPackagePackage(epackage)» = new «id.EPackagePackageImpl(epackage)»();
		
		                // Create package meta-data objects
		                the«id.EPackagePackage(epackage)».createPackageContents();
		
		                // Initialize created meta-data
		                the«id.EPackagePackage(epackage)».initializePackageContents();
		
				        return the«id.EPackagePackage(epackage)»;
			        }
			        
			        private bool isCreated = false;
		            public void createPackageContents()
		            {
		                if (isCreated) return;
		                isCreated = true;
						«FOR EClass eclass:eclasses»
							«id.EClassEClass(eclass)» = createEClass(«id.literal(eclass)»);
							«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
								«IF feature instanceof EReference»
								createEReference(«id.EClassEClass(eclass)», «id.literal(feature)»);
								«ELSEIF feature instanceof EAttribute»
								createEAttribute(«id.EClassEClass(eclass)», «id.literal(feature)»);
								«ENDIF»
							«ENDFOR»
						«ENDFOR»
						
						«FOR EEnum eenum:enums»
							«id.EEnumEEnum(eenum)» = createEEnum(«id.literal(eenum)»);
						«ENDFOR»
						
						
			        }
			        
			        private bool isInitialized = false;
			        public void initializePackageContents()
			        {
		                if (isInitialized) return;
		                isInitialized = true;
			            // Initialize package
			            name = eNAME;
			            nsPrefix = eNS_PREFIX;
			            nsURI = eNS_URI;
			
						«FOR EClass e:eclasses»
							
							«FOR EClass super_:e.ESuperTypes»
								«IF super_.EPackage.nsURI.equals(epackage.nsURI)»
								«id.EClassEClass(e)».eSuperTypes.add(«id.getEClass(super_)»());
								«ELSE»
								«id.EClassEClass(e)».eSuperTypes.add(«id.doSwitch(super_.EPackage)».«id.EPackagePackageImpl(super_.EPackage)».eINSTANCE.«id.getEClass(super_)»());
								«ENDIF»
							«ENDFOR»
						«ENDFOR»
						
						«FOR EClass e:eclasses»
							initEClass(«id.EClassEClass(e)», typeof(«id.doSwitch(e)»), "«id.doSwitch(e)»", «IF !e.abstract»!«ENDIF»IS_ABSTRACT, «IF !e.interface»!«ENDIF»IS_INTERFACE, IS_GENERATED_INSTANCE_CLASS);						
							
							«FOR EAttribute a:e.EAttributes»
							initEAttribute(«id.getEAttribute(a)»(), 
								«IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
								"«id.doSwitch(a)»", 
								«IF a.defaultValue===null»null«ELSE»"«a.defaultValue»"«ENDIF», 
								«a.lowerBound», 
								«a.upperBound», 
								typeof(«e.name»), 
								«IF !a.transient»!«ENDIF»IS_TRANSIENT, 
								«IF !a.volatile»!«ENDIF»IS_VOLATILE, 
								«IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
								«IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
								«IF !a.isID»!«ENDIF»IS_ID, 
								«IF !a.unique»!«ENDIF»IS_UNIQUE, 
								«IF !a.derived»!«ENDIF»IS_DERIVED, 
								«IF !a.ordered»!«ENDIF»IS_ORDERED);
							«ENDFOR»
							
							«FOR EReference a:e.EReferences»
							initEReference(
								«id.getEReference(a)»(), 
								«IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
								«IF a.EOpposite!==null»«id.getEReference(a.EOpposite)»()«ELSE»null«ENDIF», 
								"«id.doSwitch(a)»", 
								«IF a.defaultValue !== null»«a.defaultValue»«ELSE»null«ENDIF», 
								«a.lowerBound», 
								«a.upperBound», 
								typeof(«e.name»), 
								«IF !a.transient»!«ENDIF»IS_TRANSIENT, 
								«IF !a.volatile»!«ENDIF»IS_VOLATILE, 
								«IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
								«IF !a.containment»!«ENDIF»IS_COMPOSITE, 
								«IF !a.resolveProxies»!«ENDIF»IS_RESOLVE_PROXIES, 
								«IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
								«IF !a.unique»!«ENDIF»IS_UNIQUE, 
								«IF !a.derived»!«ENDIF»IS_DERIVED, 
								«IF !a.ordered»!«ENDIF»IS_ORDERED);
							«ENDFOR»
						«ENDFOR»
					«FOR EEnum e:enums»
					initEEnum(«id.EEnumEEnum(e)», typeof(«id.doSwitch(e)»), "«e.name»");
					«FOR EEnumLiteral literal:e.ELiterals»
					//addEEnumLiteral(«id.EEnumEEnum(e)», «id.doSwitch(e)».«literal.name.toUpperCase»);
					«ENDFOR»
					«ENDFOR»
			        }
			        
					
					«FOR EClass eclass:eclasses»
						private EClass «id.EClassEClass(eclass)» = null;
					«ENDFOR»
					
					
					«FOR EEnum eenum:enums»
						private EEnum «id.EEnumEEnum(eenum)» = null;
					«ENDFOR»
					
					«FOR EDataType edatatype:edatatypes»
						private EDataType «id.EDataTypeEDataType(edatatype)» = null;
					«ENDFOR»
					
					
					«FOR EClassifier eclassifier: sortedEClasses»
						«metaobjectid.doSwitch(eclassifier)»
					«ENDFOR»
					
					
					«FOR EClassifier eclassifier: sortedEClasses»
						«doSwitch(eclassifier)»
					«ENDFOR»
					
					public class Literals{
						«FOR EClassifier eclassifier: sortedEClasses»
							«literals.doSwitch(eclassifier)»
						«ENDFOR»
					}
			 
			}
		}
		'''
	
	}
	
	var metaobjectid = new CSharpVisitor(epackage){
		

		override caseEEnum(EEnum enumeration){
			'''
			public const int «id.literal(enumeration)» = «enumeration.classifierID»;
			'''
			
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			public const int «id.literal(edatatype)» = «edatatype.classifierID»;
			'''
		}
		
		override caseEClass(EClass eclassifier){

			var i = 0;

			'''
			public const int «id.literal(eclassifier)» = «eclassifier.classifierID»;
			public const int «id.EClassifier_FEATURE_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«IF !eclassifier.EPackage.equals(_super.EPackage)»«id.doSwitch(_super.EPackage)».«id.EPackagePackageImpl(_super.EPackage)».«ENDIF»«id.EClassifier_FEATURE_COUNT(_super)»«ENDFOR»«eclassifier.EStructuralFeatures.size»;
			public const int «id.EClassifier_OPERATION_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«IF !eclassifier.EPackage.equals(_super.EPackage)»«id.doSwitch(_super.EPackage)».«id.EPackagePackageImpl(_super.EPackage)».«ENDIF»«id.EClassifier_OPERATION_COUNT(_super)»«ENDFOR»«eclassifier.EOperations.size»;
			
			«FOR EStructuralFeature feature:eclassifier.EAllStructuralFeatures»
				public const int «id.literal(eclassifier,feature)» = «i++»;
			«ENDFOR»
			
			'''
		
		}
		
		
	}
	
	val literals = new CSharpVisitor(epackage) {
		

		
		override caseEClass(EClass eclass){
			'''
			public static EClass «id.literal(eclass)» = «id.EPackagePackageImpl(eclass.EPackage)».eINSTANCE.«id.getEClass(eclass)»();
			
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
			public static EEnum «id.literal(enumeration)» = «id.EPackagePackageImpl(enumeration.EPackage)».eINSTANCE.«id.getEEnum(enumeration)»();
			'''
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			public static EDataType «id.literal(edatatype)» = «id.EPackagePackageImpl(edatatype.EPackage)».eINSTANCE.«id.getEDataType(edatatype)»();
			'''
		}
	
		override caseEReference(EReference ereference){
			'''
			public static EReference «id.literal(ereference)» = «id.EPackagePackageImpl(ereference.EContainingClass.EPackage)».eINSTANCE.«id.getEReference(ereference)»();
			'''
		}
		
		override caseEAttribute(EAttribute eattribute){
			'''
			public static EAttribute «id.literal(eattribute)» = «id.EPackagePackageImpl(eattribute.EContainingClass.EPackage)».eINSTANCE.«id.getEAttribute(eattribute)»();
			'''
		}
	
	};
	
	override caseEDataType(EDataType edatatype){
		'''
		public EDataType «id.getEDataType(edatatype)»(){return «id.EDataTypeEDataType(edatatype)»;}
		'''
		
	}
	
	override caseEEnum(EEnum enumeration){
		'''
		public EEnum «id.getEEnum(enumeration)»(){return «id.EEnumEEnum(enumeration)»;}
		'''
		
	}
	
	override caseEClass(EClass eclass){
		var featureIdx = 0;
		'''
		public EClass «id.getEClass(eclass)»(){return «id.EClassEClass(eclass)»;}
		
		«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
			«IF feature instanceof EAttribute»
			public EAttribute «id.getEAttribute(feature as EAttribute)»(){return (EAttribute)«id.EClassEClass(feature.EContainingClass)».eStructuralFeatures.at(«featureIdx++»);}
			«ELSEIF feature instanceof EReference»
			public EReference «id.getEReference(feature as EReference)»(){return (EReference)«id.EClassEClass(feature.EContainingClass)».eStructuralFeatures.at(«featureIdx++»);}
			«ENDIF»
		«ENDFOR»
		'''
	
	}
	
}