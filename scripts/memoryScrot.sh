#!/usr/local/bin/bash
#script for taking weekly memory screenshots
#like a memory bank! run using crontab
#watch out carefully for all that porn

SCROTDIR=~/pictures/scrots
SCROT="`date | sed -e "s/[[:space:]]/_/g"`.jpg"
if [ -d "$SCROTDIR" ]; then
	echo "$SCROTDIR exists"
	
	if [ -f "$SCROTDIR/$SCROT" ]; then
		echo "File already exists"
	else
		scrot "$SCROTDIR/$SCROT"
	fi
else
	echo "$SCROTDIR does not exist"
fi
