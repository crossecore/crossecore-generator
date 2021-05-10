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

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EPackage

class GradleGenerator extends EcoreVisitor{
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){

		'''
		apply plugin: 'java'
		
		repositories {
		  jcenter()
		  maven{
		  	url "https://oss.sonatype.org/content/repositories/snapshots/"
		  }
		}
		
		dependencies {
			compile group: 'org.eclipse.emf', name: 'org.eclipse.emf.ecore', version: '2.18.0'
			compile group: 'org.eclipse.emf', name: 'org.eclipse.emf.ecore.xmi', version: '2.16.0'
			compile group: 'com.crossecore', name: 'com.crossecore.ocl', version: '0.1.0-SNAPSHOT'
		}
		'''
	}
	
	
}