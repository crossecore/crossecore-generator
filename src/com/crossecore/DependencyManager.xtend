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
package com.crossecore;

import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedList
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import java.util.Collection
import java.util.Collections
import java.util.Comparator
import org.eclipse.emf.common.util.BasicEList
import java.util.HashSet
import java.util.Stack

class DependencyManager {
	
	//private HashMap<EClassifier, List<EClassifier>> dag;
	
	private static HashSet<EClass> visited;
	private static Stack<EClass> sorted;
	
	static def sortEClasses(Collection<EClass> eclassifiers){
		
		visited = new HashSet<EClass>();
		sorted = new Stack<EClass>();

		for(EClass root:eclassifiers){
			
			topSort(root);
		}
		
		
		return new BasicEList<EClass>(sorted);

	}
	
	static def void topSort(EClass eclass){
		
		for(EClass sup : eclass.ESuperTypes){
			
			if(!visited.contains(sup)){
				topSort(sup);
				visited.add(sup);
			}
		}
		if(!sorted.contains(eclass)){
			
			sorted.push(eclass);
		}
		
	}
	
	
	static def sortEClasses(EPackage epackage){
		
		val eclasses = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
		
		return sortEClasses(eclasses);

	}
	


}