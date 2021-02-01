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
package com.crossecore.csharp;

import com.crossecore.DependencyManager
import com.crossecore.Utils
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter

class ModelImplGenerator extends CSharpVisitor{
	
	CSharpIdentifier id = new CSharpIdentifier();
	//private CSharpLiteralIdentifier literalId = new CSharpLiteralIdentifier();
	CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''	
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses_ = DependencyManager.sortEClasses(epackage);
		var sortedEClasses = sortedEClasses_.filter[e| e.EPackage.equals(epackage)];
		//var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		//eclassifiers.removeAll(sortedEClasses);
		
		for(EClass eclass : sortedEClasses){
			
			var contents = 	
				'''
				«header»
				using System;
				using System.Collections.Generic;
				using System.Linq;
				using System.Text;
				using oclstdlib;
				«IF !Utils.isEcoreEPackage(epackage)»
			 	using Ecore;
			 	«ENDIF»
				namespace «id.doSwitch(epackage)»{
					«doSwitch(eclass)»
				}
			'''
			
			write(eclass, contents, false);
		}
	
		return "";
	
	}
	
	override write(){
		doSwitch(epackage);
	}
	
	override caseEClass(EClass e) 
	{
		var closure = Utils.getSubclasses(e);
		
		if(!e.interface){

			'''
			public class «id.EClassImpl(e)» «FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			: «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				
				public static oclstdlib.Set<«id.EClassImpl(e)»> allInstances_ = new oclstdlib.Set<«id.EClassImpl(e)»>();
				
			    public static oclstdlib.Set<«id.doSwitch(e)»> allInstances()
				{

					var result = new oclstdlib.Set<«id.doSwitch(e)»>();
				    result.AddRange(«id.EClassImpl(e)».allInstances_);
					«FOR s:closure»
					result.AddRange(«id.EClassImpl(s)».allInstances_);
					«ENDFOR»
				
				    return result;
			    }
				
				//implement your generated class here	
			}
			'''
		
		}
	}



}