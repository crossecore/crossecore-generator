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
	
	
	static def boolean isEqual(EPackage epackage, EPackage other){
		return epackage.nsURI.equals(other.nsURI);
	}
	static def boolean isEqual(EClassifier eclassifier, EClassifier other){
		
		var first = eclassifier.EPackage.nsURI+"."+eclassifier.name;
		var second = other.EPackage.nsURI+"."+other.name;
		
		return first.equals(second);
	}
	
	static def isEClassifierForEObject(EClassifier eclassifier){
		
		if(eclassifier.name!==null && eclassifier.name=="EObject" && isEcoreEPackage(eclassifier.EPackage)){
			return true;
		}
		return false;
	}
	
	static def isEcoreEPackage(EPackage epackage){
		if(epackage !==null && epackage.nsURI==="http://www.eclipse.org/emf/2002/Ecore"){
			return true;
		}
		return false;
	}
	
	/**
	 * Removes all EOperations that an EObject inherits from the EObject-Class
	 */
	static def nonEObjectEOperations(List<EOperation> operations){
		
		var eobjectOperations = new HashSet<EOperation>(EcorePackage.Literals.EOBJECT.EOperations);
		var result = new HashSet<EOperation>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	/**
	 * Removes all EAttributes that an EObject inherits from the EObject-Class
	 */
	static def nonEObjectEAttributes(List<EAttribute> operations){
		
		var eobjectOperations = new HashSet<EAttribute>(EcorePackage.Literals.EOBJECT.EAttributes);
		var result = new HashSet<EAttribute>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	/**
	 * Removes all EReferences that an EObject inherits from the EObject-Class
	 */
	static def nonEObjectEReferences(List<EReference> operations){
		
		var eobjectOperations = new HashSet<EReference>(EcorePackage.Literals.EOBJECT.EReferences);
		var result = new HashSet<EReference>(operations);
		result.removeAll(eobjectOperations);
		return result;
	}
	
	static def getSubclassClosure(EPackage epackage){
		
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
	
	static def getSubclasses(EClass eclass){
		
		return getSubclassClosure(eclass.EPackage).get(eclass);
	}
	
	static def getFirstSuperclasses(EClass eclass){
		
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
	
	static def getInheritedOperations(EClass eclass){
		return getFirstSuperclasses(eclass).map[e|e.EOperations].flatten();
		
	}
	
	static def getDependencies(EPackage epackage){
		return epackage
					.eResource
					.resourceSet
					.resources
					.map[r|r.contents]
					.flatten
					.filter[c|c instanceof EPackage]
					.map[o| o as EPackage]
					.filter[p|!(p as EPackage).nsURI.equals(epackage.nsURI)]
					.toList
	}
	



}