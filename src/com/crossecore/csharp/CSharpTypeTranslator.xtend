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

import com.crossecore.TypeTranslator
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage

class CSharpTypeTranslator extends TypeTranslator {
	
	public static CSharpTypeTranslator INSTANCE = new CSharpTypeTranslator(new IdentifierProvider());

	
	new(IdentifierProvider _id) {
		super(_id)
	}
	
	override voidType(EGenericType type) {
		return "void";
	}
	
	override wildCardGenerics(EGenericType type) {
		return "object";
	}
	

	
	public override String mapComplexType(EDataType type){

		//TODO is EDataType correct or should it be EClassifier or something?		
		switch type.name{
			case EcorePackage.Literals.EENUMERATOR.name:return "EEnumerator"
			case EcorePackage.Literals.ERESOURCE.name: return "Resource"
			case EcorePackage.Literals.ETREE_ITERATOR.name: return "TreeIterator"
			case EcorePackage.Literals.EE_LIST.name: return "List"
		}
		return null;
				
	}
	
	public override String mapPrimitiveType(EDataType type){
		
		//nsURI is null in case of OCL Sequence, e.g. SequenceTypeImpl
		if(type.eContainer instanceof EPackage && (type.eContainer as EPackage).nsURI != null &&
			(type.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
		){
			
			switch type.name{
				case "Integer": return "int"
				case "String": return "string"
				case "Real": return "float"
				case "Boolean": return "bool"
			}
		}

		switch type.name{
			
				case EcorePackage.Literals.EBIG_DECIMAL.name: return "System.Numerics.BigInteger"//TODO check if BigInteger is ok
				case EcorePackage.Literals.EBIG_INTEGER.name: return "System.Numerics.BigInteger"
				
				case EcorePackage.Literals.EBOOLEAN.name: return "bool"
				case EcorePackage.Literals.EBOOLEAN_OBJECT.name: return "System.Boolean"
				
				case EcorePackage.Literals.EBYTE.name: return "byte"
				case EcorePackage.Literals.EBYTE_ARRAY.name: return "byte[]"
				case EcorePackage.Literals.EBYTE_OBJECT.name: return "System.Byte"
				
				case EcorePackage.Literals.ECHAR.name: return "char"
				case EcorePackage.Literals.ECHARACTER_OBJECT.name: return "System.Char"
				
				case EcorePackage.Literals.EDATE.name: return "System.DateTime"

				//case EcorePackage.Literals.EDIAGNOSTIC_CHAIN.name: return "???"
				
				case EcorePackage.Literals.EDOUBLE.name: return "double"
				case EcorePackage.Literals.EDOUBLE_OBJECT.name: return "System.Double"
				
				case EcorePackage.Literals.EE_LIST.name: return "List"
				
				
				case EcorePackage.Literals.ELONG.name: return "long"
				case EcorePackage.Literals.ELONG_OBJECT.name: return "System.Int64"
				
				case EcorePackage.Literals.EFLOAT.name: return "float"
				case EcorePackage.Literals.EFLOAT_OBJECT.name: return "System.Single"
				
				case EcorePackage.Literals.EINT.name: return "int"
				case EcorePackage.Literals.EINTEGER_OBJECT.name: return "System.Int32"

				case EcorePackage.Literals.EJAVA_OBJECT.name: return "object"
				case EcorePackage.Literals.EJAVA_CLASS.name: return "System.Type"
				
				case EcorePackage.Literals.ESHORT.name: return "short"
				//https://stackoverflow.com/questions/11224543/why-does-system-float-not-exist-in-net
				case EcorePackage.Literals.ESHORT_OBJECT.name: return "System.Single"
				
				case EcorePackage.Literals.ESTRING.name: return "string"
		}
		return null;
	}
	
	override classType(EGenericType type) {
		return "Type";
	}
	
}