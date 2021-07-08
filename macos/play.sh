#!/bin/sh
#
# https://github.com/dehesselle/chatty
#
# This is the main control script. It sources the scripts to handle the
# supported players.
#

#--- environment ---------------------------------------------------------------

RESOURCES_DIR=$(dirname $0)/..
SCRIPTS_DIR=$RESOURCES_DIR/scripts
CONFIG_DIR=$HOME/Library/Application\ Support/Chatty
ARGS="$*"                    # e.g. 'twitch.tv/channelname best'
STREAM=${ARGS#*twitch.tv/}   # remove all chars before 'channelname'
STREAM=${STREAM% *}          # remove all args after 'channelname'
QUALITY=${ARGS#*$STREAM}     # retain quality argument after 'channelname'

#--- main ----------------------------------------------------------------------

if [ ! -f "$CONFIG_DIR/no_vlc" ]; then
   source $SCRIPTS_DIR/streamlink_vlc.sh
fi

if [ ! -f "$CONFIG_DIR/no_iina" ]; then
   source $SCRIPTS_DIR/iina.sh
fi

# On newer macOS versions, this will trigger a security dialag, asking for
# permission to access system events.
osascript <<EOT
   tell app "System Events"
      display dialog "Could not find a supported app for video playback. Either install IINA or VLC." buttons {"OK"} default button 1 with icon caution with title "no supported video player"
      return
   end tell
EOT

