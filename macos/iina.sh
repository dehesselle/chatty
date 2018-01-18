# https://github.com/dehesselle/chatty
#
# A wrapper script to use IINA as video player.

#--- environment ---------------------------------------------------------------

IINA=/Applications/IINA.app/Contents/MacOS/iina-cli

OK=true

#--- functions -----------------------------------------------------------------

function get_format
{
   local quality=$1

   case $quality in
      best)
         $(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM |
grep 'mp4' | grep -v 'audio only' | awk '{ print $1 }' | tail -r | head -1
         ;;
      worst)
         $(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM |
grep 'mp4' | grep -v 'audio only' | awk '{ print $1 }' | head -1
         ;;
      "")
         quality="Available streams: "
         
         for item in  $($(dirname $IINA)/youtube-dl --list-formats https://www.twitch.tv/$STREAM |
            grep 'mp4' | awk '{ print $1 }'); do
            quality="$quality $item,"
         done
         
         quality="${quality%??????????}"
         echo $quality
         ;;
      *)
         echo $quality
         ;;
   esac
}

#--- main ----------------------------------------------------------------------

if [ -f $IINA ]; then
   OK=true
elif [ -f $HOME/$IINA ]; then
   IINA=$HOME/$IINA
   OK=true
else
   OK=false
fi

if $OK; then
   if [ -z "$QUALITY" ]; then
      get_format ""
   else
      $IINA --mpv-ytdl-format=$(get_format $QUALITY) https://www.twitch.tv/$STREAM
   fi
   exit 0
fi
