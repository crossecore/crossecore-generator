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
package com.crossecore;

import com.crossecore.csharp.FactoryGenerator
import com.crossecore.csharp.FactoryImplGenerator
import com.crossecore.csharp.ModelBaseGenerator
import com.crossecore.csharp.ModelGenerator
import com.crossecore.csharp.ModelImplGenerator
import com.crossecore.csharp.PackageGenerator
import com.crossecore.csharp.PackageImplGenerator
import com.crossecore.csharp.SwitchGenerator
import com.crossecore.csharp.ValidatorGenerator
import com.crossecore.docs.HtmlVisitor
import java.io.File
import java.util.ArrayList
import org.apache.commons.cli.DefaultParser
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.Option
import org.apache.commons.cli.Options
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import com.crossecore.csharp.VisualStudioProjectGenerator
import org.apache.log4j.Logger
import org.apache.log4j.LogManager
import org.eclipse.emf.ecore.util.EcoreValidator
import org.eclipse.emf.ecore.util.Diagnostician

class CrossEcore {
	
	static boolean generateDocumentation = true;
	
	static final Logger logger = LogManager.getLogger(CrossEcore);
	
	
	static def main(String[] args){
		
		

		var options = new Options();
		
                                
		var ecorefile = Option.builder("e")
		     .required(true)
		     .hasArg()
		     .argName("file")
		     .desc("source file (.ecore)")
		     .build();                  
		
		var language = Option.builder("L")
				     .required(true)
				     .hasArg()
				     .argName("language")
				     .desc("target programming language. Valid values are typescript, csharp, java, swift.")
				     .build();
		
		var path =  Option.builder("p")
				     .required(true)
				     .hasArg()
				     .argName("directory")
				     .desc("target path")
				     .build();
				     
	    var documentation =  Option.builder("d")
						     .required(false)
						     .hasArg()
						     .argName("boolean")
						     .desc("boolean=0 skips generation of html documentation. boolean=1 enables generation of html documentation. Default is 0.")
						     .build();
		
        
        
		options.addOption(ecorefile);
		options.addOption(language);
		options.addOption(path);
		options.addOption(documentation);
		
		if(args.size() == 0){
			var formatter = new HelpFormatter();
			formatter.printHelp("crossecore", options );
			System.exit(0);
		}
		
		var parser = new DefaultParser();
		var cmd = parser.parse( options, args);

		var errors = new ArrayList<String>();

		var _ecorefile = cmd.getOptionValue("e");
		var _language = cmd.getOptionValue("L");
		var _path = cmd.getOptionValue("p");		
		var _documentation = cmd.getOptionValue("d");
		
		
		
		if(_ecorefile.equals("")){
			
			errors.add("Provide path for ecore file.");				
		}
		else if(!new File(_ecorefile).exists){
			errors.add('''Ecore file «_ecorefile» does not exist.''');
			
			//TODO validate ecore file
		}

				
		
		if(_language.toLowerCase().equals("typescript")){
			
		}
		else if(_language.toLowerCase().equals("java")){
			
		}
		else if(_language.toLowerCase().equals("csharp")){
			
		}
		else if(_language.toLowerCase().equals("swift")){
			
		}		
		else{
			errors.add("Valid values for L parameter are 'typescript', 'csharp', 'java', 'swift'.");	
		}
		
		if(_path.equals("")){
			errors.add("Provide a target directory.");	
		}
		else if(!new File(_path).directory){
			errors.add('''Target directory «_path» does not exist.''');
		}
		
		try{
			
			if(_documentation===null){
				generateDocumentation = false;
			}
			else{
				generateDocumentation = if(Integer.parseInt(_documentation)==1) true else false;
			}
			

		}catch(Exception e){
			
			errors.add("Invalid value for argument d.");	
		}
		
		
		if(errors.size() ==0 ){
			
			if(_language.equals("typescript")){
				createTypeScript(_ecorefile, _path+"/");
			}
			else if(_language.equals("java")){
				createJava(_ecorefile, _path+"/");
			}
			else if(_language.equals("csharp")){
				createCSharp(_ecorefile, _path+"/");
			}
			else if(_language.equals("swift")){
				createSwift(_ecorefile, _path+"/");
			}					
		}
		else{
			
			for(String message : errors){
				logger.error(message)
				
			}
			logger.error("Generator failed.")
		}

	}
	
	
	static def String generate(EPackage epackage, String filename) throws IllegalArgumentException{
	
		
		if(epackage===null){
			throw new IllegalArgumentException('''No valid EPackage given''');
		}
		
	 	var mapping = #{
			//"" -> "ModelGenerator",
			"Base"-> "ModelBaseGenerator",
			"Impl"-> "ModelImplGenerator",
			"Package"-> "PackageGenerator",
			"PackageImpl"-> "PackageImplGenerator",
			"Switch"-> "SwitchGenerator",
			"Factory"-> "FactoryGenerator",
			"FactoryImpl"-> "FactoryImplGenerator"
		};
		
