#!/usr/local/bin/bash

MOUSEMOVEKILL=`ps ax | grep "./movemouse.sh" | grep -v "grep" | awk '{ print $1 }'`
echo $MOUSEMOVEKILL
kill $MOUSEMOVEKILL
