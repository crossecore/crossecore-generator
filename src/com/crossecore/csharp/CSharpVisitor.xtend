package com.crossecore.csharp

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EPackage

abstract class CSharpVisitor extends EcoreVisitor {
	


	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	/*
	override def String translateType(EGenericType type){
		
		if(type==null){
			return "void";
		}
		
		var result = new StringBuffer();
		

		if(type.EClassifier != null){
					
			if(type.EClassifier.name == EcorePackage.Literals.EJAVA_CLASS.name){
				return "Type";
			}
			else if(type.EClassifier instanceof EDataType){
				
				result.append(mapDataType(type.EClassifier as EDataType));
			}
			else{
				result.append(type.EClassifier.name)	
			}
			
			result.append('''«FOR EGenericType argument: type.ETypeArguments BEFORE '<' SEPARATOR ',' AFTER '>'»«translateType(argument)»«ENDFOR»''');


		}
		else if(type.ETypeParameter!=null){
			result.append(type.ETypeParameter.name)	
		}
		else{
			result.append("object");
		}
	
		
		return result.toString;


	}
	* */
	
	

	
}