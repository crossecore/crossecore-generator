package com.crossecore.java;

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
import com.crossecore.EcoreVisitor
import org.eclipse.emf.common.util.BasicEMap
import org.eclipse.emf.common.util.BasicEList

class ModelBaseGenerator extends EcoreVisitor{
	
	private JavaIdentifier id = new JavaIdentifier();
	private TypeTranslator t = new JavaTypeTranslator(id);

	private JavaOCLVisitor ocl2csharp = new JavaOCLVisitor();
	
	
	new(){
		super();
	}
	
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
			package «epackage.name»;
			import org.eclipse.emf.common.notify.Notification;
			import org.eclipse.emf.common.notify.NotificationChain;
			import org.eclipse.emf.common.notify.impl.NotificationImpl;
			import org.eclipse.emf.ecore.InternalEObject;
			import org.eclipse.emf.ecore.*;
			import org.eclipse.emf.ecore.impl.ENotificationImpl;
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
			allAttributes = new BasicEList<EAttribute>(e.EAllAttributes);


			
			if(e.ESuperTypes.length>0){
				
				if(!e.ESuperTypes.get(0).interface){
					
					var minus = e.ESuperTypes.get(0).EAllAttributes;
					allAttributes.removeAll(minus); 
					
					var minus2 = e.ESuperTypes.get(0).EAllReferences;
					allReferences.removeAll(minus2); 
				}
				
			}
			
			var nonDirectSupertypes = new BasicEList<EClass>();
			if(e.ESuperTypes.size>1){
				nonDirectSupertypes.addAll(e.ESuperTypes.subList(1, e.ESuperTypes.size));
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
				//allAttributes = Utils.nonEObjectEAttributes(e.EAllAttributes);
				//allReferences = Utils.nonEObjectEReferences(e.EAllReferences);
				allOperations = Utils.nonEObjectEOperations(e.EAllOperations);
	
			}
	
