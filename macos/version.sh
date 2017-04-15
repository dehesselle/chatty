# https://github.com/dehesselle/chatty

GIT_DESCRIBE=$(git describe --always --tags)

if [[ "$GIT_DESCRIBE" =~ v(.*)_b([0-9]+).* ]]; then
   CHATTY_VERSION=${BASH_REMATCH[1]}
   CHATTY_MACOS_BUILD=${BASH_REMATCH[2]}
fi

echo "------------------------------"
echo "Chatty $CHATTY_VERSION (build $CHATTY_MACOS_BUILD)"
echo "------------------------------"
