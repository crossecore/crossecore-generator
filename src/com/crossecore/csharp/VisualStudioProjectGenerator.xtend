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
package com.crossecore.csharp

import org.eclipse.emf.ecore.EPackage

class VisualStudioProjectGenerator extends CSharpVisitor{
	
	CSharpIdentifier id = new CSharpIdentifier();
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	override caseEPackage(EPackage epackage) {
		'''
		<Project Sdk="Microsoft.NET.Sdk">
		  
		  <PropertyGroup>
		    <TargetFramework>netcoreapp3.1</TargetFramework>
		  </PropertyGroup>
		  
		  <ItemGroup>
		    <PackageReference Include="Com.CrossEcore.Ecore" Version="0.1.1" />
		  </ItemGroup>
		
		</Project>
		'''
	}
	
}