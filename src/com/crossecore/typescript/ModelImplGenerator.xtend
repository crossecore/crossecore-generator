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
import com.crossecore.EcoreVisitor
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter
import org.eclipse.emf.ecore.EcorePackage
import java.util.ArrayList
import java.util.Formatter
import java.util.Locale

class ModelImplGenerator extends EcoreVisitor{ 
	

	TypeScriptIdentifier id = new TypeScriptIdentifier();
	TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	//private ImportManager imports = new ImportManager(t);
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	override List<String> index(){
		
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		
		
		val result = new ArrayList<String>()
		for(EClass eclass:sortedEClasses){
			
			val sb = new StringBuilder();
			val formatter = new Formatter(sb, Locale.US);
			val item = formatter.format(this.filenamePattern, this.epackage.name.toFirstUpper);
			result.add(item.toString)
		}
		return result;
		
	}
	
	override caseEPackage (EPackage epackage){
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		
		for(EClass eclass : sortedEClasses){
			
			var body = 	
			'''
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
			
			tt.import_(EcorePackage.eINSTANCE, "Set")
			tt.import_(e);
			tt.import_(e.EPackage, id.EClassBase(e));
			
			//TODO use importmanager
			'''
			export class «id.EClassImpl(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			extends «id.EClassBase(e)»«FOR ETypeParameter param : e.ETypeParameters BEFORE '<' SEPARATOR ',' AFTER '>'»«id.doSwitch(param)»«ENDFOR»
			{
				//implement your generated class here
			}
			'''
		
		}
	
	}

	
}