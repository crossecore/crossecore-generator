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
 package com.crossecore.csharp

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EPackage

abstract class CSharpVisitor extends EcoreVisitor {
	


	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	/*
	override def String translateType(EGenericType type){
		
		if(type==null){
			return "void";
		}
		
		var result = new StringBuffer();
		

		if(type.EClassifier != null){
					
			if(type.EClassifier.name == EcorePackage.Literals.EJAVA_CLASS.name){
				return "Type";
			}
			else if(type.EClassifier instanceof EDataType){
				
				result.append(mapDataType(type.EClassifier as EDataType));
			}
			else{
				result.append(type.EClassifier.name)	
			}
			
			result.append('''«FOR EGenericType argument: type.ETypeArguments BEFORE '<' SEPARATOR ',' AFTER '>'»«translateType(argument)»«ENDFOR»''');


		}
		else if(type.ETypeParameter!=null){
			result.append(type.ETypeParameter.name)	
		}
		else{
			result.append("object");
		}
	
		
		return result.toString;


	}
	* */
	
	

	
}