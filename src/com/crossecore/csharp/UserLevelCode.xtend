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
import java.util.List
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.EEnum
import com.crossecore.csharp.CSharpIdentifier
import org.eclipse.emf.ecore.EPackage

class UserLevelCode extends CSharpVisitor{
	
	
	CSharpIdentifier id = new CSharpIdentifier();
	EObject root;
	
	new(String path, String filenamePattern, EPackage epackage, EObject root){
		super(path, filenamePattern, epackage);
		this.root = root;

	}
	


	
	override write(){
		
		var contents =
		'''
		using MyPackage;

		namespace MyModel 
		{ 
			public class MyModel
			{
				public «id.doSwitch(root.eClass)» mock()
				{
					«doSwitch(root)»
					
					return «id.EObject(root)»;
		    	}
			}
		}
		'''
		
		write(epackage, contents);
	}

	
	private def String literal(EObject eobject, EAttribute eattribute){
		
		
		var eclassifier = eattribute.EType;
		var result = "";
		
		if(eclassifier instanceof EEnum){
			result = eclassifier.name + "." + (eclassifier as EEnum).getEEnumLiteralByLiteral(eobject.eGet(eattribute).toString);
		}
		else if(eclassifier instanceof EDataType){
				
			switch(eclassifier.name){
				case EcorePackage.Literals.EBOOLEAN.name: result = eobject.eGet(eattribute).toString
				case EcorePackage.Literals.EINT.name: result = eobject.eGet(eattribute).toString
				case EcorePackage.Literals.EDOUBLE.name: result = eobject.eGet(eattribute).toString
				case EcorePackage.Literals.EFLOAT.name: result = eobject.eGet(eattribute).toString
				case EcorePackage.Literals.ESTRING.name: result = "@\""+eobject.eGet(eattribute).toString.replace("\"","\"\"")+"\""
				case EcorePackage.Literals.ECHAR.name: result = "'"+eobject.eGet(eattribute).toString+"'"
			}
				
		}

		
		return result;
	}
	
	private def String literal(Object object, EAttribute eattribute){
		
		
		var eclassifier = eattribute.EType;
		var result = "";
		

		if(eclassifier instanceof EDataType){
				
			switch(eclassifier.name){
				case EcorePackage.Literals.EBOOLEAN.name: result = object.toString
				case EcorePackage.Literals.EINT.name: result = object.toString
				case EcorePackage.Literals.EDOUBLE.name: result = object.toString
				case EcorePackage.Literals.EFLOAT.name: result = object.toString
				case EcorePackage.Literals.ESTRING.name: result = "\""+object.toString+"\""
				case EcorePackage.Literals.ECHAR.name: result = "'"+object.toString+"'"
			}
				
		}

		
		return result;
	}
	
	override defaultCase(EObject eobject){
		
		'''
		var «id.EObject(eobject)» = «id.EPackageFactoryImpl(eobject.eClass.EPackage)».eINSTANCE.«id.createEClass(eobject.eClass)»();
		«FOR EAttribute eattribute : eobject.eClass.EAllAttributes»
			«IF !eattribute.derived»
				«IF eattribute.many»
					«var list = eobject.eGet(eattribute) as List<Object>»
					«FOR Object item:list»
						«id.EObject(eobject)».«eattribute.name».add(«literal(item, eattribute)»);
					«ENDFOR»
				«ELSE»
					«IF eobject.eGet(eattribute)!==null»
					«id.EObject(eobject)».«eattribute.name» = «literal(eobject, eattribute)»;
					«ENDIF»
				«ENDIF»
			«ENDIF»
		«ENDFOR»
		
		«FOR EReference ereference : eobject.eClass.EAllReferences»
			«IF !ereference.derived»
				«IF ereference.many»
					«var list = eobject.eGet(ereference) as List<Object>»
					«FOR Object item:list»
						«IF ereference.containment»
						«doSwitch(item as EObject)»
						«ENDIF»
						«IF ereference.EOpposite===null»
						«id.EObject(eobject)».«ereference.name».add(«id.EObject(item as EObject)»);
						«ENDIF»
					«ENDFOR»
				«ELSEIF !ereference.many»
					«var item = eobject.eGet(ereference) as EObject»
					«IF item!==null»
						«IF ereference.containment»
							«doSwitch(item)»
						«ENDIF»
						«id.EObject(eobject)».«ereference.name» = «id.EObject(item)»;
					«ENDIF»
				«ENDIF»
			«ENDIF»	
		«ENDFOR»
		'''
	}
	


	


	

}