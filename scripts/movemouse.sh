#!/usr/local/bin/bash
#script using xdotool mousemove to move the mouse when im not at my computer watching something.
declare -i ON
ON=0
	while sleep 600; do
	if (( $ON==1 )); then 
		xdotool mousemove 600 600
		ON=0
		echo $ON
	elif (( $ON==0 )); then
		xdotool mousemove 500 500
		ON=1
		echo $ON
	fi
done
