package com.crossecore

import java.io.File
import org.junit.Test
import static org.junit.Assert.assertNotNull

class EcoreLoaderTest {
	


	@Test def void testLoad() {
		
		val ecoreLoader = new EcoreLoader()
		val eobject = ecoreLoader.load(new File("model/Ecore.ecore"))
		
		assertNotNull(eobject)	
	}



}
