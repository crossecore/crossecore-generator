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

class NpmPackageGenerator extends TypeScriptVisitor{
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	override caseEPackage(EPackage epackage){
		
		return 
		'''
		{
		  "name": "«epackage.name»",
		  "version": "1.0.0",
		  "scripts": {
		    "build": "tsc -p .",
		    "test": "jest"
		  },
		  "main": "lib/index.js",
		  "private": true,
		  "dependencies": {
		  	"crossecore": "^0.1.0"
		  },
		  "devDependencies": {
		    "typescript": "~3.5.2",
		  	"jest": "^24.8.0"
		  }
		}
		'''

	}
	

}