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

import org.eclipse.emf.ecore.EObject
import com.crossecore.IdentifierProvider
import java.util.Set

class CSharpIdentifier extends IdentifierProvider {

	static Set<String> KEYWORDS = #{
		"abstract",
		"add",
		"as",
		"ascending",
		"async",
		"await",
		"base",
		"bool",
		"break",
		"by",
		"byte",
		"case",
		"catch",
		"char",
		"checked",
		"class",
		"const",
		"continue",
		"decimal",
		"default",
		"delegate",
		"descending",
		"do",
		"double",
		"dynamic",
		"else",
		"enum",
		"equals",
		"event",
		"explicit",
		"extern",
		"false",
		"finally",
		"fixed",
		"float",
		"for",
		"foreach",
		"from",
		"get",
		"global",
		"goto",
		"group",
		"if",
		"implicit",
		"in",
		"int",
		"interface",
		"internal",
		"into",
		"is",
		"join",
		"let",
		"lock",
		"long",
		"namespace",
		"new",
		"null",
		"object",
		"on",
		"operator",
		"orderby",
		"out",
		"override",
		"params",
		"partial",
		"private",
		"protected",
		"public",
		"readonly",
		"ref",
		"remove",
		"return",
		"sbyte",
		"sealed",
		"select",
		"set",
		"short",
		"sizeof",
		"stackalloc",
		"static",
		"string",
		"struct",
		"switch",
		"this",
		"throw",
		"true",
		"try",
		"typeof",
		"uint",
		"ulong",
		"unchecked",
		"unsafe",
		"ushort",
		"using",
		"value",
		"var",
		"virtual",
		"void",
		"volatile",
		"where",
		"while",
		"yield"
	};

	override escapeKeyword(String identifier) {

		if (KEYWORDS.contains(identifier)) {
			return identifier + "_"
		} else {
			return identifier;
		}
	}

	public def escapeIdentifier(String str) {

		var s = str;
		s = s.replace("-", "_");
		s = s.replace("/", "_");
		return s;
	}

	override EObject(EObject eobject) {

		return escapeIdentifier(super.EObject(eobject));
	}

}
