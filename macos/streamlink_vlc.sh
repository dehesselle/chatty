# https://github.com/dehesselle/chatty
#
# A wrapper script to use VLC as videoplayer in conjunction with Streamlink.

#--- environment ---------------------------------------------------------------

PYTHON_BIN_DIR=$RESOURCES_DIR/../Frameworks/Python.framework/Versions/Current/bin
export PATH=$PYTHON_BIN_DIR:$PATH

STREAMLINK_DIR=$RESOURCES_DIR/streamlink
export PYTHONPATH=$(echo $STREAMLINK_DIR/lib/python*/site-packages)

export PYTHONPYCACHEPREFIX=$HOME/Library/Caches/Chatty

VLC=/Applications/VLC.app/Contents/MacOS/VLC

#--- main ----------------------------------------------------------------------

if   [ -x $VLC ]; then
  :
elif [ -x $HOME/$VLC ]; then
  VLC=$HOME/$VLC
else
  VLC=/doesnotexist
fi

if [ -x $VLC ]; then
  $STREAMLINK_DIR/bin/streamlink --player $VLC --title {title} https://twitch.tv/$STREAM $QUALITY
  exit 0
fi
