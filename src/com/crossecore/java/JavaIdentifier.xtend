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

import org.eclipse.emf.ecore.EObject
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EStructuralFeature

class JavaIdentifier extends IdentifierProvider {
	
	
	
	override escapeKeyword(String identifier) {
		switch(identifier){
			case "object",
			case "volatile",
			case "package",
			case "abstract",
			case "interface": return identifier+"_"
			default: return identifier
			
		}
	}
	
	public def escapeIdentifier(String str){
		
		var s = str;
		s = s.replace("-","_");
		s = s.replace("/","_");
		return s;
	}
	
	override EObject(EObject eobject){
		
		return escapeIdentifier(super.EObject(eobject));
	}
	
	//TODO should be propagated to other languages
	override getEStructuralFeature(EStructuralFeature eStructuralFeature){
		
		if(eStructuralFeature.EType.name.equals("EBoolean")){
			return '''is«eStructuralFeature.name.toFirstUpper»'''
		}
		else{
			
			return '''get«eStructuralFeature.name.toFirstUpper»'''
		}
		
	}
	
}