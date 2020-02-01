package com.crossecore

import java.io.File
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.impl.EcorePackageImpl
import org.eclipse.emf.ecore.EPackage

public class EcoreLoader {


	private ResourceSet resourceSet = new ResourceSetImpl();

	new(){
		
		
		EcorePackageImpl.init();

	    var reg = Resource.Factory.Registry.INSTANCE;
	    var m = reg.getExtensionToFactoryMap();
	    m.put("ecore", new XMIResourceFactoryImpl());
	    m.put("xmi", new XMIResourceFactoryImpl());
	}
	public def EObject load(File ecoreFile){
		

		var resource = resourceSet.getResource(URI.createFileURI(ecoreFile.absolutePath), true);
		
		resourceSet.getResource(URI.createFileURI(ecoreFile.absolutePath), true);
		
	    var eobject = resource.getContents().get(0);
		return eobject;
	}
	
	public def void registerURI(String nsURI, EPackage instance){
		resourceSet.getPackageRegistry().put(nsURI, instance);
	}
	

}