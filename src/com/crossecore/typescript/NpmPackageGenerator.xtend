package com.crossecore.typescript;

import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EEnum
import com.crossecore.IdentifierProvider
import com.crossecore.DependencyManager
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EcorePackage
import com.crossecore.Utils
import com.crossecore.ImportManager
import com.crossecore.TypeTranslator
import java.util.ArrayList

class NpmPackageGenerator extends TypeScriptVisitor{
	
	private TypeScriptIdentifier id = new TypeScriptIdentifier();
	private TypeTranslator t = new TypeScriptTypeTranslator(id);
	private ImportManager imports = new ImportManager(t);
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	override caseEPackage(EPackage epackage){
		
		return 
		'''
		{
		  "name": "«epackage.name»",
		  "version": "1.0.0",
		  "scripts": {
		    "build": "tsc -p .",
		    "test": "jest"
		  },
		  "private": true,
		  "dependencies": {
		  },
		  "devDependencies": {
		    "typescript": "~3.5.2",
		  	"jest": "^24.8.0"
		  }
		}
		'''

	}
	

}