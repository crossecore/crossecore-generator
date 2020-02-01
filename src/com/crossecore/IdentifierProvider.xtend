package com.crossecore

import org.eclipse.emf.ecore.util.EcoreSwitch
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import java.util.Iterator

public class IdentifierProvider extends EcoreSwitch<String>{
	

	def String escapeKeyword(String id){
		return id;
	}


	override caseENamedElement(ENamedElement element){
		
		return element.name;
	}
	
	private def String _caseEPackage(EPackage epackage){
		var name = epackage.name.toFirstUpper;
		
		return name;
	}
	
	override caseEPackage(EPackage package_){

		return _caseEPackage(package_);
		
	}
	
	override doSwitch(EObject eobject){
		return escapeKeyword(super.doSwitch(eobject));
	}
	

	
	public def String privateEStructuralFeature(EStructuralFeature feature){
		
		var name = feature.name;
		var first = name.charAt(0).toString.toLowerCase;
		
		var result = "_"+first+name.substring(1);
		return escapeKeyword(result);

	}
	
	public def String literal(EClassifier eclass){
		
		return eclass.name.toUpperCase;

	}
	
	public def String literal(EOperation eoperation){
		//ECLASS___IS_SUPER_TYPE_OF__ECLASS
		var eclass = eoperation.EContainingClass;
		
		var parameters = new StringBuffer(); 
		
		
		
		for (var iter = eoperation.EParameters.iterator(); iter.hasNext();){
	      
	      	parameters.append("__")
			parameters.append(iter.next.name.toUpperCase);//TODO trim prefixed E?
			  
			
	    } 
		
		return '''«eclass.name.toUpperCase»___«eoperation.name.toUpperCase»«parameters»'''

	}
	
	public def String literal(EEnum eenum){
		
		return eenum.name.toUpperCase;

	}


	public def String literal(EDataType edatatype){
		
		return edatatype.name.toUpperCase;

	}
	
	public def String EClassifier_FEATURE_COUNT(EClassifier eclassifier){
		
		var name = eclassifier.name.toUpperCase;
		
		return name+"_FEATURE_COUNT";
	}
	
	public def String EClassifier_OPERATION_COUNT(EClassifier eclassifier){
		
		var name = eclassifier.name.toUpperCase;
		
		return name+"_OPERATION_COUNT";
	}

	
	public def String literalRef(EClassifier eclass){
		
		
		return '''«_caseEPackage(eclass.EPackage)»PackageImpl.Literals.«literal(eclass)»''';
	}
	
	public def String literal(EClass eclass, EStructuralFeature feature){
		var eclassname = eclass.name.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase;
		var efeaturename = feature.name.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase;
		
		return '''«eclassname»__«efeaturename»''';
	}
	
	public def String literal(EClass eclass, EOperation feature){
		var eclassname = eclass.name.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase;
		var efeaturename = feature.name.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase;
		
		return '''«eclassname»___«efeaturename»''';
	}
	
	public def String literalRef(EClass eclass, EStructuralFeature feature){
		
		
		var epackagename = _caseEPackage(eclass.EPackage);
		
		
		//TODO what to escape?
		return '''«epackagename»PackageImpl.«literal(eclass, feature)»'''

		
	}
	
	public def String literal(EStructuralFeature feature){
		
		
		return literal(feature.EContainingClass, feature);

	}
	
	public def String literalRef(EStructuralFeature feature){
		
		
		return literalRef(feature.EContainingClass, feature);

	}
	
	/*
	public def String basicSetEClassifier(EClassifier classifier) {
		return "basicSet"+classifier.name
	}
	*/
	
	public def String basicSetEReference(EReference ereference) {
		var name = ereference.name.toFirstUpper;
		return "basicSet"+name;
	}
	
	public def String EPackageFactory(EPackage epackage){
		var name = epackage.name.toFirstUpper;
		return name+"Factory";
	}
	public def String EPackageFactoryImpl(EPackage epackage){
		var name = epackage.name.toFirstUpper;
		return name+"FactoryImpl";
	}
	
	public def String createEClass(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return "create"+name;
	}
	
	public def String EClassImpl(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return name+"Impl"
	}
	
	public def String EClassBase(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return name+"Base"
	}
	
	public def String variable(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return "the"+name;
	}
	
	public def String EPackagePackage(EPackage epackage){
		var name = epackage.name.toFirstUpper;
		return name+"Package";
	}
	
