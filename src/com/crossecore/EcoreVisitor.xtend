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

import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStreamWriter
import java.nio.charset.Charset
import java.util.Formatter
import java.util.List
import java.util.Locale
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreSwitch
import java.util.regex.Pattern

abstract class EcoreVisitor extends EcoreSwitch<CharSequence>{
	
	protected String filenamePattern = "%s.cs";
	protected String path = "";
	protected EPackage epackage = null;
	protected boolean multi = false;
	
	
	new(EPackage epackage){
		this.epackage = epackage
	}
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super();
		this.path = path;
		this.filenamePattern = filenamePattern;
		this.epackage = epackage;
	}
	
	def List<String> index(){
		
		val sb = new StringBuilder();
		val formatter = new Formatter(sb, Locale.US);
		val item = formatter.format(this.filenamePattern, this.epackage.name.toFirstUpper);
		return #[item.toString]
			
	}
	
	def boolean matches(String path){
		return path.endsWith(this.filenamePattern.replace("%s", this.epackage.name.toFirstUpper))
	}
	
	
	def write(){
		write(epackage, this.doSwitch(epackage).toString);
	}
	
	def write(ENamedElement element, String contents, Boolean override_){
		
		
		var sb = new StringBuilder();
		
		var formatter = new Formatter(sb, Locale.US);
		
		formatter.format(this.filenamePattern, element.name.toFirstUpper);
		
		var targetFile = sb.toString;
		var x = new File(this.path+targetFile);
		
		if(!override_ && x.exists){
			return;
		}
		
		try {
			val char_output = new OutputStreamWriter(
				     new FileOutputStream(this.path+targetFile),
				     Charset.forName("UTF-8").newEncoder() 
				 );
			
			char_output.write(contents);
			char_output.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	def write(ENamedElement element, String contents){
		write(element, contents, true);
	}
	


}