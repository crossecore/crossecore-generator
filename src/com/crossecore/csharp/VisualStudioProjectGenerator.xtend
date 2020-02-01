package com.crossecore.csharp

import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass

class VisualStudioProjectGenerator extends CSharpVisitor{
	
	private CSharpIdentifier id = new CSharpIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage) {
		'''
		<Project Sdk="Microsoft.NET.Sdk">
		  
		  <PropertyGroup>
		    <TargetFramework>netstandard2.0</TargetFramework>
		  </PropertyGroup>
		  
		  <ItemGroup>
		    <PackageReference Include="CrossEcore" Version="1.0.0-alpha" />
		  </ItemGroup>
		
		</Project>
		'''
	}
	
}