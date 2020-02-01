package com.crossecore.typescript;

import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EEnum
import com.crossecore.IdentifierProvider
import com.crossecore.DependencyManager
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.Utils
import com.crossecore.ImportManager
import com.crossecore.TypeTranslator
import java.util.ArrayList

class PackageGenerator extends TypeScriptVisitor{
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	private TypeTranslator t = new TypeScriptTypeTranslator(id);
	private ImportManager imports = new ImportManager(t);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	
	override caseEPackage(EPackage epackage){
		var sortedEClasses_ = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
		var edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
		sortedEClasses_.addAll(edatatypes);
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		
		
		imports.add(EcorePackage.eINSTANCE,"EPackage");
		var body = 
		'''
		export interface «id.EPackagePackage(epackage)» extends EPackage {
			«FOR EClassifier eclassifier: sortedEClasses»
				«doSwitch(eclassifier)»
			«ENDFOR»
		}
		'''
		
		var imports = 
		'''
		«FOR String path : imports.fullyQualifiedImports»
			«IF imports.getPackage(path).nsURI.equals(epackage.nsURI)»
			import {«imports.getLocalName(path)»} from "./«imports.getLocalName(path)»";
			«ELSE»
			import {«imports.getLocalName(path)»} from "«path»";
			«ENDIF»
		«ENDFOR»
		'''
		
		return 
		'''
		«imports»
		«body»
		'''
	}
	
	override caseEEnum(EEnum enumeration){
		imports.add(EcorePackage.eINSTANCE,"EEnum");
		'''«id.getEEnum(enumeration)»():EEnum;'''
	}
	
	override caseEDataType(EDataType datatype){
		imports.add(EcorePackage.eINSTANCE,"EDataType");
		'''«id.getEDataType(datatype)»():EDataType;'''
	
	}
	
	override caseEClass(EClass eclass){
		imports.add(EcorePackage.eINSTANCE,"EClass");
		'''
		«id.getEClass(eclass)»():EClass;
		«FOR EReference ereference:eclass.EReferences»
			«doSwitch(ereference)»
		«ENDFOR»
		
		«FOR EAttribute eattribute:eclass.EAttributes»
			«doSwitch(eattribute)»
		«ENDFOR»
		'''
		
	}
	
	override caseEReference(EReference ereference){
		imports.add(EcorePackage.eINSTANCE, "EReference");
		'''«id.getEReference(ereference)»():EReference;'''
		
	}
	
	override caseEAttribute(EAttribute eattribute){
		imports.add(EcorePackage.eINSTANCE,"EAttribute");
		'''«id.getEAttribute(eattribute)»():EAttribute;'''
		
	}
}