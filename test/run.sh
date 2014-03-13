#!/bin/bash

DIR=$(dirname $0)

echo "\033[32m Installing dependences\033[0m"

pub install

echo "\033[32m Running core tests\033[0m";

dart test/all.dart


echo "\033[32m Running browser tests with contentshel\033[0m";

download_contentshell.sh
unzip content_shell-linux-x64-release.zip
mv drt*/* .

./content_shell --dump-render-tree test/all_browser.html

rm content_shell-linux-x64-release.zip -f
rm drt* -rf
rm content_shell
rm content_shell.log
rm content_shell.pak
rm fonts.conf
rm libffmpegsumo.so
rm libosmesa.so
rm snapshot-size.txt

echo "\033[32m Downloading Selenium server standalone \033[0m";
wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar --quiet

echo "\033[32m Runnging Selenium server standalone in background \033[0m";
java -jar selenium-server-standalone-2.40.0.jar > /dev/null 2> /dev/null &
SELENIUMSERVERPID=$!;

echo Pid is $SELENIUMSERVERPID

echo "\033[32m Converting tested app files to javascript\033[0m";
# comvert all not test dart files to .js
echo $DIR;
for i in `find  $DIR/selenium -regex '.*.dart' ! -regex '.*/.*test.*\.dart'`; do 
	echo "\033[32m Converting $i to ${i}.js\033[0m";
	dart2js $i -o ${i}.js;
	rm ${i}.js.deps;
	rm ${i}.js.map;
	rm ${i}.precompiled.js;
done;

echo "\033[32m Running selenium tests\033[0m";
# run selenium tests
dart test/all_selenium.dart

echo "\033[32m Cleaning compiled javascript files\033[0m";
for i in `find $DIR/selenium -name "*.dart.js"`; do 
	rm ${i};
	echo "\033[32m Cleaning $i\033[0m";
done;

echo "\033[32m Killing background Selenium server $i\033[0m";
kill $SELENIUMSERVERPID;
rm selenium-server-standalone-2.40.0.jar;

