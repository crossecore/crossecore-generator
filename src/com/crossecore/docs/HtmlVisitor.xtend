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
package com.crossecore.docs;

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.util.EcoreUtil
import com.crossecore.EcoreVisitor
import com.crossecore.TypeTranslator
import com.crossecore.IdentifierProvider
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClassifier

class HtmlVisitor extends EcoreVisitor{

	private IdentifierProvider id = new IdentifierProvider();
	private TypeTranslator t = new EcoreTypeTranslator(id);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){
		
		'''
		<!doctype html>
		<html lang="de">  
		  <head>    
		    <meta charset="utf-8">    
		    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
		    <title>Package «id.doSwitch(epackage)»
		    </title>    
		    <!-- Latest compiled and minified CSS -->    
		    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">    
		    <!-- Optional theme -->    
		    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">    
		    <!-- Latest compiled and minified JavaScript -->
		    <link rel="stylesheet" href="https://cdn.jsdelivr.net/highlight.js/9.5.0/styles/default.min.css">
			<style>

			.panel-body > h4{
			    color: #31708f;
			    background-color: #d9edf7;
			    border: 1px solid #bce8f1;
			    padding: 10px;
			  
			}
			
			.panel-body > table{
			  width:100%;
			  
			}
			
			.panel-body > table td{
			  padding: 10px;
			}
			
			.panel-body > table th{
			  padding: 0 10px;
			}
			</style>
		    
		    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
		    
		
		    <script src="https://cdn.jsdelivr.net/highlight.js/9.5.0/highlight.min.js"></script>
		    <script>hljs.initHighlightingOnLoad();</script>
		      </head>  
		      <body>  
		        <div class="container">
		        <div class="jumbotron">
		          <h1>Package «id.doSwitch(epackage)»</h1>
		          Version: <br />
		          Date:
		          </p>
		          </div>
		          <!-- METAMODEL -->  
		          <div class="bs-docs-section">        
		            <div class="page-header">          
		              <div class="row">            
		                <div class="col-lg-12">              
		                  <h1>Meta Model</h1>            
		                </div>          
		              </div>        
		            </div>        
		            <div class="row">
		            
		    	          «FOR EClassifier eclassifier : epackage.EClassifiers»          
		    	  			«doSwitch(eclassifier)»
		    	  		«ENDFOR»
		              
		            </div>        
		          </div>
		        </div>  
		      </body>
		 </html>
		'''
	}
	
	override caseEClass(EClass eclass){ 

		var contraintsString = EcoreUtil.getAnnotation(eclass, "http://www.eclipse.org/emf/2002/Ecore", "constraints");
		var String[] constraints = null;
		if(contraintsString!=null){
		  	
			var constraintsInner = contraintsString.split(" ");
		  	
			constraints = constraintsInner;
		}
	
		'''
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><b>EClassifier</b> «eclass.name»</h3>
		     </div>
		<div class="panel-body">
		<h4>Description</h4>
		<p>To be defined.</p>
        «IF constraints!=null && constraints.size > 0»
			<h4>Invariants</h4>
			<table>
				<tbody>
				«FOR String key:constraints»
					<tr><td>«key»</td></tr>
					<tr><td>
					<pre><code class="cs hljs">«EcoreUtil.getAnnotation(eclass, "http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot", key)»</code></pre>
					</td></tr>
	            «ENDFOR»
				</tbody>
			</table>
		«ENDIF»
		<h4>EStructuralFeatures</h4>
		<table class="">
			<thead>
				<tr>
					<th>Name</th>
					<th>Type</th>
					<th>Multiplicity</th>
					<th>Tags</th>
					<th>Description</th>
				</tr>
			</thead>
			<tbody>
			«FOR EStructuralFeature feature: eclass.EStructuralFeatures»
				<tr>
					<td>«feature.name»</td>
					<td>«IF feature.EType instanceof EDataType»«t.translateType(feature.EGenericType)»«ELSE»«feature.EType.name»«ENDIF»</td>
					<td>«bound(feature.lowerBound)»..«bound(feature.upperBound)»</td>
					<td>
						«IF feature.changeable»
						<span class="label label-primary">changeable</span>
						«ENDIF»
						«IF feature.derived»
						<span class="label label-primary">derived</span>
						«ENDIF»
						«IF feature.ordered»
						<span class="label label-primary">ordered</span>
						«ENDIF»
						«IF feature.transient»
						<span class="label label-primary">transient</span>
						«ENDIF»
						«IF feature.unique»
						<span class="label label-primary">unique</span>
						«ENDIF»
						«IF feature.unsettable»
						<span class="label label-primary">unsettable</span>
						«ENDIF»
						«IF feature.volatile»
						<span class="label label-primary">volatile</span>
						«ENDIF»
						«IF feature instanceof EReference && (feature as EReference).containment»
						<span class="label label-primary">composes</span>
						«ENDIF»
					</td>
					<td>Some description</td>
					</tr>
					«var derivationExpression = EcoreUtil.getAnnotation(feature, "http://www.eclipse.org/emf/2002/Ecore/OCL/Pivot", "derivation")»
					«IF derivationExpression!=null»
					<tr>
						<td colspan="5">
							<pre><code class="cs hljs">«derivationExpression»</code></pre>
						</td>
					</tr>
                  «ENDIF»
				</tbody>
                «ENDFOR»
				</table>
			</div>
		</div>

		'''
	
	}
	
	protected def bound(int bound){
		
		if(bound<0){
			return "*"
		}
		else{
			return bound;
		}
	}
	




}
