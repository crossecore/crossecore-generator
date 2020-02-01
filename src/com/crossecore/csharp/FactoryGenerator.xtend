package com.crossecore.csharp

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EPackage
import com.crossecore.Utils
import com.crossecore.IdentifierProvider

class FactoryGenerator extends CSharpVisitor {
	
	private IdentifierProvider id = new CSharpIdentifier();
	
	private String header = '''
	/* CrossEcore is a cross-platform modeling framework that generates C#, TypeScript, 
	 * JavaScript, Swift code from Ecore models with embedded OCL (http://www.crossecore.org/).
	 * The original Eclipse Modeling Framework is available at https://www.eclipse.org/modeling/emf/.
	 * 
	 * contributor: Simon Schwichtenberg
	 */
	 
	 '''
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	

	override caseEPackage (EPackage epackage) {
		
		'''
		«header»
	 	«IF !Utils.isEcoreEPackage(epackage)»
		using Ecore;
	 	«ENDIF»
		namespace «id.doSwitch(epackage)»{
			public interface «id.EPackageFactory(epackage)» : EFactory{
				
				«FOR EClassifier classifier: epackage.EClassifiers»
					«doSwitch(classifier)»
				«ENDFOR»
			}
		}
		'''
	
	}

	
	override caseEClass(EClass eclass){
		if(!eclass.interface){
			'''
				«id.doSwitch(eclass)» «id.createEClass(eclass)»();
			'''
		}
	}
	
	
	
	
}