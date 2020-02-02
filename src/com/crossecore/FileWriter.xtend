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
package com.crossecore

import org.eclipse.emf.ecore.ENamedElement
import java.util.Formatter
import java.util.Locale
import java.io.OutputStreamWriter
import java.io.FileOutputStream
import java.nio.charset.Charset
import java.io.FileNotFoundException
import java.io.IOException

public class FileWriter {
	

	private String filenamePattern;
	private String path;
	
	
	new(String path){
		
		this.path = path;
	}
	
	new(String filenamePattern, String path){
		
		this.filenamePattern = filenamePattern;
		this.path = path;
	}
	
	private def getAbsoluteFilename(String filename){
		
		if(filenamePattern!=null){
			var sb = new StringBuilder();
			var formatter = new Formatter(sb, Locale.US);
		
			formatter.format(this.filenamePattern, filename);
			
			return this.path+sb.toString;
		}
		else{
			
			return this.path+filename;
		}

		
	}
	
	
	
	public def write(String filename, String contents){
		try {
			val char_output = new OutputStreamWriter(
				     new FileOutputStream(this.getAbsoluteFilename(filename)),
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
	
	public def write(ENamedElement element, String contents){

		write(element.name.toFirstUpper, contents);
		

	}
}