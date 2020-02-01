package com.crossecore.typescript

import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.TypeTranslator
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage

class TypeScriptTypeTranslator extends TypeTranslator{
	
	public static TypeScriptTypeTranslator INSTANCE = new TypeScriptTypeTranslator(new TypeScriptIdentifier());
	
	/*
	override String translateType(EGenericType type){
		if(type.EClassifier!= null && type.EClassifier.name == EcorePackage.Literals.EJAVA_CLASS.name){
			return "Function"
		}
		else{
			return super.translateType(type);
		}
	}
	*/
	

	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	public override String mapComplexType(EDataType type){
		switch type.name{
			case EcorePackage.Literals.EENUMERATOR.name:return "Enumerator"
			
			case EcorePackage.Literals.ERESOURCE.name: return "Resource"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "TreeIterator"
			case EcorePackage.Literals.EE_LIST.name: return "List"
		}
		return null;
				
	}
	
	public override String mapPrimitiveType(EDataType type){
		
		//nsURI is null in case of OCL Sequence, e.g. SequenceTypeImpl
		if(type.eContainer instanceof EPackage && (type.eContainer as EPackage).nsURI != null &&
			(type.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
		){
			
			switch type.name{
				case "Integer": return "number"
				case "String": return "string"
				case "Real": return "number"
				case "Boolean": return "boolean"
			}
		}
		
		switch type.instanceClassName{
			case 'java.math.BigDecimal': return 'number'
			case 'java.math.BigInteger': return 'number'
			case 'boolean': return 'boolean'
			case 'java.lang.Boolean': return 'boolean'
			case 'byte': return 'number'
			case 'byte[]': return 'Array<number>'
			case 'java.lang.Byte': return 'byte'
			case 'char': return 'string'
			case 'java.lang.Character': return 'string'
			case 'java.util.Date': return 'Date'
			case 'org.eclipse.emf.common.util.DiagnosticChain': return 'DiagnosticChain'//TODO import
			case 'double': return 'number'
			case 'java.lang.Double': return 'number'
			case 'org.eclipse.emf.common.util.EList': return 'EEList' //TODO import
			case 'org.eclipse.emf.common.util.Enumerator': return 'EEnumerator' //TODO import
			case 'org.eclipse.emf.ecore.util.FeatureMap': return 'EFeatureMap' //TODO import
			case 'org.eclipse.emf.ecore.util.FeatureMap$Entry': return 'EFeatureMapEntry' //TODO import
			case 'float': return 'number'
			case 'java.lang.Float': return 'number'
			case 'int': return 'number'
			case 'java.lang.Integer': return 'int'
			case 'java.lang.Class': return 'Function'
			case 'java.lang.Object': return 'any'
			case 'long': return 'number'
			case 'java.lang.Long': return 'number'
			//case 'java.util.Map': return 'number' //TODO https://stackoverflow.com/questions/42211175/typescript-hashmap-dictionary-interface
			case 'org.eclipse.emf.ecore.resource.Resource': return 'EResource' //TODO import
			case 'org.eclipse.emf.ecore.resource.ResourceSet': return 'EResourceSet' //TODO import
			case 'short': return 'number'
			case 'java.lang.Short': return 'number'
			case 'java.lang.String': return 'string'
			case 'org.eclipse.emf.common.util.TreeIterator': return 'ETreeIterator' //TODO import
			case 'java.lang.reflect.InvocationTargetException': return 'EInvocationTargetException' //TODO import
			
			
			
			
			
		}
				
		/*
		switch type.name{
			case EcorePackage.Literals.EJAVA_CLASS.name: return "Function"
			case EcorePackage.Literals.EBOOLEAN.name: return "boolean"
			case EcorePackage.Literals.EINT.name: return "number"
			case EcorePackage.Literals.EDOUBLE.name: return "number"
			case EcorePackage.Literals.EFLOAT.name: return "number"
			case EcorePackage.Literals.ESTRING.name: return "string"
			case EcorePackage.Literals.ECHAR.name: return "string"
			case EcorePackage.Literals.EJAVA_OBJECT.name: return "any"
		}
		*/
		
		return null;
	}
	
	override voidType(EGenericType type) {
		return "void";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "any"
	}
	
	override classType(EGenericType type) {
		"Function";
	}
	
	
}