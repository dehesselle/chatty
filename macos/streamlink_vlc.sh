# https://github.com/dehesselle/chatty
#
# A wrapper script to use VLC as videoplayer in conjunction with Streamlink.

#--- environment ---------------------------------------------------------------

STREAMLINK_DIR=$RESOURCES_DIR/streamlink

export PYTHONPATH=$(echo $STREAMLINK_DIR/lib/python*/site-packages)

VLC=/Applications/VLC.app/Contents/MacOS/VLC

OK=true

#--- main ----------------------------------------------------------------------

if [ -f $VLC ]; then
  OK=true
elif [ -f $HOME/$VLC ]; then
  VLC=$HOME/$VLC
  OK=true
else
  OK=false
fi

if $OK; then
  export PATH=$PYTHON_BIN_DIR:$PATH

  export PYTHONPYCACHEPREFIX=$HOME/Library/Caches/Chatty
  if [ ! -d $PYTHONPYCACHEPREFIX ]; then
    mkdir $PYTHONPYCACHEPREFIX
  fi

  $STREAMLINK_DIR/bin/streamlink --player $VLC --title {title} https://twitch.tv/$STREAM $QUALITY
  exit 0
fi
