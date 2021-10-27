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

import com.crossecore.DependencyManager
import com.crossecore.Utils
import java.util.HashSet
import java.util.List
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.ETypeParameter
import com.crossecore.TypeTranslator
import org.eclipse.emf.common.util.BasicEMap
import org.eclipse.emf.common.util.BasicEList

class ModelBaseGenerator extends CSharpVisitor{
	
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
	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses_ = DependencyManager.sortEClasses(epackage);
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		//var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		//eclassifiers.removeAll(sortedEClasses);
		
		for(EClass eclass : sortedEClasses){
			
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
				«doSwitch(eclass)»
			}
			'''
			
			write(eclass, contents);
		}
	
		return "";
	
	}
	
	override write(){
		doSwitch(epackage);
	}
	
	override caseEClass(EClass e) 
	{
		
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
				
				nonDirectSupertypes.addAll(e.ESuperTypes.subList(1, e.ESuperTypes.size).filter[c | !c.abstract && !c.interface]);
			}
			
			allEStructuralFeatures.addAll(allAttributes);
			allEStructuralFeatures.addAll(allReferences);
			
			
			for(EReference ref:allReferences){
				
				if(!ref.many && !ref.derived){
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
	
			'''
			public class «id.EClassBase(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			:«IF e.ESuperTypes.isEmpty || e.ESuperTypes.get(0).interface»BasicEObjectImpl«ELSE»«IF !e.EPackage.equals(e.ESuperTypes.get(0).EPackage)»«id.doSwitch(e.ESuperTypes.get(0).EPackage)».«ENDIF»«id.EClassImpl(e.ESuperTypes.get(0))»«ENDIF», «id.doSwitch(e)»
			{
				«FOR EAttribute feature:allAttributes»«doSwitch(feature)»«ENDFOR»
				«FOR EReference feature:allReferences»«caseEReference(e, feature)»«ENDFOR»
				«FOR EOperation operation:allOperations»«doSwitch(operation)»«ENDFOR»
				
				protected override EClass eStaticClass() {
					return «id.literalRef(e)»;
				}
				
				«IF !referencesWithOpposite.empty»
				public override NotificationChain eInverseAdd(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
					switch (featureID) {
						«FOR EReference ref:referencesWithOpposite»
							case «id.literalRef(e, ref)»:
								«IF !ref.many»
									«IF ref.EOpposite.containment»
									if (eInternalContainer() != null) {
										msgs = eBasicRemoveFromContainer(msgs);
									}
									«ELSE»
									if («id.privateEStructuralFeature(ref)» != null){
										msgs = ((InternalEObject)«id.privateEStructuralFeature(ref)»).eInverseRemove(this, «id.literalRef(e, ref)», typeof(«id.doSwitch(ref.EType)»), msgs);
									}
									«ENDIF»
									return «id.basicSetEReference(ref)»((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ELSE»								
									return «id.doSwitch(ref)».basicAdd((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ENDIF»
						«ENDFOR»
					}
					return base.eInverseAdd(otherEnd, featureID, msgs);
				}
				
				public override NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
					switch (featureID) {
						«FOR EReference ref:referencesWithOpposite»
							case «id.literalRef(e, ref)»:
								«IF !ref.many»
								return «id.basicSetEReference(ref)»(null, msgs);
								«ELSE»
								return «id.doSwitch(ref)».basicRemove((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ENDIF»
						«ENDFOR»
					}
					return base.eInverseRemove(otherEnd, featureID, msgs);
				}
				«ENDIF»
				
				«IF !referencesSingle.empty»
					«FOR EReference ref:referencesSingle»
						«IF ref.EOpposite !== null && ref.EOpposite.containment»
						public NotificationChain «id.basicSetEReference(ref)»(«id.doSwitch(ref.EContainingClass.EPackage)».«id.doSwitch(ref.EType)» newobj, NotificationChain msgs) {
								msgs = eBasicSetContainer((InternalEObject)newobj, «id.literalRef(e, ref)», msgs);
								return msgs;
						}
						«ELSE»
						public NotificationChain «id.basicSetEReference(ref)»(«id.doSwitch(ref.EContainingClass.EPackage)».«id.doSwitch(ref.EType)» newobj, NotificationChain msgs) {
							var oldobj = «id.privateEStructuralFeature(ref)»;
							«id.privateEStructuralFeature(ref)» = newobj;
							if (eNotificationRequired()) {
								var notification = new ENotificationImpl(this, NotificationImpl.SET, «id.literalRef(e, ref)», oldobj, newobj);
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
				
				
				«IF allEStructuralFeatures.size>0»
				public override object eGet(int featureID, bool resolve, bool coreType) {
					switch (featureID) {
						«FOR EStructuralFeature feature:allEStructuralFeatures»
						case «id.literalRef(e, feature)»:
							«IF feature instanceof EReference && (feature as EReference)?.containment && feature.EType?.instanceClassName?.equals("java.util.Map$Entry")»
							if (coreType) return «id.doSwitch(feature)»;
							else return «id.doSwitch(feature)».map();							
							«ELSE»
							return «id.doSwitch(feature)»;
							«ENDIF»
						«ENDFOR»
					}
					return base.eGet(featureID, resolve, coreType);
				}
				
				
				public override void eSet(int featureID, object newValue) {
					switch (featureID) {
						«FOR EStructuralFeature feature:allEStructuralFeatures»
							«IF !feature.derived && feature.changeable»
							case «id.literalRef(e, feature)»:
								«IF feature instanceof EReference && (feature as EReference)?.containment && feature?.EType?.instanceClassName?.equals("java.util.Map$Entry")»
								((EcoreEMap<«t.translateType((feature.EType as EClass).getEStructuralFeature("key").EType)», «t.translateType((feature.EType as EClass).getEStructuralFeature("value").EType)»>)«id.doSwitch(feature)»).set(newValue);
								return;
								«ELSEIF feature.many»
									«id.doSwitch(feature)».Clear();
									«id.doSwitch(feature)».AddRange(((List<EObject>)newValue)?.Cast<«t.translateType(feature.EGenericType)»>());
									return;
								«ELSE»
									«id.doSwitch(feature)» = («t.translateType(feature.EGenericType)») newValue;
									return;
								«ENDIF»
							«ENDIF»
						«ENDFOR»
					}
					base.eSet(featureID, newValue);
				}
				«ENDIF»
				
				/*
				public override bool eIsSet(int featureID) {
					switch (featureID) {
						«FOR EStructuralFeature feature:allEStructuralFeatures»
							case «id.literalRef(e, feature)»:
								«IF feature.unsettable»
								return «id.isSetEStructuralFeature(feature)»(); //unsettable -> isSet
								«ELSEIF feature instanceof EReference && !(feature as EReference).containment && !feature.many»
								return «id.getEStructuralFeature(feature)»() != null; //single, volatile
								«ELSEIF feature instanceof EReference && !(feature as EReference).containment && feature.many»
								return «id.getEStructuralFeature(feature)»().isEmpty(); //many, volatile
								«ELSEIF feature instanceof EReference && !feature.many && feature.volatile»
								return «id.basicSetEReference(feature as EReference)»() != null; //single, volatile -> basicSet
								«ELSEIF feature instanceof EReference && (feature as EReference).containment && feature.many»
								return «id.privateEStructuralFeature(feature)» != null && !«id.privateEStructuralFeature(feature)».isEmpty();
								«ELSEIF feature instanceof EReference && (feature as EReference).containment && !feature.many»
								return «id.privateEStructuralFeature(feature)» != null; //single != null;
								«ELSEIF feature instanceof EAttribute && #{"EInt","EBoolean", "EByte", "EChar", "EDouble", "EFloat","ELong","EShort"}.contains(feature.EType.name)»
								return «id.privateEStructuralFeature(feature)» != «id.edefault(feature as EAttribute)»;
								«ELSE»
								return «id.edefault(feature as EAttribute)» == null ? «id.privateEStructuralFeature(feature)» != null : !«id.edefault(feature as EAttribute)».equals(«id.privateEStructuralFeature(feature)»);
								«ENDIF»	
						«ENDFOR»
					}
					return base.eIsSet(featureID);
				}
				*/
				
				«IF nonDirectSupertypes.size()>0»
				public override int eBaseStructuralFeatureID(int derivedFeatureID, System.Type baseClass) {
					«FOR parent:nonDirectSupertypes»
					if (baseClass == typeof(«id.doSwitch(parent.EPackage)».«id.doSwitch(parent)»)) {
						switch (derivedFeatureID) {
							«FOR feature:parent.EStructuralFeatures»
							case «id.EPackagePackageImpl(e.EPackage)».«id.literal(e, feature)»: return «IF !parent.EPackage.nsURI.equals(e.EPackage.nsURI)»«id.doSwitch(parent.EPackage)».«ENDIF»«id.EPackagePackageImpl(parent.EPackage)».«id.literal(parent, feature)»;
							«ENDFOR»
							default: return -1;
						}
					}
					«ENDFOR»
					return base.eBaseStructuralFeatureID(derivedFeatureID, baseClass);
				}
				
							
				public override int eDerivedStructuralFeatureID(int baseFeatureID, System.Type baseClass) {
					«FOR parent:nonDirectSupertypes»
					if (baseClass == typeof(«id.doSwitch(parent.EPackage)».«id.doSwitch(parent)»)) {
						switch (baseFeatureID) {
							«FOR feature:parent.EStructuralFeatures»
							case «IF !parent.EPackage.nsURI.equals(e.EPackage.nsURI)»«id.doSwitch(parent.EPackage)».«ENDIF»«id.EPackagePackageImpl(parent.EPackage)».«id.literal(parent, feature)»: return «id.EPackagePackageImpl(e.EPackage)».«id.literal(e, feature)»;
							«ENDFOR»
							default: return -1;
						}
					}
					«ENDFOR»
					return base.eDerivedStructuralFeatureID(baseFeatureID, baseClass);
				}
				«ENDIF»					
				
				«FOR String invariant:invariants.keySet»
				public boolean «invariant»(org.eclipse.emf.common.util.DiagnosticChain diagnostics, java.util.Map<Object, Object> context)
				{
					return null;
				}
	        	«ENDFOR»
				
			}
			'''
		
		}
	}
	

	override caseEAttribute(EAttribute eattribute){
		var listType = t.listType(eattribute.unique, eattribute.ordered);
		
		//TODO swap out to Utils
		var deriveExpr="";
		var oclDeriveExpr = "";
		var isOcl = false;
		if(eattribute.derived){
			
			var eAnnotation = eattribute.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

			if(eAnnotation!==null){
				
				oclDeriveExpr = eAnnotation.getDetails().get("derivation");
				if(oclDeriveExpr!==null){
					deriveExpr = "null";
					//deriveExpr = "null"; //FIXME enable OCL to C# translation
					isOcl= true;
				}		
			}
		}
	
		//TODO Do not add a field when it is derived or containment feature	
		'''
		«IF eattribute.many»
			«IF !eattribute.derived»
			private «listType»<«t.translateType(eattribute.EGenericType)»> «id.privateEStructuralFeature(eattribute)»;
			«ENDIF»
			
			public virtual «listType»<«t.translateType(eattribute.EGenericType)»> «id.doSwitch(eattribute)»
			{
				get {
					«IF !eattribute.derived»
					if(«id.privateEStructuralFeature(eattribute)»==null){
						«id.privateEStructuralFeature(eattribute)» = new «listType»<«t.translateType(eattribute.EGenericType)»>();
					}
					return «id.privateEStructuralFeature(eattribute)»;
					«ELSE»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ENDIF»					
				}
				«IF !eattribute.derived && eattribute.changeable»
				set { «id.privateEStructuralFeature(eattribute)» = value; }
				«ENDIF»
			}
		«ELSE»
			«IF !eattribute.derived»
			private «t.translateType(eattribute.EGenericType)» «id.privateEStructuralFeature(eattribute)» = «t.defaultValue(eattribute.EType)»;
			«ENDIF»
			public virtual «t.translateType(eattribute.EGenericType)» «id.doSwitch(eattribute)»
			{
			get { 
				«IF !eattribute.derived»
				return «id.privateEStructuralFeature(eattribute)»;
				«ELSEIF eattribute.derived && isOcl»
				/*«oclDeriveExpr»*/
				return «deriveExpr»;
				«ELSE»
				//TODO implement derivation
				return default(«t.translateType(eattribute.EGenericType)»);
				«ENDIF»	
			}
			«IF !eattribute.derived && eattribute.changeable»
			set { «id.privateEStructuralFeature(eattribute)» = value; }
			«ENDIF»
			}
		«ENDIF»
		'''
	
	}
	
	override caseEParameter(EParameter parameter)'''
		«t.translateType(parameter.EGenericType)» «id.doSwitch(parameter)»
	'''
	
	def caseEReference(EClass e, EReference ereference){
		var listType = t.listType(ereference.unique, ereference.ordered);
		
		var deriveExpr="";
		var oclDeriveExpr = "";
		var isOcl = false;
		//TODO translate OCL expression
		if(ereference.derived){
			
			var eAnnotation = ereference.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

			if(eAnnotation!==null){
				
				oclDeriveExpr = eAnnotation.getDetails().get("derivation");
				if(oclDeriveExpr!==null){
					deriveExpr = "null"
					isOcl= true;
				}
			}
		}
		

		
		//TODO set container also when many=false and containment=true
		'''
		«IF ereference.many»
			«IF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
			private EMap<«t.translateType((ereference.EType as EClass).getEStructuralFeature("key").EType)», «t.translateType((ereference.EType as EClass).getEStructuralFeature("value").EType)»> «id.privateEStructuralFeature(ereference)»;
			«ELSEIF !ereference.derived»
			private «listType»<«id.doSwitch(ereference.EContainingClass.EPackage)».«t.translateType(ereference.EGenericType)»> «id.privateEStructuralFeature(ereference)»;
			«ENDIF»
			
			«IF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
			public virtual EMap<«t.translateType((ereference.EType as EClass).getEStructuralFeature("key").EType)», «t.translateType((ereference.EType as EClass).getEStructuralFeature("value").EType)»> «id.doSwitch(ereference)»
			«ELSE»
			public virtual «listType»<«id.doSwitch(ereference.EContainingClass.EPackage)».«t.translateType(ereference.EGenericType)»> «id.doSwitch(ereference)»
			«ENDIF»
			{
				get {
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return default(«listType»<«t.translateType(ereference.EGenericType)»>);
					«ELSEIF ereference.containment && ereference.EType.instanceClassName?.equals("java.util.Map$Entry")»
					if («id.privateEStructuralFeature(ereference)» == null)
					{
						«id.privateEStructuralFeature(ereference)» = new EcoreEMap<«t.translateType((ereference.EType as EClass).getEStructuralFeature("key").EType)», «t.translateType((ereference.EType as EClass).getEStructuralFeature("value").EType)»>(«id.literalRef(ereference.EType)», typeof(«id.doSwitch(ereference.EType)»), this, «ereference.featureID»);
					}
					return «id.privateEStructuralFeature(ereference)»;
					«ELSE»
					if(«id.privateEStructuralFeature(ereference)»==null){
						«id.privateEStructuralFeature(ereference)» = new «listType»<«t.translateType(ereference.EGenericType)»>(this, «id.literalRef(ereference)», «IF ereference.EOpposite!==null»«id.literalRef(ereference.EOpposite)»«ELSE»EOPPOSITE_FEATURE_BASE - «id.literalRef(ereference)»«ENDIF»);
					}
					return «id.privateEStructuralFeature(ereference)»;
					«ENDIF»
				}

			}
		«ELSE»
			«IF !(ereference.derived || (ereference.EOpposite!==null && ereference.EOpposite.containment))»
			private «id.doSwitch(ereference.EContainingClass.EPackage)».«t.translateType(ereference.EGenericType)» «id.privateEStructuralFeature(ereference)»;
			«ENDIF»
			public virtual «id.doSwitch(ereference.EContainingClass.EPackage)».«t.translateType(ereference.EGenericType)» «id.doSwitch(ereference)»
			{
				get {
				
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return default(«t.translateType(ereference.EGenericType)»);
					«ELSEIF ereference.EOpposite!== null && ereference.EOpposite.containment»
					if (eContainerFeatureID() != «id.literalRef(e, ereference)») return default(«t.translateType(ereference.EGenericType)»);
					return («id.doSwitch(ereference.EType)»)eInternalContainer();
					«ELSE»
					return «id.privateEStructuralFeature(ereference)»;
					«ENDIF» 
				}
				«IF !ereference.derived && ereference.changeable»
				set {
					«IF !ereference.containment && ereference.EOpposite===null»
					var oldvalue = «id.privateEStructuralFeature(ereference)»;
					«id.privateEStructuralFeature(ereference)» = value;
					if (eNotificationRequired()){
						eNotify(new ENotificationImpl(this, NotificationImpl.SET, «id.literalRef(e, ereference)», oldvalue, value));
					}
					«ELSE»
					«var featureId = if(ereference.EOpposite!==null) id.literalRef(ereference.EOpposite) else "EOPPOSITE_FEATURE_BASE - " + id.literalRef(e, ereference) »
					«var featureClass = if(ereference.EOpposite!==null) '''typeof(«id.doSwitch(ereference.EOpposite.EType)»)''' else "null"»
					«var getcurrentvalue = if(ereference.EOpposite!==null && ereference.EOpposite.containment) '''eInternalContainer()''' else id.privateEStructuralFeature(ereference)»
					if (value != «getcurrentvalue») {
						NotificationChain msgs = null;
						if («getcurrentvalue» != null){
							msgs = ((InternalEObject)«getcurrentvalue»).eInverseRemove(this, «featureId», «featureClass», msgs);
						}
						if (value != null){
							msgs = ((InternalEObject)value).eInverseAdd(this, «featureId», «featureClass», msgs);
						}
						msgs = «id.basicSetEReference(ereference)»(value, msgs);
						if (msgs != null) {
							msgs.dispatch();
						}
					}
					else if (eNotificationRequired()){
						eNotify(new ENotificationImpl(this, NotificationImpl.SET, «id.literalRef(e, ereference)», value, value));
					}
					«ENDIF»
					}
				«ENDIF»
			}
		«ENDIF»
		'''
		
	}
	

	
	override caseEOperation(EOperation e){
		
		var body = 	'''throw new NotImplementedException();'''
		
		var eAnnotation = e.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

		if(eAnnotation!==null){
			
			var body_ = eAnnotation.getDetails().get("body");
			
			if(body_!==null){
				body = '''return null;''';
			}
		}
		
		var returntype="";
		if(e.isMany){
			returntype = '''«t.listType(e.unique, e.ordered)»<«t.translateType(e.EGenericType)»>''';
		}
		else{
			returntype = '''«t.translateType(e.EGenericType)»'''
		}
		
		'''
	    public virtual «returntype» «id.doSwitch(e)»(«FOR EParameter parameter:e.EParameters SEPARATOR ','»«doSwitch(parameter)»«ENDFOR»)
	    {
	        «body»
	    }
		'''
	
	}
	
	
	


}