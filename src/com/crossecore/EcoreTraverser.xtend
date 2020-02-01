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