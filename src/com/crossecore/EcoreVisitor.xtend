package com.crossecore;

import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStreamWriter
import java.nio.charset.Charset
import java.util.Formatter
import java.util.Locale
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreSwitch

abstract class EcoreVisitor extends EcoreSwitch<CharSequence>{
	
	protected String filenamePattern = "%s.cs";
	protected String path = "";
	protected ENamedElement epackage = null;
	
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, ENamedElement epackage){
		super();
		this.path = path;
		this.filenamePattern = filenamePattern;
		this.epackage = epackage;
	}
	
	
	public def write(){
		write(epackage, this.doSwitch(epackage).toString);
	}
	
	public def write(ENamedElement element, String contents, Boolean override_){
		
		
		//TODO use FileWriter
		
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
	
	public def write(ENamedElement element, String contents){
		write(element, contents, true);
	}
	


}