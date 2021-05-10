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
package com.crossecore

import java.io.File
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.impl.EcorePackageImpl
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.common.util.EList

class EcoreLoader {


	ResourceSet resourceSet = new ResourceSetImpl();

	new(){
		
		
		EcorePackageImpl.init();

	    var reg = Resource.Factory.Registry.INSTANCE;
	    var m = reg.getExtensionToFactoryMap();
	    m.put("ecore", new XMIResourceFactoryImpl());
	    m.put("xmi", new XMIResourceFactoryImpl());
	}
	def EList<EObject> load(File ecoreFile){
		

		var resource = resourceSet.getResource(URI.createFileURI(ecoreFile.absolutePath), true);
		
		resourceSet.getResource(URI.createFileURI(ecoreFile.absolutePath), true);
		
		return resource.getContents();
	}
	
	def void registerURI(String nsURI, EPackage instance){
		resourceSet.getPackageRegistry().put(nsURI, instance);
	}
	

}