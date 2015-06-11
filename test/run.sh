#!/bin/bash

DIR=$(dirname $0)
FAIL=0;

rmifex () {
	touch $1;
	rm $1 -rf;
}

green () {
	printf "\033[32m";
}

red () {
	printf "\033[31m";
}

white () {
	printf "\033[0m";
}

yellow () {
	printf "\033[33m";
}

SELENIUMSERVERPID=0;
runselenium () {
	if [ ! -f selenium-server-standalone-2.40.0.jar ]
	then
		echo "$(yellow)Downloading Selenium server standalone $(white)";
		wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar --quiet
	fi
	echo "$(yellow)Runnging Selenium server standalone in background $(white)";
	java -jar selenium-server-standalone-2.40.0.jar > /dev/null 2> /dev/null &
	SELENIUMSERVERPID=$!;
	echo "SELENIUM SERVER PID IS $SELENIUMSERVERPID";
}
stopselenium () {
	echo "$(yellow)Killing background Selenium server $i$(white)";
	kill $SELENIUMSERVERPID;
}

download_content_shell () {
	if [ ! -f content_shell ]
	then
		download_contentshell.sh
		unzip content_shell-linux-x64-release.zip
		mv drt*/* .
	fi
}

remove_content_shell () {
	rmifex content_shell-linux-x64-release.zip -f
	rmifex drt* -rf
	rmifex content_shell.log
	rmifex content_shell.pak
	rmifex fonts.conf
	rmifex libffmpegsumo.so
	rmifex libosmesa.so
	rmifex snapshot-size.txt
}

color_output () {
	RESULT=$1;
	# color FAIL
	RESULT=$(echo "$RESULT" | sed "/^FAIL/s//$(red)FAIL$(white)/");
	# color PASS
	RESULT=$(echo "$RESULT" | sed "/^PASS/s//$(green)PASS$(white)/");
	# remove Expectation: 
	RESULT=$(echo "$RESULT" | sed "s/Expectation: //g");
	# color success message
	RESULT=$(echo "$RESULT" | sed "s/^All \([0-9]*\) tests passed/\n$(green)All \1 tests passed$(white)/g");
	# color fail message
	RESULT=$(echo "$RESULT" | sed "s/^Total \(.*\) errors/\n$(red)Total \1 errors$(white)/g");
	RESULT=$(echo "$RESULT" | sed "s/^\([0-9]*\) PASSED, \([0-9]*\) FAILED, \([0-9]*\) ERRORS/\n$(red)\1 PASSED, \2 FAILED, \3 ERRORS$(white)/g");
	echo "$RESULT";
}

install_dependences () {
	echo "$(yellow)Installing dependences$(white)"
	pub install
}

test_core () {
	echo "$(yellow)Running core tests$(white)";

	RESULT=$(dart test/all.dart 2>&1);
	PASS=$?;
	RESULT=$(color_output "$RESULT");
	echo Core tests returns $PASS with message;
	echo "$RESULT";

	if [ $PASS -ne 0 ]
	then
		# echo "$(red)SOME TESTS FAILED$(white)";
		FAIL=1;
	fi

}

test_browser () {
	echo;
	echo;
	echo "$(yellow)Running browser tests with contentshel$(white)";

	download_content_shell;

	RESULT=$(./content_shell --dump-render-tree test/all_browser.html 2>&1);
	PASS=$?;

	# remove line numbers
	RESULT=$(echo "$RESULT" | sed "s/^[0-9]*\s*//g");
	# remove #EOF
	RESULT=$(echo "$RESULT" | sed "s/^#EOF//g");
	RESULT=$(color_output "$RESULT");
	echo Browser tests returns $PASS with message;
	echo "$RESULT";

	remove_content_shell;

	BR1=`echo ${RESULT/lasdjfkladjflkadfladsjfldasj/FF}`;
	BR2=`echo ${RESULT/FAIL/FF}`;

	if [ "$BR1" != "$BR2" ]
	then
		# echo "$(red)SOME TESTS FAILED$(white)";
		FAIL=1;
	fi
}

test_selenium () {
	echo;
	echo;
	runselenium;
	echo "$(yellow)Converting tested app files to javascript$(white)";
	# comvert all not test dart files to .js
	for i in `find  $DIR/selenium -regex '.*.dart' ! -regex '.*/.*test.*\.dart'`; do 
		echo "- $(yellow)Converting $i to ${i}.js$(white)";
		dart2js $i -o ${i}.js;
		rm ${i}.js.deps;
		rm ${i}.js.map;
		rm ${i}.precompiled.js;
	done;


	echo "$(yellow)Running selenium tests$(white)";
	# run selenium tests
	RESULT=`dart test/all_selenium.dart 2>&1`;
	PASS=$?;
 	RESULT=$(color_output "$RESULT");
	echo Selenium tests returns $PASS with message;
	echo "$RESULT";

	stopselenium;


	echo "$(yellow)Cleaning compiled javascript files$(white)";
	for i in `find $DIR/selenium -name "*.dart.js"`; do 
		rm ${i};
		echo "$(yellow)Cleaning $i$(white)";
	done;

	if [ $PASS -ne 0 ]
	then
		# echo "$(red)SOME TESTS FAILED$(white)";
		FAIL=1;
	fi
}


if [ $# -eq 0 ]
then
	install_dependences;

	test_core;
	test_browser;
	# test_selenium;
else
	opts=`getopt cbs "$@" 2> /dev/null`
	if [ $? -ne 0 ] 
	then
		echo >&2 \
		"$(red)usage: $0 [-c] [-b] [-s]$(white)"
		exit 1;
	fi

	set -- $opts
	[ $# -lt 1 ] && exit 1

	install_dependences;

	while [ $# -gt 0 ]
	do
	case "$1" in
		-c)	test_core; break;;
		-b)	test_browser; break;;
		-s)	test_selenium; break;;
		--)	shift; break;;
		-*)
			echo >&2 \
			"usage: $0 [-c] [-b] [-s]"
			exit 1;;
		*)	break;;		# terminate while loop
	esac
	shift
	done
fi


if [ $FAIL -ne 0 ]
then
	echo;
	echo;
	echo;
	echo "$(red)SOME TESTS FAILED$(white)";
	exit 1;
else
	echo;
	echo;
	echo;
	echo "$(green)ALL TESTS PASSED$(white)";
fi

