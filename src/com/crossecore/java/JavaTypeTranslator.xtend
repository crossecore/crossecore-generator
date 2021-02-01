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

import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage

class JavaTypeTranslator extends TypeTranslator {
	
	public static JavaTypeTranslator INSTANCE = new JavaTypeTranslator(new IdentifierProvider());

	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	override voidType(EGenericType type) {
		return "void";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "?";
	}

	
	override String mapComplexType(EDataType type){
		//TODO is EDataType correct or should it be EClassifier or something?		
		switch type.name{
			case EcorePackage.Literals.EENUMERATOR.name:return "org.eclipse.emf.common.util.Enumerator"
			case EcorePackage.Literals.ERESOURCE.name: return "org.eclipse.emf.ecore.resource.Resource"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "org.eclipse.emf.common.util.TreeIterator"
			case EcorePackage.Literals.EE_LIST.name: return "org.eclipse.emf.common.util.EList"
			case EcorePackage.Literals.EMAP.name: return "org.eclipse.emf.common.util.EMap"
		}
		return null;
				
	}
	
	override String mapPrimitiveType(EDataType type){
		
		//nsURI is null in case of OCL Sequence, e.g. SequenceTypeImpl
		if(type.eContainer instanceof EPackage && (type.eContainer as EPackage).nsURI !== null &&
			(type.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
		){
			
			switch type.name{
				case "Integer": return "int"
				case "String": return "String"
				case "Real": return "float"
				case "Boolean": return "boolean"
			}
		}

		
		if(type.instanceClassName!==null){
			return type.instanceClassName;
		}
		
		/*
		switch type.name{
				case EcorePackage.Literals.EBOOLEAN.name: return "boolean"
				case EcorePackage.Literals.EINT.name: return "int"
				case EcorePackage.Literals.EBIG_INTEGER.name: return "int"
				case EcorePackage.Literals.EBIG_DECIMAL.name: return "double"
				case EcorePackage.Literals.EDOUBLE.name: return "double"
				case EcorePackage.Literals.EFLOAT.name: return "float"
				case EcorePackage.Literals.ESTRING.name: return "String"
				case EcorePackage.Literals.ECHAR.name: return "char"
				case EcorePackage.Literals.EJAVA_OBJECT.name: return "Object"
				case EcorePackage.Literals.EJAVA_CLASS.name: return "Class"
		}
		*/
		return null;
	}
	
	override classType(EGenericType type) {
		return "Class";
	}
	
	override listType(boolean unique, boolean ordered){
		
		//TODO better use import statement 
		
		if(!unique && !ordered){
			return "com.crossecore.ocl.Bag"	
		}
		else if(!unique && ordered){
			return "com.crossecore.ocl.Sequence"
		}
		else if(unique && !ordered){
			return "com.crossecore.ocl.Set"
		}
		else if(unique && ordered){
			return "com.crossecore.ocl.OrderedSet"
		}
		
	}
	
}