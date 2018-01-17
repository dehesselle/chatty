# https://github.com/dehesselle/chatty
#
# A wrapper script to use VLC as videoplayer (in conjunction with Streamlink).

#--- environment ---------------------------------------------------------------

STREAMLINK_DIR=$RESOURCES_DIR/streamlink

export PYTHONPATH=$STREAMLINK_DIR/lib/python2.7/site-packages

VLC=/Applications/VLC.app/Contents/MacOS/VLC

#--- main ----------------------------------------------------------------------

if [ -f $VLC ]; then
   $STREAMLINK_DIR/bin/streamlink -p "$VLC --meta-title $STREAM" twitch.tv/$STREAM $QUALITY
   exit 0
elif [ -f $HOME/$VLC ]; then
   VLC=$HOME/$VLC
   $STREAMLINK_DIR/bin/streamlink -p "$VLC --meta-title $STREAM" twitch.tv/$STREAM $QUALITY
   exit 0
fi
