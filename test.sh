#!/bin/bash

if ! [ -x "$(command -v npm)" ]; then
  echo 'Error: Please install npm.'
  exit 1
fi

if ! [ -x "$(command -v dotnet)" ]; then
  echo 'Error: Please install dotnet.'
  exit 1
fi

if ! [ -x "$(command -v gradle)" ]; then
  echo 'Error: Please install gradle build tool.'
  exit 1
fi


./gradlew customFatJar

basedir=$(dirname "$0")
model_path="./model/" 
package_name="undefined"

generator_path="./build/libs/"
build_path="./build/testmodels/"

mkdir --parents "$build_path"

unset -v latest
for file in "$generator_path"/*; do
  [[ $file -nt $latest ]] && latest=$file
done

#ascii art from http://patorjk.com/software/taag/#p=display&c=echo&f=Graffiti&t=typescript

for file in Java Testmodel; do
    modelfile="$model_path$file.ecore"

    package_name="$file"

    for language in java csharp typescript; do
        working_dir="$build_path$language/$package_name/"
        mkdir --parents $working_dir
        
        java -jar "$latest" -L $language -e "$modelfile" -p "$working_dir"
        echo "generating $language source code from $modelfile"

        cd $working_dir

        if [ $language == 'java' ]
        then
            echo '     __                     ';
            echo '    |__|____ ___  _______   ';
            echo '    |  \__  \\  \/ /\__  \  ';
            echo '    |  |/ __ \\   /  / __ \_';
            echo '/\__|  (____  /\_/  (____  /';
            echo '\______|    \/           \/ ';
            gradle wrapper
            ./gradlew build
        elif [ $language == 'csharp' ]
        then
            echo '          _  _   ';
            echo '  ____ __| || |__';
            echo '_/ ___\\   __   /';
            echo '\  \___ |  ||  | ';
            echo ' \___  >_  ~~  _\';
            echo '     \/  |_||_|  ';
            dotnet build --configuration Release
        elif [ $language == 'typescript' ]
        then
            echo '  __                                            .__        __   ';
            echo '_/  |_ ___.__.______   ____   ______ ___________|__|______/  |_ ';
            echo '\   __<   |  |\____ \_/ __ \ /  ___// ___\_  __ \  \____ \   __\';
            echo ' |  |  \___  ||  |_> >  ___/ \___ \\  \___|  | \/  |  |_> >  |  ';
            echo ' |__|  / ____||   __/ \___  >____  >\___  >__|  |__|   __/|__|  ';
            echo '       \/     |__|        \/     \/     \/         |__|         ';    
            npm install
            npm run build
        fi

        cd ../../../../

    done
done