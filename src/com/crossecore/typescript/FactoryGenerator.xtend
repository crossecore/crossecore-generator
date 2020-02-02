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

import com.crossecore.IdentifierProvider
import com.crossecore.ImportManager
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils

class FactoryGenerator extends TypeScriptVisitor{
	
	private IdentifierProvider id = new TypeScriptIdentifier();
	private ImportManager imports = new ImportManager(new TypeScriptTypeTranslator(id));
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	override caseEPackage (EPackage epackage){
		
		
		var body = '''
		export interface «id.EPackageFactory(epackage)» extends EFactory{
			«FOR EClassifier classifier: epackage.EClassifiers»
			«doSwitch(classifier)»
			«ENDFOR»
		}
		'''
		
		var imports = 
		'''
		«IF !Utils.isEcoreEPackage(epackage)»
		import {EFactory} from "ecore/EFactory";
		«ENDIF»
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

	
	override caseEClass(EClass eclass){
		if(!eclass.interface){
			imports.filter(eclass)
			'''
			 «id.createEClass(eclass)»():«id.doSwitch(eclass)»;
			'''
		}
	}
	
	
	
}