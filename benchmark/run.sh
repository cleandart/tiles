#!/bin/bash

########################################################################
#                                                                      #
#    To run this script, content_shell must be in the path,            #
#    and dart editor running with tiles as one of the root folders.    #
#                                                                      #
########################################################################

. ./bin/functions.sh --source-only

JS=0;
RUNCOUNT=5;

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

get_nth_if_lower () {
	ORIGIN=$(echo $1)
	POSITION=$(echo $2)
	ATPOS=$(echo $ORIGIN | cut -d , -f $POSITION)
	COMPARISON=$(echo $3)
	if [ "$COMPARISON" -eq 0 ];
	then
		echo $ATPOS;
	else
		if [ $COMPARISON -gt $ATPOS ]
		then
			echo $ATPOS;
		else
			echo $COMPARISON;
		fi
	fi
}

# arguments: library, levels
analyze () {
	DOM=0
	RENDERALL=0
	UPDATECLEAN=0
	VIRTUAL=0
	UPDATEDIRTY=0
	for i in $(seq 1 $RUNCOUNT)
	do

		# echo "$(yellow)run $i of $RUNCOUNT$(white)" 1>&2;
		RESULT=$(runner $1 $2 "false" "DOM");

		DOM=$(get_nth_if_lower $RESULT 1 $DOM)
		RENDERALL=$(get_nth_if_lower $RESULT 3 $RENDERALL)
		UPDATECLEAN=$(get_nth_if_lower $RESULT 4 $UPDATECLEAN)

		if [ "$1" = "tiles" ] 
		then
			RESULT=$(runner $1 $2 "false" "virtual");
			VIRTUAL=$(get_nth_if_lower $RESULT 2 $VIRTUAL)
		fi

		RESULT=$(runner $1 $2 "true" "DOM");
		UPDATEDIRTY=$(get_nth_if_lower $RESULT 5 $UPDATEDIRTY);
	done
	echo "$DOM;$VIRTUAL;$RENDERALL;$UPDATECLEAN;$UPDATEDIRTY";
}

# arguments: library, levels
analyze_js_and_dart () {
	JS=0;
	RESULTDART=$(analyze $1 $2);
	JS=1;
	RESULTJS=$(analyze $1 $2);
	JS=0;
	echo "$RESULTDART;$RESULTJS";
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
	"[2048]"\
	"[64,32]"\
	"[16,16,8]"\
	"[8,8,8,4]"\
	"[8,8,8,4]"\
	"[8,4,4,4,4]"\
	"[4,4,4,4,4,2]"\
	"[4,4,4,4,2,2,2]"\
	"[4,4,4,2,2,2,2,2]"\
	"[4,4,2,2,2,2,2,2,2]"\
	"[4,2,2,2,2,2,2,2,2,2]"\
	"[2,2,2,2,2,2,2,2,2,2,2]"\
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
	"[2048]"

