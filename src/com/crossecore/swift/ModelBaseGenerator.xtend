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

import com.crossecore.DependencyManager
import com.crossecore.EcoreVisitor
import com.crossecore.Utils
import com.crossecore.csharp.CSharpOCLVisitor
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
import org.eclipse.emf.ecore.EcorePackage

class ModelBaseGenerator extends EcoreVisitor{
	
	SwiftIdentifier id = new SwiftIdentifier();
	SwiftTypeTranslator t = new SwiftTypeTranslator(id);

	CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		//var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		//eclassifiers.removeAll(sortedEClasses);
		
		for(EClass eclass : sortedEClasses){
			
			var contents = 	
			'''
			«IF !Utils.isEcoreEPackage(epackage)»
			using Ecore;
			«ENDIF»

			«doSwitch(eclass)»
			
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
		if(!e.interface){
		
			
			var allAttributes = new HashSet<EAttribute>();
			var allReferences = new HashSet<EReference>();
			var allOperations = new HashSet<EOperation>();
			var referencesSingle = new HashSet<EReference>();
			var referencesWithOpposite = new HashSet<EReference>();
			var referencesWithOppositeNonMany = new HashSet<EReference>();
			
			for(EReference ref:e.EReferences){
				
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
				allAttributes.addAll(e.EAttributes);
				allReferences.addAll(e.EReferences);
				
				var inheritedOperations = new HashSet<String>();
				for(EOperation op:e.EAllOperations){
					inheritedOperations.add(op.name);
				}
				
				for(EOperation op:e.EOperations){
					
					if(!inheritedOperations.contains(op)){
						allOperations.add(op);
					}
				}
			}
			else{
				//EClass inherits from EObject, but do want to exclude the EOperations from EObject, because we want to use the implementation from BasicEObjectImpl
				allAttributes = Utils.nonEObjectEAttributes(e.EAllAttributes);
				allReferences = Utils.nonEObjectEReferences(e.EAllReferences);
				allOperations = Utils.nonEObjectEOperations(e.EAllOperations);
	
			}
	
			'''
			class «id.EClassBase(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			:«IF e.ESuperTypes.isEmpty || e.ESuperTypes.get(0).interface»BasicEObjectImpl«ELSE»«id.EClassImpl(e.ESuperTypes.get(0))»«ENDIF», «id.doSwitch(e)»
			{
				«FOR EAttribute feature:allAttributes»«doSwitch(feature)»«ENDFOR»
				«FOR EReference feature:allReferences»«doSwitch(feature)»«ENDFOR»
				«FOR EOperation operation:allOperations»«doSwitch(operation)»«ENDFOR»
			
				override init(){
					super.init();
				}
				
				override func eStaticClass() -> EClass{
					return «id.literalRef(e)»!;
				}
				
				«IF !referencesWithOpposite.empty»
				override func eInverseAdd(otherEnd:InternalEObject?, featureID:Int?, msgs:NotificationChain?) -> NotificationChain?{
					var msgs_ = msgs;
					switch featureID {
						«FOR EReference ref:referencesWithOpposite»
							case «id.literalRef(e, ref)»?:
								«IF !ref.many»
									«IF ref.EOpposite.containment»
									if let eInternalContainer_ = eInternalContainer() {
										msgs_ = eBasicRemoveFromContainer(notifications:msgs_);
									}
									«ELSE»
									if let x = «id.privateEStructuralFeature(ref)» as? InternalEObject{
										msgs_ = x.eInverseRemove(otherEnd: self, featureID: «id.literalRef(ref)», baseClass: Mirror(reflecting: «id.doSwitch(ref.EType)».self), notifications: msgs_);
									}
									«ENDIF»
									return «id.basicSetEReference(ref)»(newobj:otherEnd as? «id.doSwitch(ref.EType)», msgs: msgs_);
								«ELSE»								
									return «id.doSwitch(ref)»?.basicAdd(element: otherEnd as! «id.doSwitch(ref.EType)»Impl, notifications: msgs_);
								«ENDIF»
						«ENDFOR»
						default:
							return super.eInverseAdd(otherEnd: otherEnd, featureID: featureID, msgs: msgs_);
					}
					
				}
				
				override func eInverseRemove(otherEnd:InternalEObject?, featureID:Int?, msgs:NotificationChain?) -> NotificationChain?{
					switch featureID {
						«FOR EReference ref:referencesWithOpposite»
							case «id.literalRef(e, ref)»?:
								«IF !ref.many»
								return «id.basicSetEReference(ref)»(newobj: nil, msgs: msgs);
								«ELSE»
								return «id.doSwitch(ref)»?.basicRemove(element: otherEnd as! «id.doSwitch(ref.EType)»Impl, notifications: msgs);
								«ENDIF»
						«ENDFOR»
						default:
							return super.eInverseRemove(otherEnd: otherEnd, featureID: featureID, msgs: msgs);
					}
				}
				«ENDIF»
				
				«IF !referencesSingle.empty»
					«FOR EReference ref:referencesSingle»
						«IF ref.EOpposite !== null && ref.EOpposite.containment»
						func «id.basicSetEReference(ref)»(newobj:«id.doSwitch(ref.EType)»?, msgs:NotificationChain?) -> NotificationChain?{
							var msgs_ = msgs;
							if let newobj_ = newobj as? InternalEObject{
								msgs_ = eBasicSetContainer(newContainer:newobj_, newContainerFeatureID:EcorePackageImpl.EANNOTATION_EMODELELEMENT, notifications:msgs);
							}
							else{
								msgs_ = eBasicSetContainer(newContainer:nil, newContainerFeatureID:EcorePackageImpl.EANNOTATION_EMODELELEMENT, notifications:msgs);
							}
							return msgs_;
						}
						«ELSE»
						func «id.basicSetEReference(ref)»(newobj:«id.doSwitch(ref.EType)»?, msgs:NotificationChain?) -> NotificationChain?{
							var msgs_:NotificationChain? = msgs;
							
							let oldobj = «id.privateEStructuralFeature(ref)»;
							«id.privateEStructuralFeature(ref)» = newobj;
							if (eNotificationRequired()) {
								var notification = ENotificationImpl(notifier: self, eventType: NotificationImpl.SET, featureID: «id.literalRef(ref)», oldValue: oldobj, newValue: newobj);
								if let msgs__=msgs_{
								    msgs__.add(notification: notification);
								    msgs_ = msgs__;
								}
								else{
								    msgs_ = notification;
								}
							}
							return msgs_;
						}
						«ENDIF»
					«ENDFOR»
				«ENDIF»
				
				override func eGet(featureID:Int?, resolve:Bool?, coreType:Bool?) -> Any?{
					switch (featureID) {
						«FOR EStructuralFeature feature:e.EAllStructuralFeatures»
						case «id.literalRef(e, feature)»?:
							return «id.doSwitch(feature)»;
						«ENDFOR»
						default:
							return super.eGet(featureID: featureID, resolve: resolve, coreType: coreType);
					}
				}
				
				
				override func eSet(featureID:Int?, newValue:Any?) {
					switch featureID {
						«FOR EStructuralFeature feature:e.EAllStructuralFeatures»
							«IF !feature.derived && feature.changeable»
							case «id.literalRef(e, feature)»?:
								«IF feature.many»
									«id.doSwitch(feature)»?.clear();
									if let items = newValue as? «t.listType(feature.unique, feature.ordered)»<«t.translateTypeImpl(feature.EGenericType)»>{
										«id.doSwitch(feature)»?.addAll(items: items);
									}
									return;
								«ELSE»
									if let newValue_ = newValue as? «t.translateType(feature.EGenericType)»{
										«id.doSwitch(feature)» = newValue_;
									}
									return;
								«ENDIF»
							«ENDIF»
						«ENDFOR»
						default:
							super.eSet(featureID: featureID, newValue: newValue);
					}
				}
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
					deriveExpr = ocl2csharp.translate(oclDeriveExpr, eattribute.EContainingClass);
					//deriveExpr = "null"; //FIXME enable OCL to C# translation
					isOcl= true;
				}		
			}
		}
	
