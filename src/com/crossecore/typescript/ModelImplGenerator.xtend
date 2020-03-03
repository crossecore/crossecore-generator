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
package com.crossecore.typescript;

import com.crossecore.DependencyManager
import com.crossecore.Utils
import com.crossecore.csharp.CSharpOCLVisitor
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter
import com.crossecore.ImportManager
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.TypeTranslator

class ModelImplGenerator extends TypeScriptVisitor{ 
	

	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	private CSharpOCLVisitor ocl2csharp = new CSharpOCLVisitor();
	//private TypeTranslator t = new TypeScriptTypeTranslator(id);
	private TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	//private ImportManager imports = new ImportManager(t);
	
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
		
	
	override caseEPackage (EPackage epackage){
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		
		for(EClass eclass : sortedEClasses){
			
			
			var body = 	
			'''
			«IF !Utils.isEcoreEPackage(epackage)»
			/* import Ecore*/
		 	«ENDIF»
			«doSwitch(eclass)»
			'''
			
			
			
			var contents =
			'''
			«tt.printImports(epackage)»
			«body»
			'''
			
			write(eclass, contents, false);
		}
	
		return "";
	}
	
	override write(){
		doSwitch(epackage);
	}
	

	
	override caseEClass(EClass e){

		if(!e.interface){
			
			//TODO what about allInstances on interfaces?
			var closure = Utils.getSubclasses(e);
			
			tt.import_(EcorePackage.eINSTANCE, "Set")
			tt.import_(e);
			tt.import_(e.EPackage, id.EClassBase(e));
			
			//TODO use importmanager
			'''
			export class «id.EClassImpl(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			extends «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				public static allInstances_:Set<«id.doSwitch(e)»> = new Set<«id.doSwitch(e)»>();
				//implement your generated class here
			}
			'''
		
		}
	
	}

	
	def caseEClass__(EClass e){

		if(!e.interface){
			
			//TODO what about allInstances on interfaces?
			var closure = Utils.getSubclasses(e);
			
			tt.import_(EcorePackage.eINSTANCE, "Set");
			tt.import_(e);
			tt.import_(e.EPackage, id.EClassBase(e));
			
			//TODO use importmanager
			'''
			export class «id.EClassImpl(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			extends «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{

				public static allInstances_:Set<«id.doSwitch(e)»> = new Set<«id.doSwitch(e)»>();
					
				public static allInstances():Set<«id.doSwitch(e)»>{
					
					let result = new Set<«id.doSwitch(e)»>();
					«id.EClassImpl(e)».allInstances_.forEach(x => result.push(x));
					
					«FOR s:closure»
					«tt.import_(s.EPackage, id.EClassImpl(s))»
					«id.EClassImpl(s)».allInstances_.forEach(x => result.push(x));
					«ENDFOR»
					
					return result;
				}
				
				
				//implement your generated class here
			}
			'''
		
		}
	
	}
	
}