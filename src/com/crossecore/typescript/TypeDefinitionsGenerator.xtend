package com.crossecore.typescript;

import com.crossecore.DependencyManager
import java.util.Collection
import java.util.HashSet
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage

class TypeDefintionsGenerator extends TypeScriptVisitor{ 
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	override caseEPackage(EPackage epackage) {
		var List<EClass> sortedEClasses = DependencyManager.sortEClasses(epackage);
		var Collection<EClassifier> eclassifiers = new HashSet<EClassifier>(epackage.EClassifiers);
		eclassifiers.removeAll(sortedEClasses);
		
		/*
		for(EClass classifier: sortedEClasses){
			var contents = 	
			'''
			«preamble»
		 	«IF !Utils.isEcoreEPackage(epackage)»
			import EObject = Ecore.EObject;
		 	«ENDIF»
			namespace «id.doSwitch(epackage)»{
			
				«doSwitch(classifier)»
			}
			'''
			
		}
		*/
		
		var contents = 
		'''
		namespace «id.doSwitch(epackage)»{
			«FOR EClass eclass : sortedEClasses»
				«doSwitch(eclass)»
			«ENDFOR»
		}
		''';
		
		///<reference path="./Notification.ts" />
		
		contents = 
			'''
			«FOR EClass eclass : sortedEClasses»
				///<reference path="./«id.doSwitch(eclass)».ts" />
				///<reference path="./«id.EClassBase(eclass)».ts" />
				///<reference path="./«id.EClassImpl(eclass)».ts" />
			«ENDFOR»
			///<reference path="./«id.EPackageFactory(epackage)».ts" />
			///<reference path="./«id.EPackageFactoryImpl(epackage)».ts" />
			///<reference path="./«id.EPackagePackage(epackage)».ts" />
			///<reference path="./«id.EPackagePackageImpl(epackage)».ts" />
			///<reference path="./«id.EPackageSwitch(epackage)».ts" />
			///<reference path="./AbstractCollection.ts" />
			///<reference path="./Adapter.ts" />
			///<reference path="./ArrayList.ts" />
			///<reference path="./BasicEObjectImpl.ts" />
			///<reference path="./BasicNotifierImpl.ts" />
			///<reference path="./Collection.ts" />
			///<reference path="./InternalEObject.ts" />
			///<reference path="./List.ts" />
			///<reference path="./Notification.ts" />
			///<reference path="./NotificationChain.ts" />
			///<reference path="./NotificationImpl.ts" />
			///<reference path="./Notifier.ts" />
			///<reference path="./NotifyingList.ts" />
			///<reference path="./OrderedSet.ts" />
			///<reference path="./Resource.ts" />
			///<reference path="./Switch.ts" />
			///<reference path="./TreeIterator.ts" />
			///<reference path="./EcoreEList.ts" />
			''';
		
		
	
		return contents;
	
	}
	
}