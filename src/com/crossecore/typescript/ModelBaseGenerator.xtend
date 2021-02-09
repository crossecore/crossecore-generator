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

import com.crossecore.DependencyManager
import com.crossecore.EcoreVisitor
import com.crossecore.Utils
import com.crossecore.csharp.CSharpOCLVisitor
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.List
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.BasicEMap
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.ETypeParameter
import org.eclipse.emf.ecore.EcorePackage

class ModelBaseGenerator extends EcoreVisitor{ 
	

	TypeScriptIdentifier id = new TypeScriptIdentifier();
	CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	
	TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	//private ImportManager imports = new ImportManager(t);
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
		
	
	override caseEPackage (EPackage epackage){
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		
		for(EClass eclass : sortedEClasses){
			tt.clearImports;
			tt.import_(EcorePackage.eINSTANCE, "InternalEObject");
			tt.import_(EcorePackage.eINSTANCE, "EClass");
			tt.import_(EcorePackage.eINSTANCE, "NotificationChain");
			tt.import_(EcorePackage.eINSTANCE, "ENotificationImpl");
			tt.import_(EcorePackage.eINSTANCE, "NotificationImpl");
			tt.import_(EcorePackage.eINSTANCE, "BasicEObjectImpl");
			tt.import_(epackage, id.EPackagePackageLiterals(epackage));
			//imports.add(epackage, id.EPackagePackageLiterals(epackage));
			var body = 	
			'''
			«doSwitch(eclass)»
			'''
			
			var contents =
			'''
			«tt.printImports(epackage)»
			«body»
			'''
			
			write(eclass, contents);
		}
	
		return "";
	}
	