	 	var mapping_language = #{
			"ts"-> "typescript",
			"swift"-> "swift",
			"cs"-> "csharp"
		};
		
		var index = filename.lastIndexOf(".");
		
		if(index==-1){
			throw new IllegalArgumentException('''«filename» is not a valid file name''');
		}
		
		var filename2 = filename.substring(0, index);
		var extension_ = filename.substring(index+1);
		
		if(!mapping_language.containsKey(extension_)){
			throw new IllegalArgumentException('''«extension_» must be any of the extensions «mapping_language.keySet»''');
		}
		
		
		var language = mapping_language.get(extension_);
		var generator = "ModelGenerator";
		
		var eobject = null as EObject;
		var eclassifier_name = filename2;
		
		
		for(String suffix:mapping.keySet){
			
			if(filename2.endsWith(suffix) && mapping.containsKey(suffix)){
				
				generator = mapping.get(suffix);
				
				eclassifier_name = filename2.replace(suffix,"");			
			}
			
		}
		
		if(#{"ModelGenerator", "ModelBaseGenerator", "ModelImplGenerator"}.contains(generator)){
			
			val n = eclassifier_name;
			var set = epackage.EClassifiers.filter[c|c.name.equals(n)].toSet;
			
			if(set.length!=1){
				throw new IllegalArgumentException('''«n» not found in EPackage «epackage.name»''');	
				
			}
			
			eobject = set.get(0);
			
			
		}
		else{
			eobject = epackage;
		}
		
		
		var c = Class.forName('''com.crossecore.«language».«generator»''');
		
		var instance = c.newInstance();
		
		var method = c.getMethod("doSwitch", EObject);
		
		var result = method.invoke(instance, eobject);
		
		if(result instanceof CharSequence){
			
			return result.toString;
		}
		
		

	}
	
	
	private static def loadAndValidate(String ecorefile, String base){
		
		val ecoremodel = new File(ecorefile);
		
		var mypackage = new EcoreLoader().load(ecoremodel) as EPackage;
        val diagnostics = Diagnostician.INSTANCE.validate(mypackage)
        
        
		return mypackage
        

	}
	
	private static def createTypeScript(String ecorefile, String base){
		
		var mypackage = loadAndValidate(ecorefile, base);
		
		new com.crossecore.typescript.ModelGenerator(base, "src/%s.ts", mypackage).write();
		new com.crossecore.typescript.ModelBaseGenerator(base, "src/%sBase.ts", mypackage).write();	
		new com.crossecore.typescript.ModelImplGenerator(base, "src/%sImpl.ts", mypackage).write();
		new com.crossecore.typescript.PackageGenerator(base, "src/%sPackage.ts", mypackage).write();
		new com.crossecore.typescript.PackageImplGenerator(base, "src/%sPackageImpl.ts", mypackage).write();
		new com.crossecore.typescript.PackageLiteralsGenerator(base, "src/%sPackageLiterals.ts", mypackage).write();
		new com.crossecore.typescript.SwitchGenerator(base, "src/%sSwitch.ts", mypackage).write();
		new com.crossecore.typescript.FactoryGenerator(base, "src/%sFactory.ts", mypackage).write();
		new com.crossecore.typescript.FactoryImplGenerator(base, "src/%sFactoryImpl.ts", mypackage).write();
		new com.crossecore.typescript.NpmPackageGenerator(base, "package.json", mypackage).write();
		new com.crossecore.typescript.TSConfigGenerator(base, "tsconfig.json", mypackage).write();
		
		if(generateDocumentation){
			
			new HtmlVisitor(base,"index.html", mypackage).write();
		}
		//new TypeDefintionsGenerator(base, "%s.d.ts", mypackage).write();
		
	}
	
	private static def createCSharp(String ecorefile, String base){
		val ecoremodel = new File(ecorefile);
		
		var mypackage = new EcoreLoader().load(ecoremodel) as EPackage;
		
		
		new ModelGenerator(base, "%s.cs", mypackage).write();
		new ModelBaseGenerator(base, "%sBase.cs", mypackage).write();	
		new ModelImplGenerator(base, "%sImpl.cs", mypackage).write();
		new PackageGenerator(base, "%sPackage.cs", mypackage).write();
		new PackageImplGenerator(base, "%sPackageImpl.cs", mypackage).write();
		new SwitchGenerator(base, "%sSwitch.cs", mypackage).write();
		new FactoryGenerator(base, "%sFactory.cs", mypackage).write();
		new FactoryImplGenerator(base, "%sFactoryImpl.cs", mypackage).write();
		new ValidatorGenerator(base, "%sValidator.cs", mypackage).write();
		new VisualStudioProjectGenerator(base, "project.csproj", mypackage).write();	
		
		if(generateDocumentation){
			
			new HtmlVisitor(base,"index.html", mypackage).write();
			
		}
	}
	
	
	
	private static def createJava(String ecorefile, String base){
		val ecoremodel = new File(ecorefile);
		
		var mypackage = new EcoreLoader().load(ecoremodel) as EPackage;
		
		if(!Utils.isEcoreEPackage(mypackage)){
			
			new com.crossecore.java.ModelGenerator(base, "%s.java", mypackage).write();
			new com.crossecore.java.SwitchGenerator(base, "%sSwitch.java", mypackage).write();
			new com.crossecore.java.PackageGenerator(base, "%sPackage.java", mypackage).write();
		}
		new com.crossecore.java.ModelBaseGenerator(base, "%sBase.java", mypackage).write();	
		new com.crossecore.java.ModelImplGenerator(base, "%sImpl.java", mypackage).write();
		new com.crossecore.java.PackageImplGenerator(base, "%sPackageImpl.java", mypackage).write();
		new com.crossecore.java.FactoryGenerator(base, "%sFactory.java", mypackage).write();
		new com.crossecore.java.FactoryImplGenerator(base, "%sFactoryImpl.java", mypackage).write();
		new com.crossecore.java.ValidatorGenerator(base, "%sValidator.java", mypackage).write();
		new com.crossecore.java.GradleGenerator(base, "build.gradle", mypackage).write();	
		new com.crossecore.java.GradleSettingsGenerator(base, "settings.gradle", mypackage).write();	

	}
	
		
	
	private static def createSwift(String ecorefile, String base){
		val ecoremodel = new File(ecorefile);
		
		var mypackage = new EcoreLoader().load(ecoremodel) as EPackage;
		
		
		new com.crossecore.swift.ModelGenerator(base, "%s.swift", mypackage).write();
		new com.crossecore.swift.ModelBaseGenerator(base, "%sBase.swift", mypackage).write();	
		new com.crossecore.swift.ModelImplGenerator(base, "%sImpl.swift", mypackage).write();
		new com.crossecore.swift.PackageGenerator(base, "%sPackage.swift", mypackage).write();
		new com.crossecore.swift.PackageImplGenerator(base, "%sPackageImpl.swift", mypackage).write();
		new com.crossecore.swift.SwitchGenerator(base, "%sSwitch.swift", mypackage).write();
		new com.crossecore.swift.FactoryGenerator(base, "%sFactory.swift", mypackage).write();
		new com.crossecore.swift.FactoryImplGenerator(base, "%sFactoryImpl.swift", mypackage).write();	
		
		if(generateDocumentation){
			
			new HtmlVisitor(base,"index.html", mypackage).write();
		}
	}
	
	
}