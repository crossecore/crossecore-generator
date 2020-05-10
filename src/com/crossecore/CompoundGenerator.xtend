package com.crossecore

import java.util.List
import java.util.ArrayList
import java.util.HashMap
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EObject
import java.util.Map
import java.util.Collections
import java.io.File
import java.io.OutputStreamWriter
import java.io.FileOutputStream
import java.nio.charset.Charset
import java.io.FileNotFoundException
import java.io.IOException

class CompoundGenerator{
	
	protected List<EcoreVisitor> generators = new ArrayList<EcoreVisitor>()
	protected HashMap<String, Pair<EObject, EcoreVisitor>> filename2generator = new HashMap<String, Pair<EObject, EcoreVisitor>>()
	protected boolean isIndexed = false
	
	public def Map<EObject, List<String>> index(){
		
		val result = new HashMap<EObject, List<String>>();
		for(EcoreVisitor v : generators){
			val index = v.index();
	
			for(EObject eobject:index.keySet){
				
				var filenameAccumulator = null as List<String>
				
				if(result.containsKey(eobject)){
					filenameAccumulator = result.get(eobject)
				}
				else{
					filenameAccumulator = new ArrayList<String>
				}
				
				var newFilenames = index.get(eobject)
				filenameAccumulator.addAll(newFilenames)
				result.put(eobject, filenameAccumulator)
				
				for(String filename: newFilenames){
					filename2generator.put(filename, eobject -> v)
				}
					
			}
		}
		isIndexed = true
		return result
		
	}
	
	public def register(EcoreVisitor visitor){
		generators.add(visitor);
	}
	
	public def write(){
		if(!isIndexed){
			index()
		}
		
		for(String filename: filename2generator.keySet){
		
			var x = new File(filename);
			var visitor = filename2generator.get(filename).value
			
			if(!visitor.allowOverride && x.exists){
				return;
			}
			
			try {
				val char_output = new OutputStreamWriter(
					     new FileOutputStream(filename),
					     Charset.forName("UTF-8").newEncoder() 
					 );
				var contents = generate(filename)
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
	}
	
	public def String generate(String filename) throws IllegalArgumentException{
		
		if(!isIndexed){
			index()
		}
		
		if(filename2generator.containsKey(filename)){
			val visitor = filename2generator.get(filename).value
			val eobject = filename2generator.get(filename).key
			return visitor.doSwitch(eobject).toString
		}
		else{
			throw new IllegalArgumentException()
		}

	}
	
}