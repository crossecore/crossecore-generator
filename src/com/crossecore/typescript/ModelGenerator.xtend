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
package com.crossecore.typescript;

import com.crossecore.Utils
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.EcoreVisitor

class ModelGenerator extends EcoreVisitor{ 
	
	TypeScriptIdentifier id = new TypeScriptIdentifier();
	//private TypeTranslator t = new TypeScriptTypeTranslator(id);
	TypeScriptTypeTranslator2 tt = new TypeScriptTypeTranslator2();
	//private ImportManager imports = new ImportManager(t);
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override write(){
		doSwitch(epackage);
	}

	override caseEPackage(EPackage epackage) {
		var Set<EClassifier> eclassifiers = new LinkedHashSet<EClassifier>();
		eclassifiers.addAll(epackage.EClassifiers.filter[e|e instanceof EClass]);
		eclassifiers.addAll(epackage.EClassifiers.filter[e|e instanceof EEnum]);
		
		for(EClassifier classifier: eclassifiers){
			tt.clearImports;
			tt.setCurrentClassifier(classifier)
			var body = 	
			'''
			«doSwitch(classifier)»
			'''
			
			var contents =
			'''
			«tt.printImports(epackage)»
			«body»
			'''
			write(classifier, contents);
			tt.clearCurrentClassifier
		}
		
		return "";
	
	}
	

	override caseEClass(EClass e){

		var overloading = new HashMap<String, List<EOperation>>();
		
		for(EOperation op : e.EOperations){
			
			var overloaded = overloading.get(op.name);
			if(overloaded===null){
				overloaded = new ArrayList<EOperation>();
			}
			overloaded.add(op);
			overloading.put(op.name, overloaded);
					
		}
			
		
		'''

			export interface «e.name»
			«IF e.ESuperTypes.empty && !Utils.isEClassifierForEObject(e)»
				extends InternalEObject
				«tt.import_(EcorePackage.eINSTANCE,"InternalEObject")»
			«ELSEIF (Utils.isEClassifierForEObject(e))»
				extends Notifier
				«tt.import_(EcorePackage.eINSTANCE, "Notifier")»
			«ELSE»
				«FOR EClassifier supertype:e.ESuperTypes BEFORE 'extends ' SEPARATOR ','»
					«id.doSwitch(supertype)»
					«tt.import_(supertype.EPackage, id.doSwitch(supertype))»
				«ENDFOR»
			«ENDIF»

			{
				«FOR EAttribute attrib : e.EAttributes»
					«caseEAttribute(attrib)»
				«ENDFOR»
				
				«FOR EReference ereference : e.EReferences»
					«caseEReference(ereference)»
				«ENDFOR»
				
				«FOR String name : overloading.keySet»
					«IF overloading.get(name).size > 1»
						«operationSplit(overloading.get(name))»
					«ENDIF»
					
					«FOR EOperation eoperation : overloading.get(name)»
						«IF overloading.get(name).size > 1»
							«caseEOperation(eoperation, true)»
						«ELSE»
							«caseEOperation(eoperation)»
						«ENDIF»
					«ENDFOR»
				«ENDFOR»

			}
			
		'''
	
	}
	
	private def operationSplit(List<EOperation> operations){
		//TODO consider return types
		'''
			«operations.get(0).name»(...args:Array<any>):any;
		'''
		
	}
	
