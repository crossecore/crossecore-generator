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

import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EEnum
import com.crossecore.EcoreVisitor
import com.crossecore.IdentifierProvider
import java.util.Collection
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.ArrayList
import com.crossecore.DependencyManager
import org.eclipse.emf.ecore.EStructuralFeature
import com.crossecore.Utils
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.ImportManager
import org.eclipse.emf.ecore.EObject
import java.util.List
import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.impl.EcorePackageImpl
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.impl.EClassifierImpl
import org.eclipse.emf.ecore.impl.EPackageImpl

class PackageImplGenerator extends TypeScriptVisitor{
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	//private TypeTranslator t = new TypeScriptTypeTranslator(id);
	//private ImportManager imports = new ImportManager(t);
	private TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2()
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);
		

	}
	
	
	override caseEPackage(EPackage epackage){
		var sortedEClasses_ = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
	
		var Collection<EClass> eclasses =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
		var Collection<EEnum> enums =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EENUM);
		var Collection<EDataType> edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		var Collection<EDataType> edatatypes2 = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		edatatypes2.removeAll(enums);
		sortedEClasses_.addAll(edatatypes);
		
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		
		var allLiterals = new ArrayList<EObject>();
		allLiterals.addAll(epackage.EClassifiers);
		
		for(EClassifier e : sortedEClasses){
			
			if(e instanceof EClass){
				for(EStructuralFeature f: (e as EClass).EStructuralFeatures){
					allLiterals.add(f);	
				}	
			}
		}
		
		for(EEnum e : enums){
			
			allLiterals.add(e);	
		}
		
		allLiterals.addAll(EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EATTRIBUTE));
		allLiterals.addAll(EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EREFERENCE));
		
		
		tt.import_(EcorePackage.eINSTANCE, "EPackageImpl");
		tt.import_(EcorePackage.eINSTANCE, "EFactory");
		//tt.import_(epackage, id.EPackageFactoryImpl(epackage)); //causes circular dependency!
		tt.import_(epackage, id.EPackagePackage(epackage));
		if(!Utils.isEcoreEPackage(epackage)){
			
			tt.import_(EcorePackage.eINSTANCE, "EcorePackageImpl")
		}
		tt.import_(EcorePackage.eINSTANCE, "EcoreFactoryImpl") //causes circular dependency!
		var body = 
		'''
		export class «id.EPackagePackageImpl(epackage)» extends EPackageImpl implements «id.EPackagePackage(epackage)»{
				public static eNAME:string = "«epackage.name»";
				
				public static eNS_URI:string = "«epackage.nsURI»";
				
				public static eNS_PREFIX:string = "«epackage.nsPrefix»";
				
				
				
				/*
				constructor(){
					//no private constructors in TypeScript
					super(«id.EPackagePackageImpl(epackage)».eNS_URI, «id.EPackageFactoryImpl(epackage)».eINSTANCE as any as EFactory);
				}
				*/
				
				public static init():«id.EPackagePackage(epackage)»
				{

			        // Obtain or create and register package
			        let the«id.EPackagePackage(epackage)» = new «id.EPackagePackageImpl(epackage)»();
			        «IF Utils.isEcoreEPackage(epackage)»
			        the«id.EPackagePackage(epackage)».ecorePackage = the«id.EPackagePackage(epackage)»;
			        «ELSE»
			        the«id.EPackagePackage(epackage)».ecorePackage = «id.EPackagePackageImpl(EcorePackage.eINSTANCE)».eINSTANCE;
			        «ENDIF»
			        the«id.EPackagePackage(epackage)».ecoreFactory = «id.EPackageFactoryImpl(EcorePackage.eINSTANCE)».eINSTANCE;
			
			        // Create package meta-data objects
			        the«id.EPackagePackage(epackage)».createPackageContents();
			
			        // Initialize created meta-data
			        the«id.EPackagePackage(epackage)».initializePackageContents();

			        return the«id.EPackagePackage(epackage)»;
		        }
		        
		        private isCreated:boolean = false;
		        
		        public createPackageContents = ():void =>
		        {
		            if (this.isCreated) return;
		            this.isCreated = true;
					«FOR EClass eclass:eclasses»
						this.«id.EClassEClass(eclass)» = this.createEClass(«id.EPackagePackageImpl(epackage)».«id.literal(eclass)»);
						«IF !eclass.interface»«id.EClassBase(eclass)».eStaticClass = this.«id.EClassEClass(eclass)»;«{tt.import_(epackage, id.EClassBase(eclass));}»«ENDIF»
						«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
							«IF feature instanceof EReference»
							this.createEReference(this.«id.EClassEClass(eclass)», «id.EPackagePackageImpl(epackage)».«id.literal(feature)»);
							«ELSEIF feature instanceof EAttribute»
							this.createEAttribute(this.«id.EClassEClass(eclass)», «id.EPackagePackageImpl(epackage)».«id.literal(feature)»);
							«ENDIF»
						«ENDFOR»
						«FOR EOperation operation:eclass.EOperations»
							this.createEOperation(this.«id.EClassEClass(eclass)», «id.EPackagePackageImpl(epackage)».«id.literal(operation)»);
						«ENDFOR»
					«ENDFOR»
					
					«FOR EEnum eenum:enums»
						«tt.import_(eenum)»
						this.«id.EEnumEEnum(eenum)» = this.createEEnum(«id.EPackagePackageImpl(epackage)».«id.literal(eenum)»);
					«ENDFOR»
					
					«FOR EDataType edatatype:edatatypes2»
						this.«id.EDataTypeEDataType(edatatype)» = this.createEDataType(«id.EPackagePackageImpl(epackage)».«id.literal(edatatype)»);
					«ENDFOR»
		        }
		        private isInitialized:boolean = false;
		        public initializePackageContents=():void =>
		        {
		            if (this.isInitialized) return;
		            this.isInitialized = true;
		            // Initialize package
		            this.name = «id.EPackagePackageImpl(epackage)».eNAME;
		            this.nsPrefix = «id.EPackagePackageImpl(epackage)».eNS_PREFIX;
		            this.nsURI = «id.EPackagePackageImpl(epackage)».eNS_URI;
		
					«FOR EClass e:eclasses»
						
						«FOR EClass super_:e.ESuperTypes»
							this.«id.EClassEClass(e)».eSuperTypes.add(this.«id.getEClass(super_)»());
						«ENDFOR»
					«ENDFOR»
					«tt.import_(EcorePackage.Literals.EOPERATION)»
					var op:EOperation = null;
					«FOR EClass e:eclasses»
						
						this.initEClass(
						this.«id.EClassEClass(e)»,
						«IF !e.interface»«id.EClassImpl(e)»«{tt.import_(e.EPackage, id.EClassImpl(e))}»«ELSE»null«ENDIF», 
						"«id.doSwitch(e)»", 
						«IF !e.abstract»!«ENDIF»EPackageImpl.IS_ABSTRACT, 
						«IF !e.interface»!«ENDIF»EPackageImpl.IS_INTERFACE, 
						EPackageImpl.IS_GENERATED_INSTANCE_CLASS);
						
						«FOR EAttribute a:e.EAttributes»
						this.initEAttribute_EClassifier(
							this.«id.getEAttribute(a)»(), 
							«IF Utils.isEcoreEPackage(a.EType.EPackage)»this.ecorePackage.«id.getEClassifier(a.EType)»()«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
							"«id.doSwitch(a)»", 
							«IF a.defaultValue===null»null«ELSE»"«a.defaultValue»"«ENDIF», 
							«a.lowerBound», 
							«a.upperBound», 
							«IF !e.interface»«id.EClassImpl(e)»«{tt.import_(e.EPackage, id.EClassImpl(e))}»«ELSE»null«ENDIF», 
							«IF !a.transient»!«ENDIF»EPackageImpl.IS_TRANSIENT, 
							«IF !a.volatile»!«ENDIF»EPackageImpl.IS_VOLATILE, 
							«IF !a.changeable»!«ENDIF»EPackageImpl.IS_CHANGEABLE, 
							«IF !a.unsettable»!«ENDIF»EPackageImpl.IS_UNSETTABLE, 
							«IF !a.isID»!«ENDIF»EPackageImpl.IS_ID, 
							«IF !a.unique»!«ENDIF»EPackageImpl.IS_UNIQUE, 
							«IF !a.derived»!«ENDIF»EPackageImpl.IS_DERIVED, 
							«IF !a.ordered»!«ENDIF»EPackageImpl.IS_ORDERED);
						«ENDFOR»
						
						«FOR EReference a:e.EReferences»
						this.initEReference(
							this.«id.getEReference(a)»(),
							«IF Utils.isEcoreEPackage(a.EType.EPackage)»this.ecorePackage.«id.getEClassifier(a.EType)»()«ELSEIF !a.EType.EPackage.nsURI.equals(epackage.nsURI)»«id.EPackagePackageImpl(a.EType.EPackage)».eINSTANCE.«id.getEClassifier(a.EType)»()«tt.import_(a.EType.EPackage, id.EPackagePackageImpl(a.EType.EPackage))»«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
							«IF a.EOpposite!==null»this.«id.getEReference(a.EOpposite)»()«ELSE»null«ENDIF», 
							"«id.doSwitch(a)»", 
							«IF a.defaultValue !== null»«a.defaultValue»«ELSE»null«ENDIF», 
							«a.lowerBound», 
							«a.upperBound», 
							«IF !e.interface»«id.EClassImpl(e)»«{tt.import_(e.EPackage, id.EClassImpl(e))}»«ELSE»null«ENDIF», 
							«IF !a.transient»!«ENDIF»EPackageImpl.IS_TRANSIENT, 
							«IF !a.volatile»!«ENDIF»EPackageImpl.IS_VOLATILE, 
							«IF !a.changeable»!«ENDIF»EPackageImpl.IS_CHANGEABLE, 
							«IF !a.containment»!«ENDIF»EPackageImpl.IS_COMPOSITE, 
							«IF !a.resolveProxies»!«ENDIF»EPackageImpl.IS_RESOLVE_PROXIES, 
							«IF !a.unsettable»!«ENDIF»EPackageImpl.IS_UNSETTABLE, 
							«IF !a.unique»!«ENDIF»EPackageImpl.IS_UNIQUE, 
							«IF !a.derived»!«ENDIF»EPackageImpl.IS_DERIVED, 
							«IF !a.ordered»!«ENDIF»EPackageImpl.IS_ORDERED);
						«ENDFOR»
						
						«FOR EOperation o:e.EOperations»
						//TODO add initEOperation to EPackageImpl
						op = this.initEOperation_3(this.«id.getEOperation(o)»(), «IF o.EType===null»null«ELSEIF Utils.isEcoreEPackage(o.EType.EPackage)»this.ecorePackage.«id.getEClassifier(o.EType)»()«ELSE»this.«id.getEClassifier(o.EType)»()«ENDIF», "«o.name»", «o.lowerBound», «o.upperBound», «IF !o.unique»!«ENDIF»EPackageImpl.IS_UNIQUE, «IF !o.ordered»!«ENDIF»EPackageImpl.IS_ORDERED);
						«FOR EParameter p:o.EParameters»
						//TODO add addEParameter to EPackageImpl
						//this.addEParameter_3(op, this.«id.getEClass(o.EContainingClass)»(), "«p.name»", «p.lowerBound», «p.upperBound», «IF !o.unique»!«ENDIF»EPackageImpl.IS_UNIQUE, «IF !o.ordered»!«ENDIF»EPackageImpl.IS_ORDERED);
						«ENDFOR»
						«ENDFOR»
						
					«ENDFOR»
					
					«FOR EDataType e:edatatypes»
						this.initEDataType(this.«id.EDataTypeEDataType(e)», null, "«e.name»", «IF !e.serializable»!«ENDIF»EPackageImpl.IS_SERIALIZABLE, !EPackageImpl.IS_GENERATED_INSTANCE_CLASS);
					«ENDFOR»
					«FOR EEnum e:enums»
						this.initEEnum(this.«id.EEnumEEnum(e)», null, "«e.name»");
					«ENDFOR»
					
		        }
				
				
				«FOR EClass eclass:eclasses»
					private «id.EClassEClass(eclass)»:EClass = null;
				«ENDFOR»
				
				
				«FOR EEnum eenum:enums»
					private «id.EEnumEEnum(eenum)»:EEnum = null;
				«ENDFOR»
				
				«FOR EDataType edatatype:edatatypes2»
					private «id.EDataTypeEDataType(edatatype)»:EDataType = null;
				«ENDFOR»
				
				
				«FOR EClassifier eclassifier: sortedEClasses»
					«metaobjectid.doSwitch(eclassifier)»
				«ENDFOR»
				
				/*Important: Call init() AFTER metaobject ids have been assigned.*/
				public static eINSTANCE:«id.EPackagePackage(epackage)» = «id.EPackagePackageImpl(epackage)».init();
				
				
				«FOR EClassifier eclassifier: sortedEClasses»
					«doSwitch(eclassifier)»
				«ENDFOR»
				
				/*
				public static Literals = {
					«FOR EObject e: allLiterals SEPARATOR ', '»
						«literals.doSwitch(e)»
					«ENDFOR»
				}
				*/
				

		 
		}
		'''
		

		
		return 
		'''
		«tt.printImports(epackage)»
		«body»
		'''
	}
	
	var literals = new TypeScriptVisitor(){
		override caseEClass(EClass eclass){
			//tt.import_(EcorePackage.eINSTANCE,"EClass");
			'''
				«id.literal(eclass)»: «id.EPackagePackageImpl(eclass.EPackage)».eINSTANCE.«id.getEClass(eclass)»()

			'''
		}
		
		override caseEEnum(EEnum enumeration){
			
			//tt.import_(EcorePackage.eINSTANCE,"EEnum");
			'''«id.literal(enumeration)»: «id.EPackagePackageImpl(enumeration.EPackage)».eINSTANCE.«id.getEEnum(enumeration)»()'''
		}
		
		override caseEDataType(EDataType edatatype){
			//tt.import_(EcorePackage.eINSTANCE,"EDataType");
			'''«id.literal(edatatype)»: «id.EPackagePackageImpl(edatatype.EPackage)».eINSTANCE.«id.getEDataType(edatatype)»()'''
			
		}
	
		override caseEReference(EReference ereference){
			//tt.import_(EcorePackage.eINSTANCE,"EReference");
			'''«id.literal(ereference)»: «id.EPackagePackageImpl(ereference.EContainingClass.EPackage)».eINSTANCE.«id.getEReference(ereference)»()'''
		}
		
		override caseEAttribute(EAttribute eattribute){
			//tt.import_(EcorePackage.eINSTANCE,"EAttribute");			
			'''«id.literal(eattribute)»: «id.EPackagePackageImpl(eattribute.EContainingClass.EPackage)».eINSTANCE.«id.getEAttribute(eattribute)»()'''
		}
		
		override caseEOperation(EOperation eoperation){
			
			'''«id.literal(eoperation)»: «id.EPackagePackageImpl(eoperation.EContainingClass.EPackage)».eINSTANCE.«id.getEOperation(eoperation)»()'''
		}	
	}
	
	
	var metaobjectid = new TypeScriptVisitor(){
		
		override caseEEnum(EEnum enumeration)'''
			public static «id.literal(enumeration)»:number = «enumeration.classifierID»;
			
		'''
		
		override caseEDataType(EDataType edatatype)'''
			public static «id.literal(edatatype)»:number = «edatatype.classifierID»;
			
		'''
		
		override caseEOperation(EOperation eoperation)'''
			public static «id.literal(eoperation)»:number = «eoperation.operationID»;
			
		'''
		
		override caseEClass(EClass eclassifier){

			var i = 0;
			var j =0;
			
			tt.import_(eclassifier.EPackage, id.EPackagePackageImpl(eclassifier.EPackage));

		'''
			public static «id.literal(eclassifier)»:number = «eclassifier.classifierID»;
			public static «id.EClassifier_FEATURE_COUNT(eclassifier)»:number = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EPackagePackageImpl(_super.EPackage)+"."+id.EClassifier_FEATURE_COUNT(_super)»«tt.import_(_super.EPackage, id.EPackagePackageImpl(_super.EPackage))»«ENDFOR»«eclassifier.EStructuralFeatures.size»;
			public static «id.EClassifier_OPERATION_COUNT(eclassifier)»:number = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EPackagePackageImpl(_super.EPackage) + "." +id.EClassifier_OPERATION_COUNT(_super)»«tt.import_(_super.EPackage, id.EPackagePackageImpl(_super.EPackage))»«ENDFOR»«eclassifier.EOperations.size»;
			
			«FOR EStructuralFeature feature:eclassifier.EAllStructuralFeatures»
				public static «id.literal(eclassifier,feature)»:number = «i++»;
			«ENDFOR»
			«FOR EOperation eoperation:eclassifier.EOperations»
				public static «id.literal(eoperation)»:number = «j++»; 
			«ENDFOR»
			
		'''
		
		}
		
	}
	
	
	override caseEDataType(EDataType edatatype){
		tt.import_(EcorePackage.eINSTANCE,"EDataType");
		'''public «id.getEDataType(edatatype)»=():EDataType=>{return this.«id.EDataTypeEDataType(edatatype)»;}'''
		
	}
	
	override caseEEnum(EEnum enumeration){
		tt.import_(EcorePackage.eINSTANCE,"EEnum");
		'''public «id.getEEnum(enumeration)»=():EEnum=>{return this.«id.EEnumEEnum(enumeration)»;}'''
	}
	
	override caseEOperation(EOperation operation){
		tt.import_(EcorePackage.eINSTANCE,"EOperation");
		'''public «id.getEOperation(operation)»=():EOperation=>{return this.«id.EOperationEOperation(operation)»;}'''
	}
	

	
	override caseEClass(EClass eclass){
		var featureIdx = 0;
		var operationIdx = 0;
		tt.import_(EcorePackage.eINSTANCE,"EClass");
		tt.import_(EcorePackage.eINSTANCE,"EAttribute");
		tt.import_(EcorePackage.eINSTANCE,"EReference");
		tt.import_(EcorePackage.eINSTANCE,"EOperation");
		
		'''
		public «id.getEClass(eclass)»=():EClass=>{return this.«id.EClassEClass(eclass)»;}
		
		«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
			«IF feature instanceof EAttribute»
			public «id.getEAttribute(feature as EAttribute)»=():EAttribute=>{return <EAttribute> this.«id.EClassEClass(feature.EContainingClass)».eStructuralFeatures.at(«featureIdx++»);}
			«ELSEIF feature instanceof EReference»
			public «id.getEReference(feature as EReference)»=():EReference=>{return <EReference> this.«id.EClassEClass(feature.EContainingClass)».eStructuralFeatures.at(«featureIdx++»);}
			«ENDIF»
		«ENDFOR»
		«FOR EOperation operation:eclass.EOperations»
		public «id.getEOperation(operation)»=():EOperation=>{return <EOperation> this.«id.EClassEClass(operation.EContainingClass)».eOperations.at(«operationIdx++»);}
		«ENDFOR»
		'''
	}
	
}