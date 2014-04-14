#!/bin/bash

. ./bin/functions.sh --source-only

DIR=$(dirname $0)

STARTTIME=$(date +%s);

startStopWatch() {
	STARTTIME=$(date +%s%N);
}

stopStopWatch() {
	ENDTIME=$(date +%s%N)
	DURATION=$(($ENDTIME-$STARTTIME))

	MILISECONDS=$(($DURATION/1000000))
	SECONDS=$(($MILISECONDS/1000))
	echo "Time needed: $(yellow)$SECONDS$(white) sedonds and $(yellow)$MILISECONDS$(white) miliseconds"
}

run () {
	./content_shell --dump-render-tree benchmark/$1.html 2>&1
}

analyze() {
	startStopWatch;

	RESULT=$(run $1);
	echo "number of linex in $(green)$1$(white) is $(yellow)`echo "$RESULT" | wc -l`$(white)";

	stopStopWatch;
}

analyze mass_react;

analyze mass_tiles;

analyze structure_tiles;

analyze structure_react;

