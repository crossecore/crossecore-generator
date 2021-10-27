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

import com.crossecore.typescript.FactoryGenerator
import com.crossecore.typescript.FactoryImplGenerator
import com.crossecore.typescript.ModelBaseGenerator
import com.crossecore.typescript.ModelGenerator
import com.crossecore.typescript.ModelImplGenerator
import com.crossecore.typescript.NpmPackageGenerator
import com.crossecore.typescript.PackageGenerator
import com.crossecore.typescript.PackageImplGenerator
import com.crossecore.typescript.PackageLiteralsGenerator
import com.crossecore.typescript.SwitchGenerator
import com.crossecore.typescript.TSConfigGenerator
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.EPackage
import com.google.gwt.core.client.EntryPoint
import jsinterop.annotations.JsType

@JsType
class CrossEcore implements EntryPoint{
	

	def boolean aisjdajsdoiasjoaijdofjaifj(){
		return false;
	}
	
	def List<String> index(EPackage epackage, String language){
		val result = new ArrayList<String>()
		var item = #[]
		val base = ""
		
		if(language.equals("typescript")){
			
			item = new ModelGenerator(base, "%s.ts", epackage).index();
			result.addAll(item)
			item = new ModelBaseGenerator(base, "%sBase.ts", epackage).index();
			result.addAll(item)
			item = new ModelImplGenerator(base, "%sImpl.ts", epackage).index();
			result.addAll(item)
			item = new PackageGenerator(base, "%sPackage.ts", epackage).index();
			result.addAll(item)
			item = new PackageImplGenerator(base, "%sPackageImpl.ts", epackage).index();
			result.addAll(item)
			item = new PackageLiteralsGenerator(base, "%sPackageLiterals.ts", epackage).index();
			result.addAll(item)
			item = new SwitchGenerator(base, "%sSwitch.ts", epackage).index();
			result.addAll(item)
			item = new FactoryGenerator(base, "%sFactory.ts", epackage).index();
			result.addAll(item)
			item = new FactoryImplGenerator(base, "%sFactoryImpl.ts", epackage).index();
			result.addAll(item)
			item = new NpmPackageGenerator(base, "package.json", epackage).index();
			result.addAll(item)
			item = new TSConfigGenerator(base, "tsconfig.json", epackage).index();
			result.addAll(item)
		}
		
		return result;
	}
	
	def String generate(EPackage epackage, String language, String path){
		if(language.equals("typescript")){
			
			
			var generator = null as EcoreVisitor;
			val base = ""
			
			generator = new ModelGenerator(base, "%s.ts", epackage);
			if(generator.matches(path)){
				val name = path.replace(base, "").replace(".ts", "")
				return generator.doSwitch(epackage.EClassifiers.findFirst[e|e.name.equals(name)]).toString	
			}
			
			generator = new ModelBaseGenerator(base, "%sBase.ts", epackage);
			if(generator.matches(path)){
				val name = path.replace(base, "").replace("Base.ts", "")
				return generator.doSwitch(epackage.EClassifiers.findFirst[e|e.name.equals(name)]).toString	
			}
			generator = new ModelImplGenerator(base, "%sImpl.ts", epackage);
			if(generator.matches(path)){
		
				val name = path.replace(base, "").replace("Impl.ts", "")
				return generator.doSwitch(epackage.EClassifiers.findFirst[e|e.name.equals(name)]).toString	
			}
			
			generator = new PackageGenerator(base, "%sPackage.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString
			}
			
			generator = new PackageImplGenerator(base, "%sPackageImpl.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString	
			}
			
			generator = new PackageLiteralsGenerator(base, "%sPackageLiterals.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString	
			}
			
			generator = new SwitchGenerator(base, "%sSwitch.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString		
			}
			
			generator = new FactoryGenerator(base, "%sFactory.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString	
			}

			generator = new FactoryImplGenerator(base, "%sFactoryImpl.ts", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString		
			}
			
			generator = new NpmPackageGenerator(base, "package.json", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString		
			}
			
			generator = new TSConfigGenerator(base, "tsconfig.json", epackage);
			if(generator.matches(path)){
				return generator.doSwitch(epackage).toString		
			}
		}
	}
	
	override onModuleLoad() {
	}
	

	
	
}