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
package com.crossecore.typescript;

import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EPackage

class RollupConfigGenerator extends EcoreVisitor{
	
	
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}

	
	override caseEPackage(EPackage epackage){
		
		return 
		'''
		import typescript from '@rollup/plugin-typescript';
		import { terser } from "rollup-plugin-terser";
		import cleanup from 'rollup-plugin-cleanup';
		
		export default {
		    input: 'src/index.ts',
		    output: [
		        {
		            file: "dist/«epackage.name».cjs.js",
		            format: 'cjs'
		        }
		        ,
		        {
		            file: "dist/«epackage.name».cjs.min.js",
		            format: 'cjs',
		            plugins: [terser({ format: { comments: false } })]
		        }
		        ,
		        {
		            file: "dist/«epackage.name».umd.js",
		            format: 'umd',
		            name: "«epackage.name»"
		        }
		        ,
		        {
		            file: "dist/«epackage.name».umd.min.js",
		            format: 'umd',
		            name: "«epackage.name»",
		            plugins: [terser({ format: { comments: false } })]
		        }
		        ,
		        {
		            file: "dist/«epackage.name».amd.js",
		            format: 'amd',
		            name: "«epackage.name»"
		        }
		        ,
		        {
		            file: "dist/«epackage.name».amd.min.js",
		            format: 'amd',
		            name: "«epackage.name»",
		            plugins: [terser({ format: { comments: false } })]
		        }
		        ,
		        {
		            file: "dist/«epackage.name».es.js",
		            format: 'es',
		
		        }
		        ,
		        {
		            file: "dist/«epackage.name».es.min.js",
		            format: 'es',
		            plugins: [terser({ format: { comments: false } })]
		        }
		    ],
		    plugins: [typescript(), cleanup({comments: "none"})]
		};
		'''

	}
	

}