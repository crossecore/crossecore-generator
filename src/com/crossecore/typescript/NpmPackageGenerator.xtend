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
		  "name": "morecomplexmodel",
		  "version": "1.0.0",
		  "scripts": {
		    "test": "jest",
		    "build": "webpack",
		    "start:dev": "webpack serve --open --mode production"
		  },
		  "files": ["dist"],
		  "main": "dist/morecomplexmodel.js",
		  "private": true,
		  "dependencies": {
		  	"crossecore": "^0.3.0"
		  },
		  "devDependencies": {
		    "@types/backbone": "^1.4.11",
		    "@types/jest": "^27.0.1",
		    "bootstrap": "^4.6.0",
		    "crossecore": "^0.3.0",
		    "css-loader": "^5.2.1",
		    "html-webpack-plugin": "^5.3.1",
		    "jest": "^26.6.3",
		    "jointjs": "^3.3.1",
		    "jquery": "^3.5.1",
		    "jsdom": "^17.0.0",
		    "popper.js": "^1.16.1",
		    "style-loader": "^2.0.0",
		    "touch": "^3.1.0",
		    "ts-jest": "^26.5.6",
		    "ts-loader": "^9.2.4",
		    "tsconfig-paths-webpack-plugin": "^3.5.1",
		    "tslib": "^2.2.0",
		    "typescript": "^4.2.4",
		    "webpack": "^5.47.0",
		    "webpack-cli": "^4.7.2",
		    "webpack-dev-server": "^4.0.0",
		    "xmldom": "^0.6.0"
		  }
		}
		'''

	}
	

}