	override caseEEnum(EEnum eenum) {
		
		return 
		'''
	    export class «id.doSwitch(eenum)»
	    {
	    	
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				public static readonly «eenumliteral.name.toUpperCase»_VALUE:number = «eenumliteral.value»;
			«ENDFOR»
			
			«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				public static «eenumliteral.name.toUpperCase»:«id.doSwitch(eenum)» = new «id.doSwitch(eenum)»(«eenumliteral.value», "«eenumliteral.name»", "«eenumliteral.literal»");
			«ENDFOR»
	
			private static VALUES_ARRAY:Array<«id.doSwitch(eenum)»> = [
				«FOR EEnumLiteral eenumliteral : eenum.ELiterals SEPARATOR ', '»
					«id.doSwitch(eenum)».«eenumliteral.name.toUpperCase»
				«ENDFOR»
			];
	
	        public static get_string(literal:string):«id.doSwitch(eenum)»
	        {
	            for (let i = 0; i < this.VALUES_ARRAY.length; i++)
	            {
	                let result = this.VALUES_ARRAY[i];
	                if (result.toString() === literal)
	                {
	                    return result;
	                }
	            }
	            return null;
	        }
	
	        public static getByName(name:string):«id.doSwitch(eenum)»
	        {
		        for (let i = 0; i < this.VALUES_ARRAY.length; i++)
		        {
		            let result = this.VALUES_ARRAY[i];
		            if (result.getName()==name)
		            {
		                return result;
		            }
		        }
		        return null;
	        }
	
	        public static get_number(value:number):«id.doSwitch(eenum)»
	        {
	            switch (value)
	            {
				«FOR EEnumLiteral eenumliteral : eenum.ELiterals»
				case this.«eenumliteral.name.toUpperCase»_VALUE: return this.«eenumliteral.name.toUpperCase»;
				«ENDFOR»
	            }
	            return null;
	        }
	
		    private value:number;
		    private name:string;
		    private literal:string;
	
		    private constructor(value:number, name:string, literal:string)
		    {
		        this.value = value;
		        this.name = name;
		        this.literal = literal;
		    }
		
		    public getLiteral():string
		    {
		        return this.literal;
		    }
		
		    public getName():string
		    {
		        return this.name;
		    }
		
		    public getValue():number
		    {
		        return this.value;
		    }
		    
		    public toString():string
		    {
		        return this.literal;
		    }
	    }
		'''
	
	}
	
	override caseEEnumLiteral(EEnumLiteral eenumliteral)'''
	
		«id.doSwitch(eenumliteral)» = «eenumliteral.value»
	'''
	
	override caseEAttribute(EAttribute eattribute){
	
		var listType = tt.listType(eattribute.unique, eattribute.ordered);


		
		'''
		«IF eattribute.many»
			
			«id.doSwitch(eattribute)»:«listType»<«tt.translateType(eattribute.EGenericType)»>;
		«ELSE»
			 «id.doSwitch(eattribute)»:«tt.translateType(eattribute.EGenericType)»;
		«ENDIF»
		'''
	
	}
	

	
	override caseEReference(EReference ereference){
		var listType = tt.listType(ereference.unique, ereference.ordered);
		tt.import_(EcorePackage.eINSTANCE, listType);
		'''
		«IF ereference.containment && ereference.EType?.instanceClassName?.equals("java.util.Map$Entry")»
		«{tt.import_(EcorePackage.eINSTANCE,"EMap")}»
		«id.doSwitch(ereference)»:EMap<«tt.translateType((ereference.EType as EClass).getEStructuralFeature("key").EType)», «tt.translateType((ereference.EType as EClass).getEStructuralFeature("value").EGenericType)»>;
		«ELSEIF ereference.many»
		«id.doSwitch(ereference)»: «listType»<«tt.translateType(ereference.EGenericType)»>;
		«ELSE»
		«id.doSwitch(ereference)»:«tt.translateType(ereference.EGenericType)»;
		«ENDIF»
		'''
	
	
	}
	

	override caseEOperation(EOperation eoperation){
		return caseEOperation(eoperation, false);
	
	}

	
	def caseEOperation(EOperation eoperation, boolean overloaded){
		
		//var name = if (overloaded) eoperation.name+eoperation.EContainingClass.getOperationID(eoperation) else eoperation.name;
		var name = if(overloaded) id.caseOverloadedEOperation(eoperation) else id.doSwitch(eoperation);
		'''
			«name»(«FOR EParameter eparameter:eoperation.EParameters SEPARATOR ', '»«id.doSwitch(eparameter)»:«tt.translateType(eparameter.EGenericType)»«ENDFOR»):«IF eoperation.EType!==null» «tt.translateType(eoperation.EGenericType)» «ELSE» void «ENDIF»;
		'''
	
	}
	


	
}