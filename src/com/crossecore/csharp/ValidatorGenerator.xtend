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
package com.crossecore.csharp

import org.eclipse.emf.ecore.EPackage
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.common.util.BasicEMap

class ValidatorGenerator extends CSharpVisitor{
	
	IdentifierProvider id = new CSharpIdentifier();
	CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	
	String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){
		
		var eclasses = epackage.EClassifiers.filter[e|e instanceof EClass].map[e| e as EClass].toList;
		
		
		
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
		using System.Collections.Generic;
		namespace «id.doSwitch(epackage)»{
			public class «id.doSwitch(epackage)»Validator : EObjectValidator {
		        protected override bool validate(int classifierID, object value, DiagnosticChain diagnostics, Dictionary<object, object> context)
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
		}
	'''
	}
	
	override caseEClass(EClass eclass){
		
			var eAnnotation = eclass.getEAnnotation("http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot");
			var invariants = if(eAnnotation!=null) eAnnotation.getDetails() else new BasicEMap();
			
			return 
			'''
			
			public bool «id.validate(eclass)»(«id.doSwitch(eclass)» obj, DiagnosticChain diagnostics, Dictionary<object, object> context)
			{
			    if (!validate_NoCircularContainment(obj, diagnostics, context)) return false;
			    bool result = validate_EveryMultiplicityConforms(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_EveryDataValueConforms(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_EveryReferenceIsContained(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_EveryBidirectionalReferenceIsPaired(obj, diagnostics, context);
			    //if (result || diagnostics != null) result &= validate_EveryProxyResolves(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_UniqueID(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_EveryKeyUnique(obj, diagnostics, context);
			    if (result || diagnostics != null) result &= validate_EveryMapEntryUnique(obj, diagnostics, context);
			    «FOR String invariant:invariants.keySet»
			    if (result || diagnostics != null) result &= «id.validate(eclass, invariant)»(obj, diagnostics, context);
			    «ENDFOR»
			    
			    return result;
			    
			}
			
			«FOR String invariant:invariants.keySet»
			public bool «id.validate(eclass, invariant)»(EClass eClass, DiagnosticChain diagnostics, Dictionary<object, object> context)
			{
			    return
			        validate
			            («id.literalRef(eclass)»,
			             eClass,
			             diagnostics,
			             context,
			             "http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot",
			             "«invariant»",
			             «ocl2csharp.translate(invariants.get(invariant), eclass)»,
			             DiagnosticImpl.ERROR,
			             DIAGNOSTIC_SOURCE,
			             0);
			}
	        «ENDFOR»
			'''


		
	} 
	
}