#!/bin/bash
if [ "$1" == "join" ]
then
    coffee -j js/wilt.js -w -c \
	   src/*.coffee \
	   src/test/old/*.coffee \
	   src/test/old/grow/*.coffee \
	   src/test/sad/*.coffee
else
    coffee -w -c -o js \
	   src/*.coffee \
	   src/test/old/*.coffee \
	   src/test/old/grow/*.coffee \
	   src/test/sad/*.coffee
fi
