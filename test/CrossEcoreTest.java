import static org.junit.Assert.*;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.impl.EcorePackageImpl;
import org.junit.Ignore;
import org.junit.Test;

import com.crossecore.CrossEcore;
import com.crossecore.EcoreLoader;
import com.crossecore.Utils;

public class CrossEcoreTest {

	@Test
	@Ignore
	public void testGenerate() {
		CrossEcore crossecore = new CrossEcore();
		EPackage epackage = (EPackage) new EcoreLoader().load(new File("model/Ecore.ecore"));
		
		System.out.println(crossecore.generate(epackage, "EClassifierBase.cs"));
		
		assertNotNull(crossecore.generate(epackage, "EClassifier.cs"));
		assertNotNull(crossecore.generate(epackage, "EcorePackage.cs"));
	}
	
	@Test
	@Ignore
	public void test() {
		
		
		EcorePackageImpl.init();
		
		HashMap<EClass, HashSet<EClass>> closure = Utils.getSubclassClosure(EcorePackage.eINSTANCE);
		
		
		HashSet<EClass> subclasses = closure.get(EcorePackage.eINSTANCE.getEModelElement());
		
		System.out.println(subclasses);
		
		
	}
	
	@Test
	public void bla() {
		
		System.out.println("ThisIsMyCamelCase".replaceAll("([a-z])([A-Z])", "$1_$2"));
		
		System.out.println("AAA".replaceAll("([a-z])([A-Z])", "$1_$2"));
		System.out.println("camelCase".replaceAll("([a-z])([A-Z])", "$1_$2"));
		System.out.println("camel_Case".replaceAll("([a-z])([A-Z])", "$1_$2"));
		
	}

}
