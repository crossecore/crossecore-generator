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

import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import java.util.ArrayList
import java.util.Collections
import java.util.Collection
import org.eclipse.emf.ecore.ENamedElement

class EcoreTraverser {
	
	

	public def Collection<?> names(ENamedElement enamedelement){
		
		var result = new ArrayList<String>();
		
		result.add(enamedelement.name + enamedelement.hashCode);
		
		
		
		return result;
		
	}
	
	
	public def Collection<?> domain(EDataType datatype){
		
		switch datatype.classifierID{
			case EcorePackage.Literals.EBOOLEAN.classifierID: 
			{
				var result = new ArrayList<Boolean>();
				result.add(true);
				result.add(false);
				return result;
			}
			case EcorePackage.Literals.EINT.classifierID: 
			{
				var result = new ArrayList<Integer>();
				result.add(Integer.MIN_VALUE);
				result.add(-1);
				result.add(0);
				result.add(1);
				result.add(Integer.MAX_VALUE);
				return result;
			}
			case EcorePackage.Literals.EDOUBLE.classifierID: 
			{
				var result = new ArrayList<Double>();
				result.add(Double.MIN_VALUE);
				result.add(-1d);
				result.add(0d);
				result.add(1d);
				result.add(Double.MAX_VALUE);
				return result;
			}
			case EcorePackage.Literals.EFLOAT.classifierID: 
			{
				var result = new ArrayList<Float>();
				result.add(Float.MIN_VALUE);
				result.add(-1f);
				result.add(0f);
				result.add(1f);
				result.add(Float.MAX_VALUE);
				return result;
			}
			case EcorePackage.Literals.ESTRING.classifierID: 
			{
				var result = new ArrayList<String>();
				result.add("");
				result.add("Foobar");
				return result;
			}
			case EcorePackage.Literals.ECHAR.classifierID: 
			{
				var result = new ArrayList<Character>();
				result.add('a');
				result.add('»');
				return result;
			}
			case EcorePackage.Literals.EJAVA_OBJECT.classifierID: 
			{
				//TODO implement
				return Collections.EMPTY_LIST;
			}
			case EcorePackage.Literals.EJAVA_CLASS.classifierID: 
			{
				//TODO implement
				return Collections.EMPTY_LIST;
			}
			case EcorePackage.Literals.ERESOURCE.classifierID: 
			{
				//TODO implement
				return Collections.EMPTY_LIST;
			}
			case EcorePackage.Literals.ETREE_ITERATOR.classifierID: 			
			{
				//TODO implement
				return Collections.EMPTY_LIST;
			}
			case EcorePackage.Literals.EE_LIST.classifierID: 			
			{
				//TODO implement
				return Collections.EMPTY_LIST;
			}
			default:
			{
				return Collections.EMPTY_LIST;
			}
				
			
		}
		


	}
}