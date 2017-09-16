# https://github.com/dehesselle/chatty


GIT_TAG=$(git tag --points-at HEAD | tail -n 1)

if [[ "$GIT_TAG" =~ v(.*)_b([0-9]+).* ]]; then
   CHATTY_VERSION=${BASH_REMATCH[1]}
   CHATTY_MACOS_BUILD=${BASH_REMATCH[2]}
else
   echo "***ERROR*** in version.sh"

   while true; do
      read -p "Do you want me to continue?" RESULT
      case $RESULT in
         [Yy]* ) CHATTY_VERSION=0; CHATTY_MACOS_BUILD=0; break ;;
         [Nn]* ) exit 1 ;;
         * ) echo "Please answer yes or no.";;
      esac
   done
fi

echo "------------------------------"
echo "Chatty $CHATTY_VERSION (build $CHATTY_MACOS_BUILD)"
echo "------------------------------"