	override write(){
		doSwitch(epackage);
	}
		

	
	override caseEClass(EClass e){

		var eAnnotation = e.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");
		var invariants = if(eAnnotation!==null) eAnnotation.getDetails() else new BasicEMap();
		

		if(!e.interface){
			
			var allAttributes = new BasicEList<EAttribute>();
			var allReferences = new BasicEList<EReference>();
			var allEStructuralFeatures = new BasicEList<EStructuralFeature>();
			var allOperations = new HashSet<EOperation>();
			var referencesSingle = new HashSet<EReference>();
			var referencesWithOpposite = new HashSet<EReference>();
			var referencesWithOppositeNonMany = new HashSet<EReference>();
			
			allReferences = new BasicEList<EReference>(e.EAllReferences);
			if(e.ESuperTypes.length>0){
				
				var minus = e.ESuperTypes.get(0).EAllReferences;
				allReferences.removeAll(minus); 
			}
			
			allAttributes = new BasicEList<EAttribute>(e.EAllAttributes);
			if(e.ESuperTypes.length>0){
				
				var minus = e.ESuperTypes.get(0).EAllAttributes;
				allAttributes.removeAll(minus); 
			}

			
			var nonDirectSupertypes = new BasicEList<EClass>();
			
			if(e.ESuperTypes.size>1){
				

				nonDirectSupertypes.addAll(e.ESuperTypes.subList(1, e.ESuperTypes.size).filter[c | !c.abstract && !c.interface])
			}
			
			allEStructuralFeatures.addAll(allAttributes);
			allEStructuralFeatures.addAll(allReferences);
			
			
			for(EReference ref:allReferences){
				
				if(!ref.many && ref.changeable){
					referencesSingle.add(ref);
				}
				
				if(ref.EOpposite!==null){
					referencesWithOpposite.add(ref);
					
					if(!ref.many){
						referencesWithOppositeNonMany.add(ref);	
					}
				}
			}
			
			
			if(!e.ESuperTypes.empty && !e.ESuperTypes.get(0).interface){
				

				
				//allAttributes.addAll(e.EAttributes);
				//allReferences.addAll(e.EReferences);
				
				allOperations = new HashSet<EOperation>(e.EAllOperations);
				allOperations.removeAll(Utils.getInheritedOperations(e));
			}
			else{
				//EClass inherits from EObject, but do want to exclude the EOperations from EObject, because we want to use the implementation from BasicEObjectImpl
				//allAttributes = Utils.nonEObjectEAttributes(e.EAllAttributes);
				//allReferences = Utils.nonEObjectEReferences(e.EAllReferences);
				allOperations = Utils.nonEObjectEOperations(e.EAllOperations);
	
			}

			var overloading = new HashMap<String, List<EOperation>>();
			
			for(EOperation op : allOperations){
				
				var overloaded = overloading.get(op.name);
				if(overloaded===null){
					overloaded = new ArrayList<EOperation>();
				}
				overloaded.add(op);
				overloading.put(op.name, overloaded);
						
			}
			
			return
			'''
			
				export class «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
				extends «IF e.ESuperTypes.isEmpty || e.ESuperTypes.get(0).interface»BasicEObjectImpl«tt.import_(EcorePackage.eINSTANCE, "BasicEObjectImpl")»«ELSE»«id.EClassImpl(e.ESuperTypes.get(0))»«tt.import_(e.EPackage, id.EClassImpl(e.ESuperTypes.get(0)))»«ENDIF»
				implements «id.doSwitch(e)»«tt.import_(e.EPackage, id.doSwitch(e))»
				{
					«FOR EAttribute feature:allAttributes»«doSwitch(feature)»«ENDFOR»
					«FOR EReference feature:allReferences»«doSwitch(feature)»«ENDFOR»
	
					«FOR String name : overloading.keySet»
						«IF overloading.get(name).size > 1»
							«operationSplit(overloading.get(name))»
						«ENDIF»
						
						«FOR EOperation eoperation : overloading.get(name)»
							«IF overloading.get(name).size > 1»
								«caseEOperation(eoperation, true)»
							«ELSE»
								«caseEOperation(eoperation)»
							«ENDIF»
						«ENDFOR»
					«ENDFOR»
				
					public static eStaticClass:EClass;
					
					protected eStaticClass():EClass{
						
						return «id.EClassBase(e)».eStaticClass;
					}
				
					«IF !referencesWithOpposite.empty»
					public eInverseAdd(otherEnd:InternalEObject, featureID:number, msgs:NotificationChain): NotificationChain{
						switch (featureID) {
							«FOR EReference ref:referencesWithOpposite»
								case «id.literalRef(e, ref)»:
									«IF !ref.many»
										«IF ref.EOpposite.containment»
										if (this.eInternalContainer() != null) {
											msgs = this.eBasicRemoveFromContainer(msgs);
										}
										«ELSE»
										if (this.«ref.name» != null){
											msgs = this.«ref.name».eInverseRemove(this, «id.literalRef(ref)», /*«id.doSwitch(ref.EType)»*/ null, msgs);
										}
										«ENDIF»
										return this.«id.basicSetEReference(ref)»(otherEnd as «id.doSwitch(ref.EType)», msgs);
									«ELSE»								
										return this.«id.doSwitch(ref)».basicAdd(otherEnd as «id.doSwitch(ref.EType)», msgs);
									«ENDIF»
							«ENDFOR»
						}
						return super.eInverseAdd(otherEnd, featureID, msgs);
					}
					
					public eInverseRemove(otherEnd:InternalEObject, featureID:number, msgs:NotificationChain):NotificationChain{
						switch (featureID) {
							«FOR EReference ref:referencesWithOpposite»
								case «id.literalRef(e, ref)»:
									«IF !ref.many»
										return this.«id.basicSetEReference(ref)»(null, msgs);
									«ELSE»
										return this.«id.doSwitch(ref)».basicRemove(otherEnd as «id.doSwitch(ref.EType)», msgs);
									«ENDIF»
							«ENDFOR»
						}
						return super.eInverseRemove(otherEnd, featureID, msgs);
					}
					
					«ENDIF»
				
					«IF !referencesSingle.empty»
						«FOR EReference ref:referencesSingle»
							«IF ref.EOpposite !== null && ref.EOpposite.containment»
							public «id.basicSetEReference(ref)»(newobj:«id.doSwitch(ref.EType)», msgs:NotificationChain):NotificationChain {
									msgs = this.eBasicSetContainer(newobj, «id.literalRef(ref)», msgs);
									return msgs;
							}
							«ELSE»
							public «id.basicSetEReference(ref)»(newobj:«id.doSwitch(ref.EType)», msgs:NotificationChain):NotificationChain {
								let oldobj = this.«ref.name»;
								this.«ref.name» = newobj;
								if (this.eNotificationRequired()) {
									let notification = new ENotificationImpl(this, NotificationImpl.SET, «id.literalRef(ref)», oldobj, newobj);
									if (msgs == null){
										msgs = notification;
									}
									else{
										msgs.add(notification);
									}
								}
								return msgs;
							}
							«ENDIF»
						«ENDFOR»
						
					«ENDIF»
				
					public eGet_number_boolean_boolean(featureID:number, resolve:boolean, coreType:boolean):any{
						«IF !e.EAllStructuralFeatures.empty»
						switch (featureID) {
							«FOR EStructuralFeature feature:e.EAllStructuralFeatures»
							«tt.import_(feature.EContainingClass.EPackage, id.EPackagePackageLiterals(feature.EContainingClass.EPackage))»
							case «id.literalRef(e, feature)»:
								return this.«id.doSwitch(feature)»;
							«ENDFOR»
						}
						«ENDIF»
						//return this.«id.super_eGetRef(e)»(featureID, resolve, coreType);
						return super.eGet(featureID, resolve, coreType);
					}
					
					public eSet_number_any(featureID:number, newValue:any):void {
						switch (featureID) {
							«FOR EStructuralFeature feature:allEStructuralFeatures»
								«IF !feature.derived && feature.changeable»
								case «id.literalRef(e, feature)»:
									«IF feature instanceof EReference && (feature as EReference)?.containment && feature?.EType?.instanceClassName?.equals("java.util.Map$Entry")»
									(<EcoreEMap<«tt.translateType((feature.EType as EClass).getEStructuralFeature("key").EGenericType)», «tt.translateType((feature.EType as EClass).getEStructuralFeature("value").EGenericType)»>>this.«id.doSwitch(feature)»).set(newValue);
									return;
									«ELSEIF feature.many»
										this.«id.doSwitch(feature)».clear();
										«tt.import_(EcorePackage.eINSTANCE, "AbstractCollection")»
										this.«id.doSwitch(feature)».addAll(newValue);
										return;
									«ELSE»
										this.«id.doSwitch(feature)» = <«tt.translateType(feature.EGenericType)»> newValue;
										return;
									«ENDIF»
								«ENDIF»
							«ENDFOR»
						}
						super.eSet_number_any(featureID, newValue);
					}
	
					«IF nonDirectSupertypes.size()>0»
					public eBaseStructuralFeatureID(derivedFeatureID:number, baseClass:Function):number {
						«FOR parent:nonDirectSupertypes»
						«IF !parent.interface»
						«tt.import_(e.EPackage, id.EClassImpl(parent))»
						if (baseClass === «id.EClassImpl(parent)») {
							switch (derivedFeatureID) {
								«FOR feature:parent.EStructuralFeatures»
								case «id.EPackagePackageLiterals(e.EPackage)».«id.literal(e, feature)»: return «id.EPackagePackageLiterals(e.EPackage)».«id.literal(parent, feature)»;
								«ENDFOR»
								default: return -1;
							}
						}
						«ENDIF»
						«ENDFOR»
						return super.eBaseStructuralFeatureID(derivedFeatureID, baseClass);
					}
					
					public eDerivedStructuralFeatureID_number_Function(baseFeatureID:number, baseClass:Function):number {
						«FOR parent:nonDirectSupertypes»
						«IF !parent.interface»
						«tt.import_(e.EPackage, id.EClassImpl(parent))»
						if (baseClass === «id.EClassImpl(parent)») {
							switch (baseFeatureID) {
								«FOR feature:parent.EStructuralFeatures»
								case «id.EPackagePackageLiterals(e.EPackage)».«id.literal(parent, feature)»: return «id.EPackagePackageLiterals(e.EPackage)».«id.literal(e, feature)»;
								«ENDFOR»
								default: return -1;
							}
						}
						«ENDIF»
						«ENDFOR»
						return super.eDerivedStructuralFeatureID_number_Function(baseFeatureID, baseClass);
					}
					«ENDIF»	
					
					«FOR String invariant:invariants.keySet»
					«tt.import_(EcorePackage.eINSTANCE, "DiagnosticChain")»
					//TODO context is map<object, object>
					public «invariant»(diagnostics:DiagnosticChain, context:any):boolean
					{
						/*
						«invariants.get(invariant)»;
						*/
						return true;«/*TODO OCL Translator*/»
					}
		        	«ENDFOR»
				}
				
			'''
			
		}
	
	}
	
