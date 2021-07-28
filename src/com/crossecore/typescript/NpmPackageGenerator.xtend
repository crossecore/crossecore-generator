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
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils

class NpmPackageGenerator extends EcoreVisitor{
	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	override caseEPackage(EPackage epackage){
		
		val dependencies = Utils.getDependencies(epackage)
		return 
		'''
		{
		  "name": "«epackage.name»",
		  "version": "1.0.0",
		  "scripts": {
		    "build": "rimraf typings && yarn run declaration && rollup --config rollup.config.js",
		    "test": "jest",
		    "postinstall": "cti create ./src",
		    "declaration": "tsc -p . --emitDeclarationOnly --declaration true --declarationDir ./typings",
			"linking": "«FOR EPackage d:dependencies SEPARATOR " && "»yarn link «d.name»«ENDFOR»"
		  },
		  "files": ["dist", "typings"],
		  "main": "dist/«epackage.name».cjs.min.js",
		  "private": true,
		  "dependencies": {
		  	"crossecore": "^0.3.0"
		  },
		  "devDependencies": {
		    "@rollup/plugin-typescript": "^8.2.1",
		    "create-ts-index": "^1.13.6",
		    "rollup": "^2.47.0",
		    "rollup-plugin-cleanup": "^3.2.1",
		    "rollup-plugin-terser": "^7.0.2",
		    "ts-jest": "^26.5.6",
		    "tslib": "^2.2.0",
		    "typescript": "4.2.4",
		    "rimraf": "^3.0.2"
		  }
		}
		'''

	}
	

}