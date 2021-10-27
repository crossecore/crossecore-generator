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

import com.crossecore.EcoreVisitor
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import org.eclipse.emf.ecore.EcorePackage

class FactoryGenerator extends EcoreVisitor{
	
	IdentifierProvider id = new TypeScriptIdentifier();
	//private ImportManager imports = new ImportManager(new TypeScriptTypeTranslator(id));
	TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	

	override caseEPackage (EPackage epackage){
		
		tt.import_(EcorePackage.eINSTANCE, "EFactory");
		var body = '''
		export interface «id.EPackageFactory(epackage)» extends EFactory{
			«FOR EClassifier classifier: epackage.EClassifiers»
			«doSwitch(classifier)»
			«ENDFOR»
		}
		'''
		
		
		return 
		'''
		«tt.printImports(epackage)»
		«body»
		'''
	}

	
	override caseEClass(EClass eclass){
		if(!eclass.interface){
			tt.import_(eclass)
			'''
			 «id.createEClass(eclass)»():«id.doSwitch(eclass)»;
			'''
		}
	}
	
	
	
}