	private def operationSplit(List<EOperation> operations){
		//TODO consider return types
		
		//TODO consider the case that a non-primitive EParameter is an EDataType from Ecore Package

		var sortedOperations = operations.sortBy[o|o.EParameters.size].reverse
		var i = 0;				
		'''
			public «sortedOperations.get(0).name»(...args:Array<any>):any {
				«FOR EOperation op:sortedOperations»
					«IF op.EParameters.size>0»
					if(
						«{i = 0; ""}»
						«FOR EParameter param:op.EParameters SEPARATOR " && "»
							«IF #["boolean", "number", "string"].contains(tt.translateType(param.EType))»
							typeof args[«i++»] === "«tt.translateType(param.EType)»"
							«ELSE»
							args[«i++»] instanceof «tt.translateType(param.EType)»
							«ENDIF»
						«ENDFOR»
					)
					«ELSE»
					else
					«ENDIF»
					{
						return this.«id.caseOverloadedEOperation(op)»(«var pindex2=0»«FOR EParameter param: op.EParameters SEPARATOR ", "»args[«pindex2++»]«ENDFOR»);
					}
				«ENDFOR»
			};
		'''
		
	}
	
	
	override caseEAttribute(EAttribute eattribute){
	
		var listType = tt.listType(eattribute.unique, eattribute.ordered);
		tt.import_(EcorePackage.eINSTANCE, listType);
		
		
		//TODO swap out to Utils
		var deriveExpr="";
		var oclDeriveExpr = "";
		var isOcl = false;
		if(eattribute.derived){
			
			var eAnnotation = eattribute.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

			if(eAnnotation !== null){
				
				oclDeriveExpr = eAnnotation.getDetails().get("derivation");
				if(oclDeriveExpr !== null){
					deriveExpr = ocl2csharp.translate(oclDeriveExpr, eattribute.EContainingClass);
					isOcl= true;
				}
				
							
			
			}
		}
		
		//TODO is there a set method for multi-valued EReferences?
		//TODO case derived && !ocl
		var es5plus = 
		'''
		«IF eattribute.many»
			«IF !eattribute.derived»
			private «id.privateEStructuralFeature(eattribute)»:«listType»<«tt.translateType(eattribute.EGenericType)»> = new «listType»<«tt.translateType(eattribute.EGenericType)»>();
			«ENDIF»
			get «eattribute.name»():«listType»<«tt.translateType(eattribute.EGenericType)»>{
				«IF !eattribute.derived»
				if(this.«id.privateEStructuralFeature(eattribute)»===null){
					this.«id.privateEStructuralFeature(eattribute)» = new «listType»<«tt.translateType(eattribute.EGenericType)»>();
						
				}
				return this.«id.privateEStructuralFeature(eattribute)»;
				«ELSE»
				/*OCL: «oclDeriveExpr»*/
				return «deriveExpr»;
				«ENDIF»
			}
			«IF !eattribute.derived && eattribute.changeable»
			set «eattribute.name»(value:«listType»<«tt.translateType(eattribute.EGenericType)»>){
				this.«id.privateEStructuralFeature(eattribute)» = value; 
			}
			«ENDIF»
		«ELSE»
			«IF !eattribute.derived»
			private «id.privateEStructuralFeature(eattribute)»:«tt.translateType(eattribute.EGenericType)» = «tt.defaultValue(eattribute.EType)»;
			«ENDIF»
			get «eattribute.name»():«tt.translateType(eattribute.EGenericType)»{
				«IF !eattribute.derived»
				return this.«id.privateEStructuralFeature(eattribute)»;
				«ELSEIF eattribute.derived && isOcl»
				/*OCL: «oclDeriveExpr»*/
				return «deriveExpr»;
				«ELSE»
				//TODO implement derivation
				return null;
				«ENDIF»	
			}
			«IF !eattribute.derived && eattribute.changeable»
			set «eattribute.name»(value:«tt.translateType(eattribute.EGenericType)»){
				this.«id.privateEStructuralFeature(eattribute)» = value; 
			}
			«ENDIF»
		«ENDIF»
		'''
		
		return es5plus;
	
	}
	
	
	override caseEReference(EReference ereference){
		var listType = tt.listType(ereference.unique, ereference.ordered);
	
		//TODO swap out to Utils
		var deriveExpr="";
		var oclDeriveExpr = "";
		var isOcl = false;
		if(ereference.derived){
			
			var eAnnotation = ereference.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

			if(eAnnotation!==null){
				
				oclDeriveExpr = eAnnotation.getDetails().get("derivation");
				if(oclDeriveExpr!==null){
					deriveExpr = ocl2csharp.translate(oclDeriveExpr, ereference.EContainingClass);
					isOcl= true;
				}
				
			}
		}
	
		var ec5plus= 
		'''
			«IF ereference.many»
				«IF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
				«{tt.import_(EcorePackage.eINSTANCE, "EMap");}»
				«{tt.import_(EcorePackage.eINSTANCE, "EcoreEMap");}»
				private «id.privateEStructuralFeature(ereference)»:EMap<«tt.translateType((ereference.EType as EClass).getEStructuralFeature("key").EGenericType)», «tt.translateType((ereference.EType as EClass).getEStructuralFeature("value").EGenericType)»>;
				«ELSEIF !ereference.derived»
				private «id.privateEStructuralFeature(ereference)»:«listType»<«ereference.EType.name»> = null;
				«ENDIF»
				
				«IF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
				get «id.doSwitch(ereference)»():EMap<«tt.translateType((ereference.EType as EClass).getEStructuralFeature("key").EGenericType)», «tt.translateType((ereference.EType as EClass).getEStructuralFeature("value").EGenericType)»>{
				«ELSE»
				get «id.doSwitch(ereference)»():«listType»<«tt.translateType(ereference.EGenericType)»>{
				«ENDIF»
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return null;
					«ELSEIF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
					if (this.«id.privateEStructuralFeature(ereference)» === null)
					{
						«{tt.import_(ereference.EType.EPackage, id.EClassBase(ereference.EType as EClass))}»
						this.«id.privateEStructuralFeature(ereference)» = new EcoreEMap<«tt.translateType((ereference.EType as EClass).getEStructuralFeature("key").EGenericType)», «tt.translateType((ereference.EType as EClass).getEStructuralFeature("value").EGenericType)»>(«id.EClassBase(ereference.EType as EClass)».eStaticClass, «id.EClassBase(ereference.EType as EClass)», this, «id.literalRef(ereference)»);
					}
					return this.«id.privateEStructuralFeature(ereference)»;
					«ELSE»
					if(this.«id.privateEStructuralFeature(ereference)»===null){
						this.«id.privateEStructuralFeature(ereference)» = new «listType»<«tt.translateType(ereference.EGenericType)»>(this, «id.literalRef(ereference)», «IF ereference.EOpposite!==null»«id.literalRef(ereference.EOpposite)»«ELSE»BasicEObjectImpl.EOPPOSITE_FEATURE_BASE - «id.literalRef(ereference)»«ENDIF»);
							
					}
					return this.«id.privateEStructuralFeature(ereference)»;
					«ENDIF»	
					
				}


			«ELSE»
				«IF !(ereference.derived || (ereference.EOpposite!==null && ereference.EOpposite.containment))»
				private «id.privateEStructuralFeature(ereference)»:«tt.translateType(ereference.EGenericType)» = null;
				«ENDIF»
				get «ereference.name»():«tt.translateType(ereference.EGenericType)»{
				
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return null;
					«ELSEIF ereference.EOpposite!== null && ereference.EOpposite.containment»
					if (this.eContainerFeatureID() != «id.literalRef(ereference)») return null;
					return this.eInternalContainer() as «id.doSwitch(ereference.EType)»;
					«ELSE»
					return this.«id.privateEStructuralFeature(ereference)»;
					«ENDIF» 
				}
				«IF !ereference.derived && ereference.changeable»
				set «ereference.name»(value:«tt.translateType(ereference.EGenericType)») {
					«IF !ereference.containment && ereference.EOpposite===null»
					let oldvalue = this.«id.privateEStructuralFeature(ereference)»;
					this.«id.privateEStructuralFeature(ereference)» = value;
					if (this.eNotificationRequired()){
						this.eNotify(new ENotificationImpl(this, NotificationImpl.SET,«id.literalRef(ereference)» , oldvalue, value));
					}
					«ELSE»
					«var featureId = if(ereference.EOpposite!==null) id.literalRef(ereference.EOpposite) else "BasicEObjectImpl.EOPPOSITE_FEATURE_BASE - " + id.literalRef(ereference) »
					«var featureClass = if(ereference.EOpposite!==null) '''«id.doSwitch(ereference.EOpposite.EType)»''' else "null"»
					«var getcurrentvalue = if(ereference.EOpposite!==null && ereference.EOpposite.containment) '''this.eInternalContainer() as «id.doSwitch(ereference.EType)»''' else "this."+ereference.name»
					if (value != «getcurrentvalue») {
						let msgs:NotificationChain = null;
						if («getcurrentvalue» != null){
							msgs = («getcurrentvalue»).eInverseRemove(this, «featureId», /*«featureClass»*/ null , msgs);
						}
						if (value != null){
							msgs = value.eInverseAdd(this, «featureId», /*«featureClass»*/ null, msgs);
						}
						msgs = this.«id.basicSetEReference(ereference)»(value, msgs);
						if (msgs != null) {
							msgs.dispatch();
						}
					}
					else if (this.eNotificationRequired()){
						this.eNotify(new ENotificationImpl(this, NotificationImpl.SET,«id.literalRef(ereference)» , value, value));
					}
					«ENDIF»
				}
				«ENDIF»
			«ENDIF»
		'''
		
		return ec5plus;
	
	
	}
	

	override caseEOperation(EOperation eoperation){
		return caseEOperation(eoperation, false);
	
	}

	
	def caseEOperation(EOperation eoperation, boolean overloaded){
		
		var body = 
		'''
		/*TODO implement function*/ 
		return null;
		''';
		
		var eAnnotation = eoperation.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

		if(eAnnotation!==null){
			
			var body_ = eAnnotation.getDetails().get("body");
			
			if(body_!==null){
				body = '''return «body_»;''';
			}
		}
		
		var visibility = "public";//if (overloaded) "private" else "public";
		var name = if(overloaded) id.caseOverloadedEOperation(eoperation) else id.doSwitch(eoperation);
		
		'''
			«visibility» «name»(«FOR EParameter eparameter:eoperation.EParameters SEPARATOR ', '»«id.doSwitch(eparameter)»:«tt.translateType(eparameter.EGenericType)»«ENDFOR»):«IF eoperation.EType!==null» «tt.translateType(eoperation.EGenericType)» «ELSE» void «ENDIF»{
				«body»
			};
		'''
	
	}
	

	
}