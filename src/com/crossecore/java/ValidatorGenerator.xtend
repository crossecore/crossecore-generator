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
package com.crossecore.java

import org.eclipse.emf.ecore.EPackage
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.common.util.BasicEMap
import com.crossecore.EcoreVisitor

class ValidatorGenerator extends EcoreVisitor{
	
	IdentifierProvider id = new JavaIdentifier();

	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){
		
		var eclasses = epackage.EClassifiers.filter[e|e instanceof EClass].map[e| e as EClass].toList;
		
		'''
		package «epackage.name»;
		import org.eclipse.emf.ecore.util.EObjectValidator;
		import org.eclipse.emf.common.util.DiagnosticChain;
		import org.eclipse.emf.ecore.EClass;
		import java.util.Map;
		
		public class «id.doSwitch(epackage)»Validator extends EObjectValidator {

			public static final «id.doSwitch(epackage)»Validator INSTANCE = new «id.doSwitch(epackage)»Validator();

			public static final String DIAGNOSTIC_SOURCE = "«epackage.name»";
			
			

	        protected boolean validate(int classifierID, Object value, DiagnosticChain diagnostics, Map<Object, Object> context)
	        {
	            switch (classifierID)
	            {
					«FOR EClass eclass: eclasses»
						case «id.doSwitch(eclass.EPackage)»PackageImpl.«id.doSwitch(eclass).toUpperCase»:
							return «id.validate(eclass)»((«id.doSwitch(eclass)»)value, diagnostics, context);	
					«ENDFOR»
	                
	
	                default:
	                    return true;
	            }
	        }
			«FOR EClass eclass: eclasses»
				«doSwitch(eclass)»
			«ENDFOR»
			
		}
	'''
	}
	
	override caseEClass(EClass eclass){
		
			var eAnnotation = eclass.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");
			var invariants = if(eAnnotation!==null) eAnnotation.getDetails() else new BasicEMap();
			
			return 
			'''
			
			public boolean «id.validate(eclass)»(«id.doSwitch(eclass)» obj, DiagnosticChain diagnostics, Map<Object, Object> context)
			{
	        	«IF invariants.size==0»
					return validate_EveryDefaultConstraint(obj, diagnostics, context);
	        	«ELSE»
		            if (!validate_NoCircularContainment(obj, diagnostics, context)) return false;
		            boolean result = validate_EveryMultiplicityConforms(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryDataValueConforms(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryReferenceIsContained(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryBidirectionalReferenceIsPaired(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryProxyResolves(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_UniqueID(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryKeyUnique(obj, diagnostics, context);
		            if (result || diagnostics != null) result &= validate_EveryMapEntryUnique(obj, diagnostics, context);
		            «FOR String invariant:invariants.keySet»
		            if (result || diagnostics != null) result &= «id.validate(eclass, invariant)»(obj, diagnostics, context);
		            «ENDFOR»
		            return result;
	        	«ENDIF»
			}
			
			«FOR String invariant:invariants.keySet»
			public boolean «id.validate(eclass, invariant)»(«id.doSwitch(eclass)» obj, DiagnosticChain diagnostics, Map<Object, Object> context){
				return obj.«invariant»(diagnostics, context);
			}
	        «ENDFOR»
			'''
			//FIXME: do not replace "self" with "this" 

		
	}
	
	
}