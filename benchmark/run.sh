#!/bin/bash

########################################################################
#                                                                      #
#    To run this script, content_shell must be in the path,            #
#    and dart editor running with tiles as one of the root folders.    #
#                                                                      #
########################################################################

. ./bin/functions.sh --source-only

JS=0;

DIR=$(dirname $0)

STARTTIME=$(date +%s);

runner_html () {
	if [ $JS -eq 1 ];
	then
		echo "http://127.0.0.1:3030/tiles/benchmark/runner.js.html";
	else
		echo "http://127.0.0.1:3030/tiles/benchmark/runner.html";
	fi
}

runner () {
	RUNNERHTML=$(runner_html);
	content_shell --dump-render-tree \
		"$RUNNERHTML#{\"levels\":$2,\"library\":\"$1\",\"dirty\":$3,\"environment\":\"$4\"}" 2> /dev/null \
	| grep "CONSOLE"\
	| sed "s/^CONSOLE MESSAGE: line [0-9]*: //g"
}

# arguments: library, levels
analyze () {
		RESULT=$(runner $1 $2 "false" "DOM");

		DOM=$(echo $RESULT | cut -d , -f 1)
		RENDERALL=$(echo $RESULT | cut -d , -f 3)
		UPDATECLEAN=$(echo $RESULT | cut -d , -f 4)

		RESULT=$(runner $1 $2 "false" "virtual");
		VIRTUAL=$(echo $RESULT | cut -d , -f 2)

		RESULT=$(runner $1 $2 "true" "DOM");
		UPDATEDIRTY=$(echo $RESULT | cut -d , -f 5)

		echo "$DOM;$VIRTUAL;$RENDERALL;$UPDATECLEAN;$UPDATEDIRTY";
}

# arguments: library, levels
analyze_js_and_dart () {
	JS=0;
	RESULTDART=$(analyze $1 $2);
	JS=1;
	RESULTJS=$(analyze $1 $2);
	JS=0;
	echo "$RESULTDART; $RESULTJS";
}

# arguments: list of levels
analyze_all () {
	for i in "$@"
	do
		echo "$(green)complete analyzing of $i$(white)" 1>&2;
		printf "$i; ";
		TILESRESULT=$(analyze_js_and_dart tiles $i)
		REACTRESULT=$(analyze_js_and_dart tiles $i)
		echo "$TILESRESULT;$REACTRESULT";
	done
}

# arguments: list of levels
tiles () {
	for i in "$@"
	do
		printf "tiles $i; ";
		analyze_js_and_dart tiles $i
	done
}

# arguments: list of levels
react () {
	for i in "$@"
	do
		printf "react $i; ";
		analyze react $i
	done
}

# easy benchmark runner of comparison of mass and structure in tiles
tiles_mass_vs_structure () {
	echo "$(green)tiles_mass_vs_structure$(white)" 1>&2;
	tiles \
		"[5040]         "\
		"[5040,1]       "\
		"[504,10]       "\
		"[50,10,10]     "\
		"[50,10,5,2]    "\
		"[10,10,5,5,2]  "\
		"[10,5,5,5,2,2] "\
		"[7,6,5,4,3,2,1]"
}

# easy benchmark runner of comparison of mass and structure in react
react_mass_vs_structure () {
	echo "$(green)react_mass_vs_structure$(white)" 1>&2;
	react \
		"[5040]         "\
		"[5040,1]       "\
		"[504,10]       "\
		"[50,10,10]     "\
		"[50,10,5,2]    "\
		"[10,10,5,5,2]  "\
		"[10,5,5,5,2,2] "\
		"[7,6,5,4,3,2,1]"
}

# print headeers of output csv
print_headers () {
	printf "measure; "; # header
	printf "tiles render; tiles virtual DOM; tiles render all; tiles clean update; tiles dirty update; "; # tiles dart
	printf "tiles JS render; tiles JS virtual DOM; tiles JS render all; tiles JS clean update; tiles JS dirty update;"; # tiles javascript
	printf "react render; react virtual DOM; react render all; react clean update; react dirty update; "; # react dart
	echo "react JS render; react JS virtual DOM; react JS render all; react JS clean update; react JS dirty update"; # react javascript
}

print_headers;

analyze_all  \
	"[1]"\
	"[100]"\
	"[200]"\
	"[300]"\
	"[400]"\
	"[500]"\
	"[600]"\
	"[700]"\
	"[800]"\
	"[900]"\
	"[1000]"\
	"[1100]"\
	"[1200]"\
	"[1300]"\
	"[1400]"\
	"[1500]"\
	"[1600]"\
	"[1700]"\
	"[1800]"\
	"[1900]"\
	"[2000]"\
	"[2]"\
	"[2,2]"\
	"[2,2,2]"\
	"[2,2,2,2]"\
	"[2,2,2,2,2]"\
	"[2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2,2,2]"\
	"[4,2,2,2,2,2,2,2,2,2]"\
	"[4,4,2,2,2,2,2,2,2]"\
	"[4,4,4,2,2,2,2,2]"\
	"[4,4,4,4,2,2,2]"\
	"[4,4,4,4,4,2]"\
	"[4,4,4,4,8]"\
	"[8,8,4,8]"\
	"[16,16,8]"\
	"[64,32]"\
	"[4]"\
	"[8]"\
	"[16]"\
	"[32]"\
	"[64]"\
	"[128]"\
	"[256]"\
	"[512]"\
	"[1024]"\
	"[2048]"\
