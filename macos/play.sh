#!/bin/sh
#
# https://github.com/dehesselle/chatty
#
# This is the main control script. It sources the scripts to handle the
# supported players.
#

#--- environment ---------------------------------------------------------------

RESOURCES_DIR=$(dirname $0)/..
PYTHON_BIN_DIR=$RESOURCES_DIR/../Frameworks/Python.framework/Versions/Current/bin
SCRIPTS_DIR=$RESOURCES_DIR/scripts
ARGS="$*"                   # e.g. 'twitch.tv/channelname best'
STREAM=${ARGS#twitch.tv/}   # remove all chars before 'channelname'
STREAM=${STREAM% *}         # remove all args after 'channelname'
QUALITY=${ARGS#*$STREAM}    # retain quality argument after 'channelname'

#--- main ----------------------------------------------------------------------

source $SCRIPTS_DIR/iina.sh
source $SCRIPTS_DIR/streamlink_vlc.sh

osascript <<EOT
   tell app "System Events"
      display dialog "Could not find a supported app for video playback. Either install IINA or VLC." buttons {"OK"} default button 1 with icon caution with title "no supported video player"
      return
   end tell
EOT

