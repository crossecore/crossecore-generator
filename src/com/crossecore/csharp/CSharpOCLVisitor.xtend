package com.crossecore.csharp

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

class CSharpOCLVisitor extends AbstractVisitor<CharSequence>{
	private TypeTranslator t = CSharpTypeTranslator.INSTANCE;
	
	

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
		
		if(type.referredType instanceof EDataType){
			
			return '''typeof(«t.mapPrimitiveType(type.referredType as EDataType)»)''';
		}
		else{
			//TODO test this:
			//TODO is if-else necessary?
			return '''typeof(«t.translateType(type.referredType)»)''';
		}
		
		
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
        
        if(operation!=null && 
        	operation.eContainer !=null && 
        	operation.eContainer.eContainer!=null &&
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
					return '''! «sourceResult» || «argumentResults.get(0)»''';
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
					return '''«sourceResult».ToString()'''
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
        			return '''«sourceResult» as double / «argumentResults.get(0)» as double''';	
        		}
        		else if(callExp.referredOperation.name.equals("abs")){
        			return '''Math.Abs(«sourceResult»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("div")){
        			return '''«sourceResult» / «argumentResults.get(0)»''';			
        		}
        		else if(callExp.referredOperation.name.equals("max")){
        			return '''Math.Max(«sourceResult», «argumentResults.get(0)»)''';		
        		}
        		else if(callExp.referredOperation.name.equals("min")){
        			return '''Math.Min(«sourceResult», «argumentResults.get(0)»)''';		
        		}
        		else if(callExp.referredOperation.name.equals("mod")){
        			return '''«sourceResult» % «argumentResults.get(0)»''';		
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			return '''«sourceResult».ToString()''';		
        		}
        		else if(callExp.referredOperation.name.equals("toUnlimitedNatural")){
        			throw new UnsupportedOperationException();		
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
        			return '''Math.Abs(«sourceResult»)''';
        		}
        		else if(callExp.referredOperation.name.equals("floor")){
        			return '''Math.Floor(«sourceResult»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("max")){
        			return '''Math.Max(«sourceResult», «argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("min")){
        			return '''Math.Min(«sourceResult», «argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("round")){
        			return '''Math.Round(«sourceResult», «argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			return '''«sourceResult».ToString()''';	
        		}   
        		         		
        	}
        	else if(callExp.referredOperation.EContainingClass.name.equals("String_Class")){
        		if(callExp.referredOperation.name.equals("+")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';		
        		} 
        		else if(callExp.referredOperation.name.equals("<")){
        			//return '''«sourceResult» < «argumentResults.get(0)»''';
        			return '''«sourceResult».CompareTo(«argumentResults.get(0)») < 0''';			
        		} 
        		else if(callExp.referredOperation.name.equals("<=")){
        			//return '''«sourceResult» <= «argumentResults.get(0)»''';
        			return '''«sourceResult».CompareTo(«argumentResults.get(0)») <= 0''';		
        		}
        		else if(callExp.referredOperation.name.equals("<>")){
        			return '''«sourceResult» != «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals("=")){
        			return '''«sourceResult» == «argumentResults.get(0)»''';	
        		}
        		else if(callExp.referredOperation.name.equals(">")){
        			//return '''«sourceResult» > «argumentResults.get(0)»''';	
        			return '''«sourceResult».CompareTo(«argumentResults.get(0)») > 0''';
        		}
        		else if(callExp.referredOperation.name.equals(">=")){
        			//return '''«sourceResult» >= «argumentResults.get(0)»''';
        			return '''«sourceResult».CompareTo(«argumentResults.get(0)») >= 0''';	
        		}
        		else if(callExp.referredOperation.name.equals("at")){
        			return '''«sourceResult»[«argumentResults.get(0)»]+""''';	
        		}
        		else if(callExp.referredOperation.name.equals("characters")){
        			throw new UnsupportedOperationException();	
        		}
        		else if(callExp.referredOperation.name.equals("compareTo")){
        			return '''«sourceResult».Compare(«argumentResults.get(0)»)''';	
        		}
        		else if(callExp.referredOperation.name.equals("concat")){
        			return '''«sourceResult» + «argumentResults.get(0)»''';
        		}
        		else if(callExp.referredOperation.name.equals("equalsIgnoreCase")){
        			
        			return '''String.Equals(«sourceResult», «argumentResults.get(0)», StringComparison.OrdinalIgnoreCase)''';
        		}
        		else if(callExp.referredOperation.name.equals("indexOf")){
        			return '''«sourceResult».IndexOf(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("lastIndexOf")){
        			return '''«sourceResult».LastIndexOf(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("matches")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("replaceAll")){
        			return '''«sourceResult».Replace(«argumentResults.get(0)», «argumentResults.get(1)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("replaceFirst")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("size")){
        			return '''«sourceResult».Count()''';
        		}
        		else if(callExp.referredOperation.name.equals("startsWith")){
        			return '''«sourceResult».StartsWith(«argumentResults.get(0)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("substituteAll")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("substituteFirst")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("substring")){
        			return '''«sourceResult».Substring(«argumentResults.get(0)», «argumentResults.get(1)»)''';
        		}
        		else if(callExp.referredOperation.name.equals("toBoolean")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toInteger")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toLower")){
        			return '''«sourceResult».ToLower()''';
        		}
        		else if(callExp.referredOperation.name.equals("toReal")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toString")){
        			throw new UnsupportedOperationException();
        		}
        		else if(callExp.referredOperation.name.equals("toUpper")){
        			return '''«sourceResult».ToUpper()''';
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
        return '''«sourceResult».«callExp.name»(«variableResults.get(0)» => «bodyResult»)''';
    }
    
    override CharSequence handlePropertyCallExp(PropertyCallExp<EClassifier, EStructuralFeature> callExp,
            CharSequence sourceResult, List<CharSequence> qualifierResults) {
        return '''«sourceResult».«callExp.referredProperty.name»''';
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