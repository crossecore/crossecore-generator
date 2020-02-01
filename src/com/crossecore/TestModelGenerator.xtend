package com.crossecore

import org.eclipse.emf.ecore.EDataType
import java.util.HashSet
import java.util.Set
import java.util.List
import java.util.Map
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EObject
import java.util.Collections
import org.eclipse.emf.ecore.EReference
import org.eclipse.ocl.ecore.EcoreEvaluationEnvironment
import org.eclipse.emf.ecore.util.EcoreValidator

class TestModelGenerator {
	
	
	private final Set<EDataType> VARIABLE_ECORE_EDATATYPES = #{};
	
	private static int combins =1;
	
	/*
	
	private static List<? extends Pair<String, ? extends List<? extends Comparable<?>>>> variables;
	
	static def void x(int i, Map<String, Object> vector){
		
		if(i == variables.size){
			System.out.println('''property «name(vector)» : MyClass[1..«vector.get("upperBound")»|1] { «IF vector.get("readonly")==true»readonly«ENDIF» «IF vector.get("composes")==true»composes«ENDIF» «IF vector.get("derived")==true»derived«ENDIF» «IF vector.get("ordered")==true»ordered«ENDIF» «IF vector.get("transient")==true»transient«ENDIF» «IF vector.get("unique")==true»unique«ENDIF» «IF vector.get("unsettable")==true»unsettable«ENDIF» «IF vector.get("volatile")==true»volatile«ENDIF»};''');

		}
		
		else if(i<variables.size){
			
			for(Object value:variables.get(i).value as Collection<Object>){
				
				
				vector.put(variables.get(i).key, value);
				
				x(i+1, vector);
			}
		}
		
	}
	
	*/
	
	private static def name(Map<String, Object> vector){
		
		var sb = new ArrayList();
		
		
		if(vector.get("readonly")==true){
			sb.add("readonly")
		}
		
		if(vector.get("composes")==true){
			sb.add("composes")
		}
		
		if(vector.get("derived")==true){
			sb.add("derived")
		}
		
		if(vector.get("upperBound").equals("*")){
			sb.add("many")
		}
		else{
			sb.add("single")
		}
		
		if(vector.get("ordered")==true){
			sb.add("ordered")
		}
		
		if(vector.get("transient")==true){
			sb.add("transient")
		}
		
		if(vector.get("unique")==true){
			sb.add("unique")
		}
		
		if(vector.get("unsettable")==true){
			sb.add("unsettable")
		}
		
		if(vector.get("volatile")==true){
			sb.add("volatile")
		}
		
		var result = new StringBuffer();
		for(var iter=sb.iterator;iter.hasNext;){
			
			var next = iter.next();
			
			result.append(next);
			
			if(iter.hasNext){
				result.append("_");
			}
		}
		
		return result.toString;

		
		
	}
	
	public static def void main(String[] args){
		


		
		//x(0, new HashMap<String, Object>());
		//y();
		
		new TestModelGenerator().traverse(EcorePackage.eINSTANCE);

	}
	
	private EFactory factory = EcoreFactory.eINSTANCE;
	private HashMap<EClassifier, List<EObject>> domains = new HashMap<EClassifier, List<EObject>>();
	private int nodes = 0;
	private int links = 0;
	private EcoreValidator ecoreValidator = new EcoreValidator();
	
	public def combinations(EClass eclass){
		
		var result = new ArrayList<EObject>();
		var eobject = factory.create(eclass);
		
		//TODO room for optimization: just need to check EAttributes if supertypes are no abstract classes, interfaces
		var featuresToTest = eclass.EAllAttributes.filter[f|!f.derived && f.changeable];
		for(feature:featuresToTest){
			//TODO multivalued
			for(value:getDomain(feature)){
				eobject = EcoreUtil.copy(eobject);
				eobject.eSet(feature, value);
				
				if(!ecoreValidator.validate(eobject, null, null)){
					System.exit(-1);
				}
				nodes++;
				System.out.println(eobject);
				result.add(eobject);
				
			}	
		}
		
		domains.put(eclass, result);
		
		return result;
	}
	
	public def traverse(EPackage epackage){
		
		var eclassifiers = epackage.EClassifiers.filter[e|e instanceof EClass && !(e as EClass).interface && !(e as EClass).abstract]
		
		for(EClassifier eClassifier:eclassifiers){
			if(eClassifier instanceof EClass){
				
				combinations(eClassifier);
			}
		}
		
		for(EClassifier eClassifier:epackage.EClassifiers){
			if(eClassifier instanceof EClass){
				
				
				if(domains.containsKey(eClassifier)){
						
						var eobjects = domains.get(eClassifier);
						
						for(eobject:eobjects){
							
							var featuresToTest = eClassifier.EReferences.filter[f|!f.derived && f.changeable];
							
							
							for(feature:featuresToTest){
						
								//TODO safe cast?
								for(value:getClosure(feature.EType as EClass)){
									
									if(feature.many){
										
									}
									else{
										var eobject_ = EcoreUtil.copy(eobject);
										eobject_.eSet(feature, value);
										if(!ecoreValidator.validate(eobject_, null, null)){
											System.exit(-1);
										}	
										links++;	
										System.out.println(eobject_);
									}					
								}
			
							}
							
						}	
						
					}
				
			}
		}
		System.out.println('''Nodes: «nodes», Links: «links»''');
		
		
	}
	
	public def getClosure(EClass e){
		
		var result = new ArrayList<EObject>();
		var eclasses = Utils.getSubclasses(e);
		eclasses.add(e);
		
		for(EClass ex : eclasses){
			if(domains.containsKey(ex)){
				
				result.addAll(domains.get(ex));
			}
		}
		return result;
	}
	
	public def List<Object> getDomain(EStructuralFeature attribute){
		
		switch(attribute.EType.name){
			case "EBoolean": return #[false, true]
			case "EInt": return #[-1, 0, 1, 2]
			
		}
		


		
		return Collections.EMPTY_LIST;
	}
	
	


	
	public static def y(){
		
		var edatatypes = EcorePackage.eINSTANCE.EClassifiers.filter[e|e instanceof EDataType].map[e| e as EDataType];
		for(EDataType e : edatatypes){
			System.out.println('''attribute ecore_«e.name.toLowerCase»_single : ecore::«e.name»[?] «IF !e.serializable»{transient}«ENDIF»;''');
			System.out.println('''attribute ecore_«e.name.toLowerCase»_multi : ecore::«e.name»[*] «IF !e.serializable»{transient}«ENDIF»;''');
			System.out.println('''operation operation_«e.name.toLowerCase»() : ecore::«e.name»[?];''');
		}
	}
	
}