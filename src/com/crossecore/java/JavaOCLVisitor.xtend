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

import org.eclipse.ocl.ecore.utilities.AbstractVisitor
import org.eclipse.ocl.expressions.IfExp
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.ocl.expressions.StringLiteralExp
import org.eclipse.ocl.expressions.BooleanLiteralExp
import org.eclipse.ocl.expressions.IntegerLiteralExp
import org.eclipse.ocl.expressions.RealLiteralExp
import java.util.List
import org.eclipse.ocl.expressions.OperationCallExp
import org.eclipse.emf.ecore.EOperation
import org.eclipse.ocl.expressions.NullLiteralExp
import org.eclipse.ocl.expressions.VariableExp
import org.eclipse.emf.ecore.EParameter
import org.eclipse.ocl.expressions.PropertyCallExp
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EPackage
import org.eclipse.ocl.expressions.IteratorExp
import org.eclipse.ocl.expressions.Variable
import org.eclipse.ocl.expressions.LetExp
import org.eclipse.emf.ecore.EDataType
import com.crossecore.TypeTranslator
import org.eclipse.ocl.expressions.CollectionLiteralExp
import org.eclipse.ocl.expressions.CollectionLiteralPart
import org.eclipse.ocl.ecore.impl.CollectionLiteralExpImpl
import org.eclipse.ocl.ecore.CollectionType
import org.eclipse.ocl.ecore.CollectionItem
import org.eclipse.ocl.expressions.TypeExp
import org.eclipse.ocl.expressions.TupleLiteralExp
import org.eclipse.ocl.expressions.TupleLiteralPart
import org.eclipse.emf.ecore.ETypedElement
import org.eclipse.ocl.expressions.CollectionRange
import org.eclipse.ocl.expressions.UnlimitedNaturalLiteralExp
import org.eclipse.ocl.ecore.OCL
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.ocl.ecore.delegate.OCLDelegateDomain
import org.eclipse.ocl.xtext.essentialocl.EssentialOCLStandaloneSetup
import com.crossecore.IdentifierProvider

class JavaOCLVisitor extends AbstractVisitor<CharSequence>{
	private TypeTranslator t = JavaTypeTranslator.INSTANCE;
	private IdentifierProvider id = new JavaIdentifier();
	

	public def String translate(String expression, EClassifier context){
		var rs = new ResourceSetImpl();
		
		OCL.initialize(rs);
		OCLDelegateDomain.initialize(rs);
		org.eclipse.ocl.pivot.internal.resource.StandaloneProjectMap.getAdapter(rs);

		EssentialOCLStandaloneSetup.doSetup();

		
		var ocl = org.eclipse.ocl.ecore.OCL.newInstance();
		var helper = ocl.createOCLHelper();
		
		helper.setContext(context);
		
		
		var oclExp = helper.createQuery(expression);
		
		return oclExp.accept(this).toString;
		
	}
	

    override CharSequence handleCollectionRange(CollectionRange<EClassifier> range, CharSequence firstResult,
            CharSequence lastResult) {
        
        var buffer = new StringBuffer();
        
        if(range.first instanceof IntegerLiteralExp && range.last instanceof IntegerLiteralExp){
        	
        	var lower = Integer.parseInt(firstResult+"");
        	var upper = Integer.parseInt(lastResult+"");
        	
        	if(lower<=upper){
        		
        		       		
        		for(var i=lower;i<=upper;i++){
        			buffer.append(i);
        			
        			if(i+1<=upper){
        				buffer.append(",");
        			}	
        		}
        	}
        }
        
        return buffer.toString;

    }

	override CharSequence handleTupleLiteralExp(TupleLiteralExp<EClassifier, EStructuralFeature> literalExp,
            List<CharSequence> partResults) {
        
        
        var firstPart = literalExp.part.get(0) as ETypedElement;
        var secondPart = literalExp.part.get(1) as ETypedElement;
        
        var firstPart2 = literalExp.part.get(0) as TupleLiteralPart<EClassifier, EStructuralFeature>;
        var secondPart2 = literalExp.part.get(1) as TupleLiteralPart<EClassifier, EStructuralFeature>;
        
        var firstType = t.translateType(firstPart.EGenericType);
        var secondType = t.translateType(secondPart.EGenericType);
        
        var firstValue = firstPart2.value.accept(this);
        var secondValue = secondPart2.value.accept(this);
            	
        return '''new Tuple<«firstType», «secondType»>(«firstValue», «secondValue»)''';
    }

	
	override CharSequence visitTypeExp(TypeExp<EClassifier> type) {
		
		return '''«t.translateType(type.referredType)»''';
		
		
	}
    override CharSequence visitUnlimitedNaturalLiteralExp(UnlimitedNaturalLiteralExp<EClassifier> literalExp) {
        return 'UnlimitedNatural.UNLIMITED'
    }
	
