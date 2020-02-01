package com.crossecore.docs

import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider

class EcoreTypeTranslator extends TypeTranslator {
	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	public override String mapPrimitiveType(EDataType type){
		
		return type.name;
		/*
		switch type.name{
			
			case EcorePackage.Literals.EBIG_DECIMAL.name: return "EBigDecimal"
			case EcorePackage.Literals.EBIG_INTEGER.name: return "EBigInteger"
			case EcorePackage.Literals.EBOOLEAN.name: return "EBoolean"
			case EcorePackage.Literals.EBOOLEAN_OBJECT.name: return "EBooleanObject"
			case EcorePackage.Literals.EBYTE.name: return "EByte"
			case EcorePackage.Literals.EBYTE_ARRAY.name: return "EByteArray"
			case EcorePackage.Literals.EBYTE_OBJECT.name: return "EByteObject"
			case EcorePackage.Literals.ECHARACTER_OBJECT.name: return "ECharacterObject"
			case EcorePackage.Literals.EDATE.name: return "EDate"
			case EcorePackage.Literals.EDIAGNOSTIC_CHAIN.name: return "EDiagnosticChain"
			
			case EcorePackage.Literals.EDOUBLE.name: return "EDouble"
			case EcorePackage.Literals.EDOUBLE_OBJECT.name: return "EDoubleObject"
			case EcorePackage.Literals.EE_LIST.name: return "EEList"
			case EcorePackage.Literals.EENUMERATOR.name: return "EEnumerator"
			case EcorePackage.Literals.EFEATURE_MAP.name: return "EFeatureMap"
			case EcorePackage.Literals.EFEATURE_MAP_ENTRY.name: return "EFEATURE_MAP_ENTRY"
			case EcorePackage.Literals.EFLOAT.name: return "EFLOAT"
			case EcorePackage.Literals.EFLOAT_OBJECT.name: return "EFLOAT_OBJECT"
			case EcorePackage.Literals.EINT.name: return "EINT"
			case EcorePackage.Literals.EINTEGER_OBJECT.name: return "EINTEGER_OBJECT"
			case EcorePackage.Literals.EJAVA_CLASS.name: return "EJAVA_CLASS"
			case EcorePackage.Literals.EJAVA_OBJECT.name: return "EJAVA_OBJECT"
			case EcorePackage.Literals.ELONG.name: return "ELONG"
			
			case EcorePackage.Literals.ELONG_OBJECT.name: return "ELONG_OBJECT"
			case EcorePackage.Literals.EMAP.name: return "EMAP"
			case EcorePackage.Literals.ERESOURCE.name: return "ERESOURCE"
			case EcorePackage.Literals.ERESOURCE_SET.name: return "ERESOURCE_SET"
			case EcorePackage.Literals.ESHORT.name: return "ESHORT"
			case EcorePackage.Literals.ESHORT_OBJECT.name: return "ESHORT_OBJECT"
			case EcorePackage.Literals.ESTRING.name: return "ESTRING"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "ETREE_ITERATOR"
			case EcorePackage.Literals.EINVOCATION_TARGET_EXCEPTION.name: return "EINVOCATION_TARGET_EXCEPTION"
			
			
		}
		return null;
		*/
	}
	
	override voidType(EGenericType type) {
		return "Void";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "?"
	}
	
	override classType(EGenericType type) {
		return EcorePackage.Literals.EJAVA_CLASS.name;
	}
	
	override mapComplexType(EDataType type) {
		return null;
	}
	
}