		//TODO Do not add a field when it is derived or containment feature	
		'''
		«IF eattribute.many»
			«IF !eattribute.derived»
			private lazy var «id.privateEStructuralFeature(eattribute)»:«listType»<«t.translateType(eattribute.EGenericType)»>? = «listType»<«t.translateType(eattribute.EGenericType)»>?();
			«ENDIF»
			
			var «id.doSwitch(eattribute)»:«listType»<«t.translateType(eattribute.EGenericType)»>?
			{
				get {
					«IF !eattribute.derived»
					return «id.privateEStructuralFeature(eattribute)»;
					«ELSE»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ENDIF»					
				}
				«IF !eattribute.derived && eattribute.changeable»
				set(value) { «id.privateEStructuralFeature(eattribute)» = value; }
				«ENDIF»
			}
		«ELSE»
			«IF !eattribute.derived»
			private var «id.privateEStructuralFeature(eattribute)»:«t.translateType(eattribute.EGenericType)»? = «t.defaultValue(eattribute.EType)»;
			«ENDIF»
			var «id.doSwitch(eattribute)»:«t.translateType(eattribute.EGenericType)»?
			{
			get { 
				«IF !eattribute.derived»
				return «id.privateEStructuralFeature(eattribute)»;
				«ELSEIF eattribute.derived && isOcl»
				/*«oclDeriveExpr»*/
				return «deriveExpr»;
				«ELSE»
				//TODO implement derivation
				return nil;//«t.translateTypeImpl(eattribute.EGenericType)»();
				«ENDIF»	
			}
			«IF !eattribute.derived && eattribute.changeable»
			set(value) { «id.privateEStructuralFeature(eattribute)» = value; }
			«ENDIF»
			}
		«ENDIF»
		'''
	
	}
	
	override caseEParameter(EParameter parameter)'''
		«id.doSwitch(parameter)»:«t.translateType(parameter.EGenericType)»?
	'''
	
	override caseEReference(EReference ereference){
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
					deriveExpr = ocl2csharp.translate(oclDeriveExpr, ereference.EContainingClass);
					isOcl= true;
				}
			}
		}
		
		
		//TODO set container also when many=false and containment=true
		'''
		«IF ereference.many»
			«IF !ereference.derived»
			private var «id.privateEStructuralFeature(ereference)»:«listType»<«t.translateTypeImpl(ereference.EGenericType)»>? = nil;
			«ENDIF»
			
			var «id.doSwitch(ereference)»:«listType»<«t.translateTypeImpl(ereference.EGenericType)»>?
			{
				get {
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return «listType»<«t.translateTypeImpl(ereference.EGenericType)»>();
					«ELSE»
					if let x = «id.privateEStructuralFeature(ereference)»{
						«id.privateEStructuralFeature(ereference)» = «listType»<«t.translateTypeImpl(ereference.EGenericType)»>(owner: self as InternalEObject, featureId: «id.literalRef(ereference)», oppositeFeatureId: «IF ereference.EOpposite!==null»«id.literalRef(ereference.EOpposite)»«ELSE»BasicEObjectImpl.EOPPOSITE_FEATURE_BASE - «id.literalRef(ereference)»«ENDIF»);
					}
					return «id.privateEStructuralFeature(ereference)»!;
					
					
					«ENDIF»
				}

			}
		«ELSE»
			«IF !(ereference.derived || (ereference.EOpposite!==null && ereference.EOpposite.containment))»
			private var «id.privateEStructuralFeature(ereference)»:«t.translateType(ereference.EGenericType)»?;
			«ENDIF»
			var «id.doSwitch(ereference)»:«t.translateType(ereference.EGenericType)»?
			{
				get {
				
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return nil;//«t.translateType(ereference.EGenericType)»Impl();
					«ELSEIF ereference.EOpposite!== null && ereference.EOpposite.containment»
					return (eContainerFeatureID() == «id.literalRef(ereference)») ? eInternalContainer() as? «id.doSwitch(ereference.EType)» : nil;
					«ELSE»
					return «id.privateEStructuralFeature(ereference)»;
					«ENDIF» 
				}
				«IF !ereference.derived && ereference.changeable»
				set(value) {
					«IF !ereference.containment && ereference.EOpposite===null»
					var oldvalue = «id.privateEStructuralFeature(ereference)»;
					«id.privateEStructuralFeature(ereference)» = value;
					if (eNotificationRequired()){
						eNotify(notification:ENotificationImpl(notifier: self, eventType: NotificationImpl.SET, featureID: «id.literalRef(ereference)» , oldValue: oldvalue, newValue: value));
					}
					«ELSE»
					«var featureId = if(ereference.EOpposite!==null) id.literalRef(ereference.EOpposite) else "BasicEObjectImpl.EOPPOSITE_FEATURE_BASE - " + id.literalRef(ereference) »
					«var featureClass = if(ereference.EOpposite!==null) '''Mirror(reflecting:«id.doSwitch(ereference.EOpposite.EType)».self)''' else "nil"»
					«var etype = t.translateTypeImpl(ereference.EGenericType)»
					«var getcurrentvalue = if(ereference.EOpposite!==null && ereference.EOpposite.containment) '''eInternalContainer()''' else id.privateEStructuralFeature(ereference)»
					if let value_ = value as? «etype»{
					
						if let container = «getcurrentvalue» as? «etype»{
					
							if(value_ != container){
								var msgs:NotificationChain? = nil;
								msgs = container.eInverseRemove(otherEnd: self, featureID: «featureId», baseClass: «featureClass», notifications: msgs);
								msgs = value_.eInverseAdd(otherEnd: self, featureID: «featureId», baseClass: «featureClass», notifications: msgs);
								msgs = «id.basicSetEReference(ereference)»(newobj: value, msgs: msgs);
								if let msgs_ = msgs{
									msgs_.dispatch();
								}
							}
						}
					}
					if (eNotificationRequired()){
						eNotify(notification:ENotificationImpl(notifier:self, eventType: NotificationImpl.SET,featureID: «id.literalRef(ereference)» , oldValue: value, newValue: value));
					}
					
					«ENDIF»
				}
				«ENDIF»
			}
		«ENDIF»
		'''
		
	}
	

	private def String eOperation2String(EOperation o){
		var sb = new StringBuffer();
		sb.append(o.name);
		
		var iter = o.EParameters.iterator();
		
		while(iter.hasNext){
			var s = t.translateType(iter.next().EGenericType);
			sb.append(s);
			
			if(iter.hasNext){
				sb.append("_");
			}
			
		}
		
		sb.append("->");
		if(o.EGenericType===null){
			sb.append("null");
		}
		else{
			sb.append(t.translateType(o.EGenericType));
		}
		
		return sb.toString;
		

	}
	
	override caseEOperation(EOperation e){
		
		var signatures = new HashSet<String>();
		var operations = new HashSet<EOperation>();
		if(!e.EContainingClass.ESuperTypes.empty){
			operations.addAll(e.eClass.ESuperTypes.get(0).EAllOperations);
		}
		else{
			operations.addAll(EcorePackage.Literals.EOBJECT.EAllOperations);
		}
		
		
		//operations.removeAll(e.eClass.EOperations);

		
		
		for(EOperation o : operations){
			signatures.add(eOperation2String(o));
			
		}
		
		var override_ = signatures.contains(eOperation2String(e));
		
		var body = '''fatalError("not implemented exception");'''
		
		var eAnnotation = e.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

		if(eAnnotation!==null){
			
			var body_ = eAnnotation.getDetails().get("body");
			
			if(body_!==null){
				body = '''return «ocl2csharp.translate(body_, e.EContainingClass)»;''';
			}
		}
		
		var returntype="";
		if(e.isMany){
			returntype = '''«t.listType(e.unique, e.ordered)»<«t.translateType(e.EGenericType)»>?''';
		}
		else{
			returntype = '''«t.translateType(e.EGenericType)»?'''
		}
		
		'''
	    «IF override_»override «ENDIF»func «id.doSwitch(e)»(«FOR EParameter parameter:e.EParameters SEPARATOR ','»«doSwitch(parameter)»«ENDFOR») «IF e.EGenericType!==null»-> «returntype»«ENDIF»
	    {
	        «body»
	    }
		'''
	
	}
	
	
	


}