	override CharSequence handleCollectionLiteralExp(CollectionLiteralExp<EClassifier> literalExp,
            List<CharSequence> partResults) {
        
         	
        var collectionLiteral = literalExp as CollectionLiteralExpImpl;
        var kind = literalExp.kind;
        var collectionType = collectionLiteral.EGenericType.EClassifier as CollectionType;//e.g. SequenceType
        var elementType = collectionType.elementType;
        var type = "";
        
        //TODO move to TypeTranslator
		/*
		if(elementType.eContainer instanceof EPackage && (elementType.eContainer as EPackage).nsURI != null &&
			(elementType.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
			&& elementType instanceof AnyType
		){
			
			type = "object"
		}
		else{
			type = t.mapPrimitiveType(elementType as EDataType);	
		}
		*/
		
		type = t.translateType(collectionLiteral.EGenericType);
            	
        
        
        return 
        '''
        new «type»{
        	«FOR CollectionLiteralPart<EClassifier> part: literalExp.part SEPARATOR ', '»
        		«IF part instanceof CollectionItem»
	        		«(part as CollectionItem).item.accept(this)»
        		«ELSEIF part instanceof CollectionRange»
        			«visitCollectionRange(part as CollectionRange)»
        		«ENDIF»
        		
        		
        		
        	«ENDFOR»
        }
        ''';
    }

	
    override CharSequence handleLetExp(LetExp<EClassifier, EParameter> letExp, CharSequence variableResult, CharSequence inResult) {


		if(letExp.eContainer instanceof LetExp == false && letExp.in instanceof LetExp ==false){
			//case: root and sink at same time

			return
			'''
	        ((Func<«t.mapDataType(letExp.type as EDataType)»>)(() => { var «letExp.variable.name» = «letExp.variable.initExpression.accept(this)»; return «inResult»; }))();
	        '''
		}
		else if(letExp.eContainer instanceof LetExp == false && letExp.in instanceof LetExp){
			//case: root and nested LetExp
			
			return
			'''
	        ((Func<«t.mapDataType(letExp.type as EDataType)»>)(() => { var «letExp.variable.name» = «letExp.variable.initExpression.accept(this)»; «letExp.in.accept(this)»}))();
	        '''
		}
		else if(letExp.in instanceof LetExp){
			//case: nested LetExp
			return '''var «letExp.variable.name» = «letExp.variable.initExpression.accept(this)»;''' + letExp.in.accept(this).toString;
		}
		else{
			//case: sink of nested LetExp
			return '''var «letExp.variable.name» = «letExp.variable.initExpression.accept(this)»; return «inResult»;'''
		}
		


    }	
	
	override def handleIfExp(IfExp<EClassifier> ifExp, CharSequence conditionResult, CharSequence thenResult,
            CharSequence elseResult) {
    
    	return '''«conditionResult» ? «thenResult» : «elseResult»'''
		       	
   	}
   	
