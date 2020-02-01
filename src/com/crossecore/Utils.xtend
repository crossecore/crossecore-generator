package com.crossecore

import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import java.util.List
import org.eclipse.emf.ecore.EOperation
import java.util.HashSet
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EClass
import java.util.HashMap
import java.util.ArrayList

class Utils {
	
	
	public static def boolean isEqual(EPackage epackage, EPackage other){
		return epackage.nsURI.equals(other.nsURI);
	}
	public static def boolean isEqual(EClassifier eclassifier, EClassifier other){
		
		var first = eclassifier.EPackage.nsURI+"."+eclassifier.name;
		var second = other.EPackage.nsURI+"."+other.name;
		
		return first.equals(second);
	}
	
	public static def isEClassifierForEObject(EClassifier eclassifier){
		
		if(eclassifier.name!=null && eclassifier.name=="EObject" && isEcoreEPackage(eclassifier.EPackage)){
			return true;
		}
		return false;
	}
	
	public static def isEcoreEPackage(EPackage epackage){
		if(epackage !=null && epackage.nsURI=="http://www.eclipse.org/emf/2002/Ecore"){
			return true;
		}
		return false;
	}
	
	/**
	 * Removes all EOperations that an EObject inherits from the EObject-Class
	 */
	public static def nonEObjectEOperations(List<EOperation> operations){
		
		var eobjectOperations = new HashSet<EOperation>(EcorePackage.Literals.EOBJECT.EOperations);
		var result = new HashSet<EOperation>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	/**
	 * Removes all EAttributes that an EObject inherits from the EObject-Class
	 */
	public static def nonEObjectEAttributes(List<EAttribute> operations){
		
		var eobjectOperations = new HashSet<EAttribute>(EcorePackage.Literals.EOBJECT.EAttributes);
		var result = new HashSet<EAttribute>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	/**
	 * Removes all EReferences that an EObject inherits from the EObject-Class
	 */
	public static def nonEObjectEReferences(List<EReference> operations){
		
		var eobjectOperations = new HashSet<EReference>(EcorePackage.Literals.EOBJECT.EReferences);
		var result = new HashSet<EReference>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	public static def getSubclassClosure(EPackage epackage){
		
		var result = new HashMap<EClass, HashSet<EClass>>();
		var eclasses = epackage.EClassifiers.filter[e|e instanceof EClass].map[e| e as EClass];
		
		for(EClass e:eclasses){
			for(EClass s:e.EAllSuperTypes){
				
				if(!result.containsKey(s)){
					result.put(s, new HashSet<EClass>());
				}
				
				var set = result.get(s);
				set.add(e);
				result.put(s, set);
				

			}
			if(!result.containsKey(e)){
				result.put(e, new HashSet<EClass>());
			}	
			
		}
		return result;
		
	}
	
	public static def getSubclasses(EClass eclass){
		
		return getSubclassClosure(eclass.EPackage).get(eclass);
	}
	
	public static def getFirstSuperclasses(EClass eclass){
		
		val result = new ArrayList<EClass>();
		
		
		var current = eclass;
		while(current!==null){
			if(current.ESuperTypes.size > 0){
				current = current.ESuperTypes.get(0);
				result.add(current);
			}
			else{
				current =null;
			}
		}
		return result;
	}
	
	public static def getInheritedOperations(EClass eclass){
		return getFirstSuperclasses(eclass).map[e|e.EOperations].flatten();
		
	}
	



}