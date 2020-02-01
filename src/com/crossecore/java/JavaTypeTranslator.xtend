package com.crossecore.java

import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage

class JavaTypeTranslator extends TypeTranslator {
	
	public static JavaTypeTranslator INSTANCE = new JavaTypeTranslator(new IdentifierProvider());

	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	override voidType(EGenericType type) {
		return "void";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "?";
	}

	
	public override String mapComplexType(EDataType type){
		//TODO is EDataType correct or should it be EClassifier or something?		
		switch type.name{
			case EcorePackage.Literals.EENUMERATOR.name:return "org.eclipse.emf.common.util.Enumerator"
			case EcorePackage.Literals.ERESOURCE.name: return "org.eclipse.emf.ecore.resource.Resource"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "org.eclipse.emf.common.util.TreeIterator"
			case EcorePackage.Literals.EE_LIST.name: return "org.eclipse.emf.common.util.EList"
			case EcorePackage.Literals.EMAP.name: return "org.eclipse.emf.common.util.EMap"
		}
		return null;
				
	}
	
	public override String mapPrimitiveType(EDataType type){
		
		//nsURI is null in case of OCL Sequence, e.g. SequenceTypeImpl
		if(type.eContainer instanceof EPackage && (type.eContainer as EPackage).nsURI != null &&
			(type.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
		){
			
			switch type.name{
				case "Integer": return "int"
				case "String": return "String"
				case "Real": return "float"
				case "Boolean": return "boolean"
			}
		}

		
		if(type.instanceClassName!==null){
			return type.instanceClassName;
		}
		
		/*
		switch type.name{
				case EcorePackage.Literals.EBOOLEAN.name: return "boolean"
				case EcorePackage.Literals.EINT.name: return "int"
				case EcorePackage.Literals.EBIG_INTEGER.name: return "int"
				case EcorePackage.Literals.EBIG_DECIMAL.name: return "double"
				case EcorePackage.Literals.EDOUBLE.name: return "double"
				case EcorePackage.Literals.EFLOAT.name: return "float"
				case EcorePackage.Literals.ESTRING.name: return "String"
				case EcorePackage.Literals.ECHAR.name: return "char"
				case EcorePackage.Literals.EJAVA_OBJECT.name: return "Object"
				case EcorePackage.Literals.EJAVA_CLASS.name: return "Class"
		}
		*/
		return null;
	}
	
	override classType(EGenericType type) {
		return "Class";
	}
	
	override listType(boolean unique, boolean ordered){
		
		//TODO better use import statement 
		
		if(!unique && !ordered){
			return "Ocllib.Bag"	
		}
		else if(!unique && ordered){
			return "Ocllib.Sequence"
		}
		else if(unique && !ordered){
			return "Ocllib.Set"
		}
		else if(unique && ordered){
			return "Ocllib.OrderedSet"
		}
		
	}
	
}