			'''
			public class «id.EClassBase(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			extends «IF e.ESuperTypes.isEmpty || e.ESuperTypes.get(0).interface»org.eclipse.emf.ecore.impl.MinimalEObjectImpl.Container«ELSE»«id.EClassImpl(e.ESuperTypes.get(0))»«ENDIF» implements «IF Utils.isEcoreEPackage(epackage as EPackage)»org.eclipse.emf.ecore.«ENDIF»«id.doSwitch(e)»
			{
				«FOR EAttribute feature:allAttributes»«doSwitch(feature)»«ENDFOR»
				«FOR EReference feature:allReferences»«doSwitch(feature)»«ENDFOR»
				«FOR EOperation operation:allOperations»«doSwitch(operation)»«ENDFOR»
			
				
				@Override
				protected EClass eStaticClass() {
					return «id.literalRef(e)»;
				}
				
				«IF !referencesWithOpposite.empty»
				@Override
				public NotificationChain eInverseAdd(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
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
										msgs = ((InternalEObject)«id.privateEStructuralFeature(ref)»).eInverseRemove(this, «id.literalRef(ref)», «id.doSwitch(ref.EType)».class, msgs);
									}
									«ENDIF»
									return «id.basicSetEReference(ref)»((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ELSE»								
									return «id.getEStructuralFeature(ref)»().basicAdd((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ENDIF»
						«ENDFOR»
					}
					return super.eInverseAdd(otherEnd, featureID, msgs);
				}
				
				@Override
				public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
					switch (featureID) {
						«FOR EReference ref:referencesWithOpposite»
							case «id.literalRef(e, ref)»:
								«IF !ref.many»
								return «id.basicSetEReference(ref)»(null, msgs);
								«ELSE»
								return «id.getEStructuralFeature(ref)»().basicRemove((«id.doSwitch(ref.EType)»)otherEnd, msgs);
								«ENDIF»
						«ENDFOR»
					}
					return super.eInverseRemove(otherEnd, featureID, msgs);
				}
				«ENDIF»
				
				«IF !referencesSingle.empty»
					«FOR EReference ref:referencesSingle»
						«IF ref.EOpposite !== null && ref.EOpposite.containment»
						public NotificationChain «id.basicSetEReference(ref)»(«id.doSwitch(ref.EType)» newobj, NotificationChain msgs) {
								msgs = eBasicSetContainer((InternalEObject)newobj, «id.literalRef(ref)», msgs);
								return msgs;
						}
						«ELSE»
						public NotificationChain «id.basicSetEReference(ref)»(«id.doSwitch(ref.EType)» newobj, NotificationChain msgs) {
							«id.doSwitch(ref.EType)» oldobj = «id.privateEStructuralFeature(ref)»;
							«id.privateEStructuralFeature(ref)» = newobj;
							if (eNotificationRequired()) {
								ENotificationImpl notification = new ENotificationImpl(this, NotificationImpl.SET, «id.literalRef(ref)», oldobj, newobj);
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
				
				@Override
				public Object eGet(int featureID, boolean resolve, boolean coreType) {
					switch (featureID) {
						«FOR EStructuralFeature feature:allEStructuralFeatures»
						case «id.literalRef(e, feature)»:
							return «id.getEStructuralFeature(feature)»();
						«ENDFOR»
					}
					return super.eGet(featureID, resolve, coreType);
				}
				
				@Override
				public void eSet(int featureID, Object newValue) {
					switch (featureID) {
						«FOR EStructuralFeature feature:allEStructuralFeatures»
							«IF !feature.derived && feature.changeable»
							case «id.literalRef(e, feature)»:
								«IF feature.many»
									«id.getEStructuralFeature(feature)»().clear();
									«id.getEStructuralFeature(feature)»().addAll((java.util.Collection<? extends «t.translateType(feature.EGenericType)»>) newValue);
									return;
								«ELSE»
									«id.setEStructuralFeature(feature)»((«t.translateType(feature.EGenericType)») newValue);
									return;
								«ENDIF»
							«ENDIF»
						«ENDFOR»
					}
					super.eSet(featureID, newValue);
				}
				
				@Override
				public boolean eIsSet(int featureID) {
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
					return super.eIsSet(featureID);
				}
				
				«IF nonDirectSupertypes.size()>0»
				@Override
				public int eBaseStructuralFeatureID(int derivedFeatureID, Class<?> baseClass) {
					«FOR parent:nonDirectSupertypes»
					if (baseClass == «id.doSwitch(parent)».class) {
						switch (derivedFeatureID) {
							«FOR feature:parent.EStructuralFeatures»
							case «id.EPackagePackageImpl(e.EPackage)».«id.literal(e, feature)»: return «id.EPackagePackageImpl(e.EPackage)».«id.literal(parent, feature)»;
							«ENDFOR»
							default: return -1;
						}
					}
					«ENDFOR»
					return super.eBaseStructuralFeatureID(derivedFeatureID, baseClass);
				}
				
							
				@Override
				public int eDerivedStructuralFeatureID(int baseFeatureID, Class<?> baseClass) {
					«FOR parent:nonDirectSupertypes»
					if (baseClass == «id.doSwitch(parent)».class) {
						switch (baseFeatureID) {
							«FOR feature:parent.EStructuralFeatures»
							case «id.EPackagePackageImpl(e.EPackage)».«id.literal(parent, feature)»: return «id.EPackagePackageImpl(e.EPackage)».«id.literal(e, feature)»;
							«ENDFOR»
							default: return -1;
						}
					}
					«ENDFOR»
					return super.eDerivedStructuralFeatureID(baseFeatureID, baseClass);
				}
				«ENDIF»				
				
				«FOR String invariant:invariants.keySet»
				public boolean «invariant»(org.eclipse.emf.common.util.DiagnosticChain diagnostics, java.util.Map<Object, Object> context)
				{
					return «ocl2csharp.translate(invariants.get(invariant), e)»;
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
			private «listType»<«t.translateType(eattribute.EGenericType)»> «id.privateEStructuralFeature(eattribute)»;
			«ENDIF»
			
			public «listType»<«t.translateType(eattribute.EGenericType)»> «id.getEStructuralFeature(eattribute)»()
			{
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
			public void «id.setEStructuralFeature(eattribute)»(«t.translateType(eattribute.EGenericType)» value){
				«id.privateEStructuralFeature(eattribute)» = value;
			}
			«ENDIF»
		«ELSE»
			«IF !eattribute.derived»
			protected static final «t.translateType(eattribute.EGenericType)» «id.edefault(eattribute)» = «t.defaultValue(eattribute.EType)»;
			private «t.translateType(eattribute.EGenericType)» «id.privateEStructuralFeature(eattribute)» = «id.edefault(eattribute)»;
			«ENDIF»
			public «t.translateType(eattribute.EGenericType)» «id.getEStructuralFeature(eattribute)»()
			{
				«IF !eattribute.derived»
				return «id.privateEStructuralFeature(eattribute)»;
				«ELSEIF eattribute.derived && isOcl»
				/*«oclDeriveExpr»*/
				return «deriveExpr»;
				«ELSE»
				//TODO implement derivation
				return null;
				«ENDIF»
			}
			«IF !eattribute.derived && eattribute.changeable»
			public void «id.setEStructuralFeature(eattribute)»(«t.translateType(eattribute.EGenericType)» value){
				
				«t.translateType(eattribute.EGenericType)» oldValue = «id.privateEStructuralFeature(eattribute)»;
				«id.privateEStructuralFeature(eattribute)» = value;
				if (eNotificationRequired())
					eNotify(new ENotificationImpl(this, Notification.SET, «id.literalRef(eattribute)», oldValue, value));
				
			}
			«ENDIF»
			


		«ENDIF»
		'''
	
	}
	
	override caseEParameter(EParameter parameter)'''
		«t.translateType(parameter.EGenericType)» «id.doSwitch(parameter)»
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
			private «listType»<«t.translateType(ereference.EGenericType)»> «id.privateEStructuralFeature(ereference)»;
			«ENDIF»
			
			public «listType»<«t.translateType(ereference.EGenericType)»> «id.getEStructuralFeature(ereference)»()
			{
				«IF ereference.derived && isOcl»
				/*OCL: «oclDeriveExpr»*/
				return «deriveExpr»;
				«ELSEIF ereference.derived && !isOcl»
				//TODO implement derivation
				return null;
				«ELSE»
				if(«id.privateEStructuralFeature(ereference)»==null){
					«id.privateEStructuralFeature(ereference)» = new «listType»<«t.translateType(ereference.EGenericType)»>(«t.translateType(ereference.EGenericType)».class, this, «id.literalRef(ereference)», «IF ereference.EOpposite!==null»«id.literalRef(ereference.EOpposite)»«ELSE»EOPPOSITE_FEATURE_BASE - «id.literalRef(ereference)»«ENDIF»);
				}
				return «id.privateEStructuralFeature(ereference)»;
				«ENDIF»

			}
		«ELSE»
			«IF !(ereference.derived || (ereference.EOpposite!==null && ereference.EOpposite.containment))»
			private «t.translateType(ereference.EGenericType)» «id.privateEStructuralFeature(ereference)»;
			«ENDIF»
			public «t.translateType(ereference.EGenericType)» «id.getEStructuralFeature(ereference)»()
			{
				
					«IF ereference.derived && isOcl»
					/*OCL: «oclDeriveExpr»*/
					return «deriveExpr»;
					«ELSEIF ereference.derived && !isOcl»
					//TODO implement derivation
					return null;
					«ELSEIF ereference.EOpposite!== null && ereference.EOpposite.containment»
					if (eContainerFeatureID() != «id.literalRef(ereference)») return null;
					return («id.doSwitch(ereference.EType)»)eInternalContainer();
					«ELSE»
					return «id.privateEStructuralFeature(ereference)»;
					«ENDIF» 
				
				
			}
			«IF !ereference.derived && ereference.changeable»
			public void «id.setEStructuralFeature(ereference)»(«t.translateType(ereference.EGenericType)» value){
				«IF !ereference.containment && ereference.EOpposite===null»
				«t.translateType(ereference.EGenericType)» oldvalue = «id.privateEStructuralFeature(ereference)»;
				«id.privateEStructuralFeature(ereference)» = value;
				if (eNotificationRequired()){
					eNotify(new ENotificationImpl(this, NotificationImpl.SET,«id.literalRef(ereference)» , oldvalue, value));
				}
				«ELSE»
				«var featureId = if(ereference.EOpposite!==null) id.literalRef(ereference.EOpposite) else "EOPPOSITE_FEATURE_BASE - " + id.literalRef(ereference) »
				«var featureClass = if(ereference.EOpposite!==null) '''«t.translateType(ereference.EGenericType)».class''' else "null"»
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
					eNotify(new ENotificationImpl(this, NotificationImpl.SET,«id.literalRef(ereference)» , value, value));
				}
				«ENDIF»	
			}
			«ENDIF»
		«ENDIF»
		'''
		
	}
	

	
	override caseEOperation(EOperation e){
		
		var body = "";
		
		if(e.EType!==null){
			
			body = '''return «t.defaultValue(e.EType)»;'''
		}
		
		
		var eAnnotation = e.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");

		if(eAnnotation!==null){
			
			var body_ = eAnnotation.getDetails().get("body");
			
			if(body_!==null){
				body = 
				'''
				/*
				«body_»
				*/
				return «ocl2csharp.translate(body_, e.EContainingClass)»;
				''';
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
	    public «returntype» «id.doSwitch(e)»(«FOR EParameter parameter:e.EParameters SEPARATOR ','»«doSwitch(parameter)»«ENDFOR»)
	    {
	        «body»
	    }
		'''
	
	}
	

}