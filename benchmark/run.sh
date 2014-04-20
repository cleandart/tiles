#!/bin/bash

########################################################################
#                                                                      #
#    To run this script, content_shell must be in the path,            #
#    and dart editor running with tiles as one of the root folders.    #
#                                                                      #
########################################################################

. ./bin/functions.sh --source-only

DIR=$(dirname $0)

STARTTIME=$(date +%s);

runner () {
	content_shell --dump-render-tree \
		"http://127.0.0.1:3030/tiles/benchmark/runner.html#{\"levels\":$2,\"library\":\"$1\",\"environment\":\"$3\"}" 2> /dev/null \
	| grep "CONSOLE"\
	| sed "s/^CONSOLE MESSAGE: line [0-9]*: //g"
}

tiles () {
	for i in "$@"
	do
		printf "tiles $i: ";
		runner tiles $i "DOM";
	done
}

react () {
	for i in "$@"
	do
		printf "react $i: ";
		runner react $i "DOM";
	done
}

tiles_virtual () {
	for i in "$@"
	do
		printf "tiles virtual $i: ";
		runner tiles $i "virtual";
	done
}

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

tiles_virtual_analyze () {
	echo "$(green)tiles_virtual$(white)" 1>&2;
	tiles_virtual \
		"[5040]         "\
		"[5040,1]       "\
		"[504,10]       "\
		"[50,10,10]     "\
		"[50,10,5,2]    "\
		"[10,10,5,5,2]  "\
		"[10,5,5,5,2,2] "\
		"[7,6,5,4,3,2,1]"
}

tiles_mass_vs_structure
react_mass_vs_structure
tiles_virtual_analyze

