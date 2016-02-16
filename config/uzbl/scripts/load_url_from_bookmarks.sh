#!/usr/local/bin/bash
bookmarks_file=~/.config/uzbl/bookmarks

COLORS=" -b -p web -nb "#000000" -nf "#383838" -sb "#383838" -sf "#ffffff""
#OPTIONS=" -i -xs -rs -l 10"

goto=`sort $bookmarks_file | dmenu $OPTIONS $COLORS | cut -d ' ' -f -100  | awk '{print $NF}'`

[ -n "$goto" ] && uzblctrl -s $5 -c "act uri $goto"

