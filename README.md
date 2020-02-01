# Build from source
```bash
./gradlew customFatJar
```
You find the Jar here: `build/libs/crossecore-generator_20200201-0643.jar`

# Usage

```bash
java -jar crossecore-generator.jar -L typescript -e Model.ecore -p
./output/mypackage/
```

```
usage: crossecore
 -d <boolean>     boolean=0 skips generation of html documentation.
                  boolean=1 enables generation of html documentation.
                  Default is 1.
 -e <file>        source file (.ecore)
 -L <language>    target programming language. Valid values are
                  typescript, csharp, java, swift.
 -p <directory>   target path
```


