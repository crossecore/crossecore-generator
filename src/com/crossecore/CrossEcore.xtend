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
import com.crossecore.csharp.VisualStudioProjectGenerator
import com.crossecore.docs.HtmlVisitor
import com.crossecore.java.GradleGenerator
import com.crossecore.java.GradleSettingsGenerator
import com.crossecore.typescript.NpmPackageGenerator
import com.crossecore.typescript.PackageLiteralsGenerator
import com.crossecore.typescript.TSConfigGenerator
import java.io.File
import java.util.ArrayList
import java.util.List
import org.apache.commons.cli.DefaultParser
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.Option
import org.apache.commons.cli.Options
import org.apache.log4j.LogManager
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.Diagnostician
import com.crossecore.typescript.WebpackConfigGenerator
import com.crossecore.typescript.JestConfigGenerator

class CrossEcore {
	
	static boolean generateDocumentation = true;
	static File targetPath = null;
	static File ecoreFile = null;
	static String targetLanguage = "";
	static List<EPackage> packages = new ArrayList<EPackage>();
	static String base = ""
	
	static final Logger logger = LogManager.getLogger(CrossEcore);
	
	
	static def main(String[] args){
		
		val options = new Options();
		
		val ecorefile = Option.builder("e")
					     .required(true)
					     .hasArg()
					     .argName("file")
					     .desc("source file (.ecore)")
					     .build();                  
		
		val language = 	Option.builder("L")
					     .required(true)
					     .hasArg()
					     .argName("language")
					     .desc("target programming language. Valid values are typescript, csharp, java, swift.")
					     .build();
		
		val path =  	Option.builder("p")
					     .required(true)
					     .hasArg()
					     .argName("directory")
					     .desc("target path")
					     .build();
				     
	    val docs =		Option.builder("d")
					     .required(false)
					     .hasArg()
					     .argName("boolean")
					     .desc("boolean=0 skips generation of html documentation. boolean=1 enables generation of html documentation. Default is 0.")
					     .build();
		
		options.addOption(ecorefile);
		options.addOption(language);
		options.addOption(path);
		options.addOption(docs);
		
		if(args.size() == 0){
			val formatter = new HelpFormatter();
			formatter.printHelp("crossecore", options );
			System.exit(0);
		}
		
		val parser = new DefaultParser();
		val cmd = parser.parse( options, args);

		val errors = new ArrayList<String>();

		val raw_ecorefile = cmd.getOptionValue("e");
		val raw_language = cmd.getOptionValue("L");
		val raw_path = cmd.getOptionValue("p");		
		val raw_documentation = cmd.getOptionValue("d");
		
		
		if(!raw_path.equals("")){
			
			val target_dir = new File(raw_path)
			if(target_dir.directory){
				targetPath = target_dir
				base = targetPath.absolutePath+"/"
			}
			else{
				errors.add('''«target_dir» is not a directory.''');		
			}
		}
		else{
			errors.add("Provide a target path.");		
		}
		
		if(!raw_ecorefile.equals("")){
			val input = new File(raw_ecorefile)
			
			if(input.exists){
				
				val pks = new EcoreLoader().load(input).filter[o|o instanceof EPackage].map[o|o as EPackage].toList
				
				if(pks.size>0){
					
					
					var valid = true;
					for(EPackage p:pks){
						val diagnostics = Diagnostician.INSTANCE.validate(p)
						valid = diagnostics.severity < Diagnostic.ERROR
						for(Diagnostic d : diagnostics.children){
							if(diagnostics.severity>=Diagnostic.ERROR){
								
								errors.add('''EPackage «p.nsURI» has error: «d.message»''');
							}
						}
						
					}
					
					if(valid){
						packages = pks as List<EPackage>
					}
				}
				else{
					errors.add('''Ecore file «raw_ecorefile» does not contain any EPackages.''');
				}
			}
			else{
				
				errors.add('''Ecore file «raw_ecorefile» does not exist.''');
			}
		}
		else{
			
			errors.add("Provide path for ecore file.");				
		}
		
		
		if(!#["typescript", "java", "csharp", "swift"].contains(raw_language)){
			errors.add("Valid values for L parameter are 'typescript', 'csharp', 'java', 'swift'.");
		}
		
		
		if(raw_documentation !==null && raw_documentation.equals("1")){
			generateDocumentation = true
		}
		else{
			generateDocumentation = false
		}
		
		
		if(errors.size() ==0 ){
			
			if(raw_language.equals("typescript")){
				createTypeScript();
			}
			else if(raw_language.equals("java")){
				createJava();
			}
			else if(raw_language.equals("csharp")){
				createCSharp();
			}
			else if(raw_language.equals("swift")){
				createSwift();
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
	
	
	private static def createTypeScript(){
		
		for(EPackage mypackage:packages){
			
			new com.crossecore.typescript.ModelGenerator(base, '''/src/%s.ts''', mypackage).write();
			new com.crossecore.typescript.ModelBaseGenerator(base, '''/src/%sBase.ts''', mypackage).write();	
			new com.crossecore.typescript.ModelImplGenerator(base, '''/src/%sImpl.ts''', mypackage).write();
			new com.crossecore.typescript.PackageGenerator(base, '''/src/%sPackage.ts''', mypackage).write();
			new com.crossecore.typescript.PackageImplGenerator(base, '''/src/%sPackageImpl.ts''', mypackage).write();
			new PackageLiteralsGenerator(base, '''/src/%sPackageLiterals.ts''', mypackage).write();
			new com.crossecore.typescript.SwitchGenerator(base, '''/src/%sSwitch.ts''', mypackage).write();
			new com.crossecore.typescript.FactoryGenerator(base, '''/src/%sFactory.ts''', mypackage).write();
			new com.crossecore.typescript.FactoryImplGenerator(base, '''/src/%sFactoryImpl.ts''', mypackage).write();
			new NpmPackageGenerator(base, '''/package.json''', mypackage).write();
			new TSConfigGenerator(base, '''/tsconfig.json''', mypackage).write();
			new WebpackConfigGenerator(base, '''/webpack.config.js''', mypackage).write();
			new JestConfigGenerator(base, '''/jest.config.js''', mypackage).write();
			
			if(generateDocumentation){
				
				new HtmlVisitor(base,"index.html", mypackage).write();
			}
		}
		
	}
	
	private static def createCSharp(){
		
		for(EPackage mypackage:packages){
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
	}
	
	
	
	private static def createJava(){

		for(EPackage mypackage:packages){
		
			if(!Utils.isEcoreEPackage(mypackage)){
				
				new com.crossecore.java.ModelGenerator(base, '''«mypackage.name»/src/main/java/%s.java''', mypackage).write();
				new com.crossecore.java.SwitchGenerator(base, '''«mypackage.name»/src/main/java/%sSwitch.java''', mypackage).write();
				new com.crossecore.java.PackageGenerator(base, '''«mypackage.name»/src/main/java/%sPackage.java''', mypackage).write();
			}
			new com.crossecore.java.ModelBaseGenerator(base, '''«mypackage.name»/src/main/java/%sBase.java''', mypackage).write();	
			new com.crossecore.java.ModelImplGenerator(base, '''«mypackage.name»/src/main/java/%sImpl.java''', mypackage).write();
			new com.crossecore.java.PackageImplGenerator(base, '''«mypackage.name»/src/main/java/%sPackageImpl.java''', mypackage).write();
			new com.crossecore.java.FactoryGenerator(base, '''«mypackage.name»/src/main/java/%sFactory.java''', mypackage).write();
			new com.crossecore.java.FactoryImplGenerator(base, '''«mypackage.name»/src/main/java/%sFactoryImpl.java''', mypackage).write();
			new com.crossecore.java.ValidatorGenerator(base, '''«mypackage.name»/src/main/java/%sValidator.java''', mypackage).write();
			new GradleGenerator(base, '''«mypackage.name»/build.gradle''', mypackage).write();	
			new GradleSettingsGenerator(base, '''«mypackage.name»/settings.gradle''', mypackage).write();	
		}
	}
	
		
	
	private static def createSwift(){

		for(EPackage mypackage:packages){		
		
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
	
	
}