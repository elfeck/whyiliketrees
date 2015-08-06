#!/bin/bash
if [ "$1" == "join" ]
then
    coffee -j js/wilt.js -w -c \
	   src/*.coffee \
	   src/test/*.coffee \
	   src/spiky/*.coffee
else
    coffee -w -c -o js \
	   src/*.coffee \
	   src/test/*.coffee \
	   src/spiky/*.coffee
fi
