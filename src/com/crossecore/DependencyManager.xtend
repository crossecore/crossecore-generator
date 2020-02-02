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
		
		var roots = eclassifiers.filter[e|e.ESuperTypes.empty];
		

		for(EClass root:eclassifiers){
			
			topSort(root);
		}
		
		
		var x = new BasicEList<EClass>(sorted);
		//Collections.reverse(x);
		
		return x;

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
	
	static def sortEClasses23(Collection<EClass> eclassifiers){
		
		var x = new BasicEList<EClass>(eclassifiers);
		
		Collections.sort(x, new Comparator<EClass>(){
			
			override compare(EClass arg0, EClass arg1) {
				//var transitive = new BasicEList<EClass>(arg1.EAllSuperTypes);
				//transitive.add(arg1);
				
				if(arg1.EAllSuperTypes.contains(arg0)){
					return -1;
				}
				else if(arg0.EAllSuperTypes.contains(arg1)){
					return 1;
				}
				else{
					return 0;
				}
			}
			
		});
		
		
		return x;
	}
	
	static def sortEClasses22(Collection<EClass> eclassifiers){
		
		//TODO support multi-inheritance
		var dag = new HashMap<EClass, List<EClass>>();
		var roots = new ArrayList<EClass>();
		
		for(EClass eclassifier: eclassifiers){
			
			if(eclassifier.ESuperTypes.empty){
				roots.add(eclassifier);
			}
			else{
				for(EClass _super: eclassifier.ESuperTypes){
					
					//we do not care about super types from other packages
					if(eclassifiers.contains(_super)){
						
						var list = dag.get(_super);
						if(list===null){
							list = new ArrayList<EClass>();
						}
						list.add(eclassifier);
						
						dag.put(_super, list);
					}
				}	
			}
		}
		
		var EClass eobject = null;
		var result = new ArrayList<EClass>();
		var queue = new LinkedList<EClass>();
		
		var iter = roots.iterator();
		while(eobject===null && iter.hasNext){
			
			var next = iter.next;
			
			if(Utils.isEClassifierForEObject(next)){
				
				eobject = next;
			}
		}
		
		queue.addAll(roots);

		if(eobject!==null){
			result.add(eobject);
			roots.remove(eobject)
			result.addAll(roots);
		}
		else{
			result.addAll(roots);
		}
		
		while(!queue.empty){
			
			var c = queue.poll();
			var list = dag.get(c);
			
			
			if(list!==null){
				queue.addAll(list);
				
				
				for(EClass _eclass : list){
					if(!result.contains(_eclass)){
						result.add(_eclass);
					}
				}
				
			}
			
		}
		
		
		return result;
	}
	
	static def sortEClasses(EPackage epackage){
		
		val eclasses = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
		
		return sortEClasses(eclasses);

	}
	


}