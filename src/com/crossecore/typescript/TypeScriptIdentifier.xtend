package com.crossecore.typescript

import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EReference
import com.crossecore.TypeTranslator

class TypeScriptIdentifier extends IdentifierProvider {
	
	private TypeTranslator t = new TypeScriptTypeTranslator(this);
	
	override escapeKeyword(String identifier) {
		var identifier_ = identifier.replace("arguments", "arguments_");
		
		return identifier_;
	}
	
	

	
	def caseOverloadedEOperation(EOperation eoperation){
		//TODO move the translateType function to IdentifierProvider
		
		return '''«eoperation.name»_«FOR EParameter eparameter:eoperation.EParameters SEPARATOR '_'»«t.translateType(eparameter.EGenericType)»«ENDFOR»'''
	}
	
	private def String resolveEPackageMethodOverloadingConflict(String name){
		
		var x = EcorePackage.Literals.EPACKAGE;
		for(EOperation c:x.EAllOperations){
			if(c.name.equals(name)){
				return name+"_";
			}
		}
		return name;
	}
	
	override getEClass(EClass eclass){
		var name = eclass.name.toFirstUpper;
		return resolveEPackageMethodOverloadingConflict("get"+name);
	}
	
	override String getEEnum(EEnum e){
		var name = e.name.toFirstUpper;
		return resolveEPackageMethodOverloadingConflict("get"+name);
	}
	
	override String getEDataType(EDataType e){
		var name = e.name.toFirstUpper;
		return resolveEPackageMethodOverloadingConflict("get"+name);
	}
	
	
	override String getEAttribute(EAttribute e){
		
		var classname = e.EContainingClass.name.toFirstUpper;
		var attributename = e.name.toFirstUpper;
		return resolveEPackageMethodOverloadingConflict("get"+classname+"_"+attributename);
	}
	
	override String getEReference(EReference e){
		
		var classname = e.EContainingClass.name.toFirstUpper;
		var attributename = e.name.toFirstUpper;
		return resolveEPackageMethodOverloadingConflict("get"+classname+"_"+attributename);
	}
	
	override literalRef(EClassifier eclass){
		
		
		return '''«EPackagePackageLiterals(eclass.EPackage)».«literal(eclass)»''';
	}
	
	override String literalRef(EClass eclass, EStructuralFeature feature){
		
		
		//TODO what to escape?
		//return '''«epackagename»PackageImpl.«literal(eclass, feature)»'''
		return '''«EPackagePackageLiterals(eclass.EPackage)».«literal(eclass, feature)»''';
	}
	
	def String super_eInverseAdd(EClass e){
		return '''eInverseAddFrom«doSwitch(e)»''';
	}
	
	def String super_eInverseAddRef(EClass e){
		return '''eInverseAddFrom«if (e.ESuperTypes.empty) "BasicEObjectImpl" else doSwitch(e.ESuperTypes.get(0))»''';
	}
	
	def String super_eInverseRemove(EClass e){
		return '''eInverseRemoveFrom«doSwitch(e)»''';
	}
	
	def String super_eInverseRemoveRef(EClass e){
		return '''eInverseRemoveFrom«if (e.ESuperTypes.empty) "BasicEObjectImpl" else doSwitch(e.ESuperTypes.get(0))»''';
	}

	def String super_eGet(EClass e){
		return '''eGetFrom«doSwitch(e)»''';
	}
	
	def String super_eGetRef(EClass e){
		return '''eGetFrom«if (e.ESuperTypes.empty) "BasicEObjectImpl" else doSwitch(e.ESuperTypes.get(0))»''';
	}
	
	def String EPackagePackageLiterals(EPackage pack){
		return EPackagePackage(pack)+"Literals";
	}
}