   	override CharSequence handleOperationCallExp(OperationCallExp<EClassifier, EOperation> callExp,
            CharSequence sourceResult, List<CharSequence> argumentResults) {
        
        var operation = callExp.referredOperation;
        
        var isOclstdlib = false;
        
        if(operation!==null && 
        	operation.eContainer !==null && 
        	operation.eContainer.eContainer!==null &&
        	operation.eContainer.eContainer instanceof EPackage &&
        	(operation.eContainer.eContainer as EPackage).nsURI.equals("http://www.eclipse.org/ocl/1.1.0/oclstdlib.ecore")
        ){
        	isOclstdlib = true;	
        }
        
        
                
        if(isOclstdlib){
        	
        	var op = callExp.referredOperation;
        	var c = op.EContainingClass;
        	var n = c.name;
        	
        	if(callExp.referredOperation.EContainingClass.name.equals("Boolean_Class")){
        		
        		if(callExp.referredOperation.name.equals("<>")){
        			return '''«sourceResult» != «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("=")){
					return '''«sourceResult» == «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("and")){
					return '''«sourceResult» && «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("implies")){
					return '''!(«sourceResult») || «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("not")){
					return '''! «sourceResult»''';
				}
				else if(callExp.referredOperation.name.equals("or")){
					return '''«sourceResult» || «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("xor")){
					return '''«sourceResult» ^ «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("toString")){
					return '''«sourceResult».toString()'''
				}
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("Integer_Class")){
        		
        		if(callExp.referredOperation.name.equals("*")){
        			return '''«sourceResult» * «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("+")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';	
        		}
        		//- can also be prefix operator for negative literals
        		else if(callExp.referredOperation.name.equals("-")){
        			return '''«sourceResult» - «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("<")){
        			return '''«sourceResult» < «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals(">")){
        			return '''«sourceResult» > «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals(">=")){
        			return '''«sourceResult» >= «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("<=")){
        			return '''«sourceResult» <= «argumentResults.get(0)»''';	
        		}
        		//casting of return value required?
        		else if(callExp.referredOperation.name.equals("/")){
        			return '''(double) «sourceResult» / (double) «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("abs")){
        			return '''Math.abs(«sourceResult»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("div")){
        			return '''«sourceResult» / «argumentResults.get(0)»''';			
        		}
        		else if(callExp.referredOperation.name.equals("max")){
        			return '''Math.max(«sourceResult», «argumentResults.get(0)»)''';		
        		}
        		else if(callExp.referredOperation.name.equals("min")){
        			return '''Math.min(«sourceResult», «argumentResults.get(0)»)''';		
        		}
        		else if(callExp.referredOperation.name.equals("mod")){
        			return '''«sourceResult» % «argumentResults.get(0)»''';		
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			return '''«sourceResult».toString()''';		
        		}
        		else if(callExp.referredOperation.name.equals("toUnlimitedNatural")){
        			throw new UnsupportedOperationException();		
        		}
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("EDate")){
        		if(callExp.referredOperation.name.equals("<")){
        			return '''«sourceResult».compareTo(«argumentResults.get(0)»)>0''';		
        		}
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("Real_Class")){
        		if(callExp.referredOperation.name.equals("*")){
        			return '''«sourceResult» * «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("+")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("-")){
        			return '''«sourceResult» - «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("/")){
        			return '''«sourceResult» / «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("<>")){
        			return '''«sourceResult» != «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("=")){
        			return '''«sourceResult» == «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("<")){
        			return '''«sourceResult» < «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals(">")){
        			return '''«sourceResult» > «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals(">=")){
        			return '''«sourceResult» >= «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("<=")){
        			return '''«sourceResult» <= «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("abs")){
        			return '''Math.abs(«sourceResult»)''';
        		}
        		else if(callExp.referredOperation.name.equals("floor")){
        			return '''Math.floor(«sourceResult»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("max")){
        			return '''Math.max(«sourceResult», «argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("min")){
        			return '''Math.min(«sourceResult», «argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("round")){
        			return '''Math.round(«sourceResult», «argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			return '''«sourceResult».toString()''';	
        		}   
        		         		
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("String_Class")){
        		if(callExp.referredOperation.name.equals("+")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';		
        		} 
        		else if(callExp.referredOperation.name.equals("<")){
        			//return '''«sourceResult» < «argumentResults.get(0)»''';
        			return '''«sourceResult».compareTo(«argumentResults.get(0)») < 0''';			
        		} 
        		else if(callExp.referredOperation.name.equals("<=")){
        			//return '''«sourceResult» <= «argumentResults.get(0)»''';
        			return '''«sourceResult».compareTo(«argumentResults.get(0)») <= 0''';		
        		}
        		else if(callExp.referredOperation.name.equals("<>")){
        			return '''«sourceResult» != «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("=")){
        			return '''«sourceResult».equals(«argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals(">")){
        			//return '''«sourceResult» > «argumentResults.get(0)»''';	
        			return '''«sourceResult».compareTo(«argumentResults.get(0)») > 0''';
        		}
        		else if(callExp.referredOperation.name.equals(">=")){
        			//return '''«sourceResult» >= «argumentResults.get(0)»''';
        			return '''«sourceResult».compareTo(«argumentResults.get(0)») >= 0''';	
        		}
        		else if(callExp.referredOperation.name.equals("at")){
        			return '''«sourceResult»[«argumentResults.get(0)»]+""''';	
        		}
        		else if(callExp.referredOperation.name.equals("characters")){
        			throw new UnsupportedOperationException();	
        		}
        		else if(callExp.referredOperation.name.equals("compareTo")){
        			return '''«sourceResult».compareTo(«argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("concat")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';
        		}
        		else if(callExp.referredOperation.name.equals("equalsIgnoreCase")){
        			
        			return '''«sourceResult».compareToIgnoreCase(«argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("indexOf")){
        			return '''«sourceResult».indexOf(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("lastIndexOf")){
        			return '''«sourceResult».lastIndexOf(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("matches")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("replaceAll")){
        			return '''«sourceResult».replaceAll(«argumentResults.get(0)», «argumentResults.get(1)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("replaceFirst")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("size")){
        			return '''«sourceResult».length()''';
        		}
        		else if(callExp.referredOperation.name.equals("startsWith")){
        			return '''«sourceResult».startsWith(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("substituteAll")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("substituteFirst")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("substring")){
        			return '''«sourceResult».substring(«argumentResults.get(0)», «argumentResults.get(1)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("toBoolean")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toInteger")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toLower")){
        			return '''«sourceResult».toLower()''';
        		}
        		else if(callExp.referredOperation.name.equals("toReal")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toUpper")){
        			return '''«sourceResult».toUpper()''';
        		}
        		else if(callExp.referredOperation.name.equals("toUpperCase")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("tokenize")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("trim")){
        			throw new UnsupportedOperationException();
        		}    
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("OclAny_Class")){
        		if(callExp.referredOperation.name.equals("<>")){
					return '''«sourceResult» != «argumentResults.get(0)»''';	
				}
				else if(callExp.referredOperation.name.equals("=")){
					return '''«sourceResult» == «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("oclIsUndefined")){
					return '''«sourceResult» != null''';
				}
				else if(callExp.referredOperation.name.equals("oclIsKindOf")){
					return '''«sourceResult» instanceof «argumentResults.get(0)»''';
				}
				else if(callExp.referredOperation.name.equals("oclIsTypeOf")){
					return '''«sourceResult».getClass().equals(«argumentResults.get(0)».class)''';
				}
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("OclType_Class")){
        		 if(callExp.referredOperation.name.equals("allInstances")){
					return '''«sourceResult».allInstances''';	
				}
        	}
        	else if(#{"selectByKind", "selectByType"}.contains(callExp.referredOperation.name)
        		&& #{"Sequence(T)_Class", "OrderedSet(T)_Class", "Set(T)_Class", "Bag(T)_Class"}.contains(callExp.referredOperation.EContainingClass.name)
        	){
        		
    	        var typedelement = callExp as ETypedElement;
    			var generictype = typedelement.EGenericType
    			var elementtype = (generictype.ERawType as CollectionType).elementType;
    			
    			var primitiveType = t.mapPrimitiveType(elementtype as EDataType)
    			return '''«sourceResult».«callExp.referredOperation.name»<«primitiveType»>()''';		
        	}

        	
        	/*
        	else if(callExp.referredOperation.EContainingClass.name.equals("Sequence(T)_Class")){
        		if(callExp.referredOperation.name.equals("selectByKind")){
        			
        			//TODO support complex types
        			var typedelement = callExp as ETypedElement;
        			var generictype = typedelement.EGenericType
        			var elementtype = (generictype.ERawType as CollectionType).elementType;
        			
        			var primitiveType = t.mapPrimitiveType(elementtype as EDataType)
        			return '''«sourceResult».selectByKind<«primitiveType»>()''';		
        		}
        		else if(callExp.referredOperation.name.equals("selectByType")){
        			
        			//TODO support complex types
        			var typedelement = callExp as ETypedElement;
        			var generictype = typedelement.EGenericType
        			var elementtype = (generictype.ERawType as CollectionType).elementType;
        			
        			var primitiveType = t.mapPrimitiveType(elementtype as EDataType)
        			return '''«sourceResult».selectByType<«primitiveType»>()''';		
        		} 
        		
        	}
        	*/


        }
		return '''«sourceResult».«callExp.referredOperation.name»(«FOR CharSequence arg:argumentResults SEPARATOR ','»«arg»«ENDFOR»)''';
        
       		
        
        
        
    }
    
    override CharSequence handleIteratorExp(IteratorExp<EClassifier, EParameter> callExp,
            CharSequence sourceResult, List<CharSequence> variableResults, CharSequence bodyResult) {
        return '''«sourceResult».«callExp.name»(«variableResults.get(0)» -> «bodyResult»)''';
    }
    
    override CharSequence handlePropertyCallExp(PropertyCallExp<EClassifier, EStructuralFeature> callExp,
            CharSequence sourceResult, List<CharSequence> qualifierResults) {
        return '''«sourceResult».«id.getEStructuralFeature(callExp.referredProperty)»()''';
    }
    
    override CharSequence handleVariable(Variable<EClassifier, EParameter> variable,
            CharSequence initResult) {
        return variable.name;
    }
    
    override CharSequence visitVariableExp(VariableExp<EClassifier, EParameter> v) {
		
		if(v.name.equals("self")){
			
			return "this";
		}
		
		return v.name;
	}
    
    
   	
	override CharSequence visitStringLiteralExp(StringLiteralExp<EClassifier> literalExp) {
		
		return "\""+ literalExp.stringSymbol +"\"";
	}
	
	override CharSequence visitBooleanLiteralExp(BooleanLiteralExp<EClassifier> literalExp) {
		
		return if(literalExp.booleanSymbol) "true" else "false";
	}
	
	override CharSequence visitIntegerLiteralExp(IntegerLiteralExp<EClassifier> literalExp) {
		
		return literalExp.integerSymbol+"";
	}
	
	override CharSequence visitRealLiteralExp(RealLiteralExp<EClassifier> literalExp) {
		
		return literalExp.realSymbol+"";
	}
	
	override CharSequence visitNullLiteralExp(NullLiteralExp<EClassifier> literalExp) {
		
		return "null";
	}
   	
   	
}