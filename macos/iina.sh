# https://github.com/dehesselle/chatty
#
# A wrapper script to use IINA as video player.

#--- environment ---------------------------------------------------------------

IINA=/Applications/IINA.app/Contents/MacOS/iina-cli

#--- functions -----------------------------------------------------------------

function get_format
{
   local quality=$1

   local cmd="\
$(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM | \
tail -5 | grep -v 'audio only' | awk '{ print $1 }'"

   case $quality in
      best)
         $(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM |
grep 'mp4' | grep -v 'audio only' | awk '{ print $1 }' | sort -r | head -1
         ;;
      worst)
         $(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM |
grep 'mp4' | grep -v 'audio only' | awk '{ print $1 }' | sort | head -1
         ;;
      *)
         echo $quality
         ;;
   esac
}

#--- main ----------------------------------------------------------------------

if [ -f $IINA ]; then
   $IINA --mpv-ytdl-format=$(get_format $QUALITY) https://www.twitch.tv/$STREAM
   exit 0
elif [ -f $HOME/$IINA ]; then
   IINA=$HOME/$IINA
   $IINA --mpv-ytdl-format=$(get_format $QUALITY) https://www.twitch.tv/$STREAM
   exit 0
fi
