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