	public def String EPackagePackageImpl(EPackage epackage){
		var name = epackage.name.toFirstUpper;
		return name+"PackageImpl";
	}
	
	public	def EPackageSwitch(EPackage ePackage) {
		var name = ePackage.name.toFirstUpper;
		return name+"Switch";
	}
	
	public def String getEClassifier(EClassifier e){


		if(e instanceof EEnum){
			return getEEnum(e as EEnum);
		}
		else if(e instanceof EDataType){
			return getEDataType(e as EDataType);
		}
		else if(e instanceof EClass){
			return getEClass(e as EClass);
		}
	}
	
	public def String getEClass(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return "get"+name;
	}
	
	public def String getEEnum(EEnum e){
		var name = e.name.toFirstUpper;
		return "get"+name;
	}
	
	public def String getEDataType(EDataType e){
		var name = e.name.toFirstUpper;
		return "get"+name;
	}
	
	
	public def String getEAttribute(EAttribute e){
		
		var classname = e.EContainingClass.name.toFirstUpper;
		var attributename = e.name.toFirstUpper;
		
		return "get"+classname+"_"+attributename;
	}
	
	public def String getEOperation(EOperation e){
		//getEModelElement__GetEAnnotation__String
		var classname = e.EContainingClass.name.toFirstUpper;
		var attributename = e.name.toFirstUpper;
		
		var parameters = new StringBuffer(); 
		
		
		
		for (var iter = e.EParameters.iterator(); iter.hasNext();){
	      
			parameters.append(iter.next.name.toFirstUpper);//TODO trim prefixed E?
			  
			if(iter.hasNext){
				parameters.append("__");
			}
	    }
		
		
		
		return '''get«classname»__«attributename»__«parameters»'''
	}
	
	public def String getEReference(EReference e){
		
		var classname = e.EContainingClass.name.toFirstUpper;
		var attributename = e.name.toFirstUpper;
		
		return "get"+classname+"_"+attributename;
	}
	
	public def String EClassEClass(EClass e){
		
		var name = e.name.toFirstUpper;
		return name+"EClass";
	}
	
	public def String EEnumEEnum(EEnum e){
		
		var name = e.name.toFirstUpper;
		return name+"EEnum";
	}
	public def String EDataTypeEDataType(EDataType e){
		
		var name = e.name.toFirstUpper;
		return name+"EDataType";
	}
	
	public def String EOperationEOperation(EOperation e){
		
		var name = e.name.toFirstUpper;
		return name+"EOperation";
	}


	
	public def EObject(EObject eobject){
		
		var idfeature = eobject.eClass.EIDAttribute;
		var id = "";
		
		if(idfeature!=null){
			
			id = eobject.eGet(idfeature).toString;
		}
		else{
			id = eobject.hashCode.toString;
		}
		
		var classname = eobject.eClass.name.toFirstLower;
		
		var identifier = classname+"_"+id;
		
		return identifier;
	}
	
	
	public def validate(EClassifier eclassifier){
		
		var name = eclassifier.name.toFirstUpper;
		return "validate"+name;
	}
	
	public def validate(EClassifier eclassifier, String invariant){
		
		var name = eclassifier.name.toFirstUpper;
		
		return "validate"+name+"_"+invariant;
	}
	
	
	public def getEStructuralFeature(EStructuralFeature eStructuralFeature){
		return '''get«eStructuralFeature.name.toFirstUpper»'''
	}
	
	public def isSetEStructuralFeature(EStructuralFeature eStructuralFeature){
		return '''isSet«eStructuralFeature.name.toFirstUpper»'''
	}
	
	public def setEStructuralFeature(EStructuralFeature eStructuralFeature){
		return '''set«eStructuralFeature.name.toFirstUpper»'''
	}
	
	public def edefault(EAttribute eAttribute){
		return '''«eAttribute.name.toUpperCase»_EDEFAULT'''
	}
	
	public def getEPackage(EPackage ePackage){
		return '''get«ePackage.name.toFirstUpper»'''
	}
	
	public def createEDataTypeFromString(EDataType eAttribute){
		return '''create«eAttribute.name.toFirstUpper»FromString'''
	}
	
	public def convertEDataTypeToString(EDataType eAttribute){
		return '''convert«eAttribute.name.toFirstUpper»ToString'''
	}
	
	
}