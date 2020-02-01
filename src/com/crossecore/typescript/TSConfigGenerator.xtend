package com.crossecore.typescript;

import org.eclipse.emf.ecore.EPackage

class TSConfigGenerator extends TypeScriptVisitor{
	
	
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
		  "compileOnSave": false,
		  "compilerOptions": {
		    "baseUrl": "./",
		    "outDir": "./dist/out-tsc",
		    "sourceMap": true,
		    "declaration": false,
		    "module": "es2015",
		    "moduleResolution": "node",
		    "emitDecoratorMetadata": true,
		    "experimentalDecorators": true,
		    "target": "es5",
		    "typeRoots": [
		      "node_modules/@types"
		    ],
		    "lib": [
		      "es2017",
		      "dom"
		    ]
		  },
		  "exclude": [
		    "node_modules"
		  ]
		}
		'''
	}
	

}