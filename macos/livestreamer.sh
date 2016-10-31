#!/bin/sh
#
# https://github.com/dehesselle/chatty
#
# This is a wrapper script to launch Streamlink and VLC.
#

#--- setup environment
ARGS="$*"
STREAMLINK_DIR=$(dirname $0)/..
STREAM=${ARGS#twitch.tv/}
STREAM=${STREAM% *}
export PYTHONPATH=$STREAMLINK_DIR/lib/python2.7/site-packages
VLC=/Applications/VLC.app/Contents/MacOS/VLC

#--- start streamlink+VLC
if [ ! -f $VLC ]; then
   osascript <<EOT
      tell app "System Events"
         display dialog "Could not find VLC in the system's application folder." buttons {"OK"} default button 1 with icon caution with title "VLC not found"
         return
      end tell
EOT
else
   $STREAMLINK_DIR/bin/streamlink -p "/Applications/VLC.app/Contents/MacOS/VLC --meta-title $STREAM" $ARGS
fi
