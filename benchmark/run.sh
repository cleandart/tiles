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
		REACTRESULT=$(analyze_js_and_dart react $i)
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
	"[2100]"\
	"[2200]"\
	"[2300]"\
	"[2400]"\
	"[2500]"\
	"[2600]"\
	"[2700]"\
	"[2800]"\
	"[2900]"\
	"[3000]"\
	"[3100]"\
	"[3200]"\
	"[3300]"\
	"[3400]"\
	"[3500]"\
	"[3600]"\
	"[3700]"\
	"[3800]"\
	"[3900]"\
	"[4000]"\
	"[4100]"\
	"[4200]"\
	"[4300]"\
	"[4400]"\
	"[4500]"\
	"[4600]"\
	"[4700]"\
	"[4800]"\
	"[4900]"\
	"[4000]"\
	"[5100]"\
	"[5200]"\
	"[5300]"\
	"[5400]"\
	"[5500]"\
	"[5600]"\
	"[5700]"\
	"[5800]"\
	"[5900]"\
	"[6000]"\
	"[1,1]"\
	"[100,1]"\
	"[200,1]"\
	"[300,1]"\
	"[400,1]"\
	"[500,1]"\
	"[600,1]"\
	"[700,1]"\
	"[800,1]"\
	"[900,1]"\
	"[1000,1]"\
	"[1100,1]"\
	"[1200,1]"\
	"[1300,1]"\
	"[1400,1]"\
	"[1500,1]"\
	"[1600,1]"\
	"[1700,1]"\
	"[1800,1]"\
	"[1900,1]"\
	"[2000,1]"\
	"[2100,1]"\
	"[2200,1]"\
	"[2300,1]"\
	"[2400,1]"\
	"[2500,1]"\
	"[2600,1]"\
	"[2700,1]"\
	"[2800,1]"\
	"[2900,1]"\
	"[3000,1]"\
	"[3100,1]"\
	"[3200,1]"\
	"[3300,1]"\
	"[3400,1]"\
	"[3500,1]"\
	"[3600,1]"\
	"[3700,1]"\
	"[3800,1]"\
	"[3900,1]"\
	"[4000,1]"\
	"[4100,1]"\
	"[4200,1]"\
	"[4300,1]"\
	"[4400,1]"\
	"[4500,1]"\
	"[4600,1]"\
	"[4700,1]"\
	"[4800,1]"\
	"[4900,1]"\
	"[4000,1]"\
	"[5100,1]"\
	"[5200,1]"\
	"[5300,1]"\
	"[5400,1]"\
	"[5500,1]"\
	"[5600,1]"\
	"[5700,1]"\
	"[5800,1]"\
	"[5900,1]"\
	"[6000,1]"\
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
	"[2,2,2,2,2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2,2,2,2,2]"\
	"[8192]"\
	"[128,64]"\
	"[32,16,16]"\
	"[16,8,8,8]"\
	"[8,8,8,4,4]"\
	"[8,4,4,4,4,4]"\
	"[4,4,4,4,4,4,2]"\
	"[4,4,4,4,4,2,2,2]"\
	"[4,4,4,4,2,2,2,2,2]"\
	"[4,4,4,2,2,2,2,2,2,2]"\
	"[4,4,2,2,2,2,2,2,2,2,2]"\
	"[4,2,2,2,2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2,2,2,2,2]"\
	"[2]"\
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
	"[4096]"\
	"[8192]"\
	"[7,6,5,4,3,2,1]"\
	"[1,2,3,4,5,6,7]"
