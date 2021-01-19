package com.crossecore.typescript

import org.eclipse.emf.ecore.EPackage
import com.crossecore.CompoundGenerator

class TypeScriptVisitor extends CompoundGenerator {
	
	new (String base, EPackage epackage){
		register(new FactoryGenerator(base, "%sFactory.ts", epackage))
		register(new FactoryImplGenerator(base, "%sFactoryImpl.ts", epackage))
		register(new ModelGenerator(base, "%s.ts", epackage))
		register(new ModelBaseGenerator(base, "%sBase.ts", epackage))
		register(new ModelImplGenerator(base, "%sImpl.ts",epackage))
		register(new NpmPackageGenerator(base, "package.json", epackage))
		register(new PackageGenerator(base, "%sPackage.ts", epackage))
		register(new PackageImplGenerator(base, "%sPackageImpl.ts", epackage))
		register(new PackageLiteralsGenerator(base, "%sPackageLiterals.ts", epackage))
		register(new SwitchGenerator(base, "%sSwitch.ts", epackage))
		register(new TSConfigGenerator(base, "tsconfig.json", epackage))
	}
}