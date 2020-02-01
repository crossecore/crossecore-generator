package com.crossecore.java

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.util.EcoreUtil
import com.crossecore.EcoreVisitor

class GradleGenerator extends EcoreVisitor{
	
	private IdentifierProvider id = new JavaIdentifier();
	
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage){

		'''
		apply plugin: 'java'
		
		sourceSets {
		    main {
		        java {
		            srcDir '.'
		        }
		    }
		}
		
		repositories.jcenter()
		
		dependencies {
			compile group: 'org.eclipse.emf', name: 'org.eclipse.emf.ecore', version: '2.18.0'
			compile group: 'org.eclipse.emf', name: 'org.eclipse.emf.ecore.xmi', version: '2.16.0'
		}
		'''
	}
	
	
}