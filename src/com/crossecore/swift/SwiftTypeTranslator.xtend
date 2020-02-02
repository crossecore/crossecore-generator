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
package com.crossecore.swift

import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClassifier

class SwiftTypeTranslator extends TypeTranslator {
	
	public static SwiftTypeTranslator INSTANCE = new SwiftTypeTranslator(new IdentifierProvider());

	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	
	override def String defaultValue(EClassifier type){
		
		if(type.name == EcorePackage.Literals.EENUMERATOR.name){
			return "nil"
		}
		else{
			return super.defaultValue(type);
		}
		
	}
	
	
	override voidType(EGenericType type) {
		return "";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "Any";
	}
	
	public def translateTypeImpl(EGenericType type){
		
		if(type.EClassifier instanceof EDataType && (mapComplexType(type.EClassifier as EDataType)!=null || mapPrimitiveType(type.EClassifier as EDataType)!=null)){
			return translateType(type);
		}
		else{
			return translateType(type)+"Impl";
		}
		
	}
	

	
	public override String mapComplexType(EDataType type){

		//TODO is EDataType correct or should it be EClassifier or something?		
		switch type.name{
			case EcorePackage.Literals.EENUMERATOR.name:return "EEnumerator"
			case EcorePackage.Literals.ERESOURCE.name: return "Resource"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "TreeIterator"
			case EcorePackage.Literals.EE_LIST.name: return "Array"
		}
		return null;
				
	}
	
	public override String mapPrimitiveType(EDataType type){
		
		//nsURI is null in case of OCL Sequence, e.g. SequenceTypeImpl
		if(type.eContainer instanceof EPackage && (type.eContainer as EPackage).nsURI != null &&
			(type.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
		){
			
			switch type.name{
				case "Integer": return "Int"
				case "String": return "String"
				case "Real": return "Float"
				case "Boolean": return "Bool"
			}
		}

		
		switch type.name{
				case EcorePackage.Literals.EBOOLEAN.name: return "Bool"
				case EcorePackage.Literals.EINT.name: return "Int"
				case EcorePackage.Literals.EBIG_INTEGER.name: return "Int"
				case EcorePackage.Literals.EBIG_DECIMAL.name: return "Double"
				case EcorePackage.Literals.EDOUBLE.name: return "Double"
				case EcorePackage.Literals.EFLOAT.name: return "Float"
				case EcorePackage.Literals.ESTRING.name: return "String"
				case EcorePackage.Literals.ECHAR.name: return "Character"
				case EcorePackage.Literals.EJAVA_OBJECT.name: return "Any"
				case EcorePackage.Literals.EJAVA_CLASS.name: return "Mirror"
		}
		return null;
	}
	
	override classType(EGenericType type) {
		return "Mirror?";
	}
	
}