#!/bin/bash
if [ "$1" == "join" ]
then
    coffee -j js/wilt.js -w -c \
	   src/*.coffee \
	   src/test/*.coffee \
	   src/test/grow/*.coffee
else
    coffee -w -c -o js \
	   src/*.coffee \
	   src/test/*.coffee \
	   src/test/grow/*.coffee
fi
