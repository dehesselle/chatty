# Chatty for macOS

![alt-text](/macos/app_dock.png)

Being a fan of [Chatty](http://chatty.github.io) myself, I wanted it to be a bit more Mac-like on macOS. The main goal was to create a self-contained app that doesn't require external 3rd party software/runtimes.

Since I don't speak Java I won't be coding new features besides making little changes here and there.

## Features

System theme |  Hifi Soft (Dark) theme
:-------------------------:|:-------------------------:
![alt-text](/macos/app_screenshot.png) | ![alt-text](/macos/app_screenshot2.png)

This is Chatty as you know and like it, but with a few additions:

- packaged as native macOS app, signed & notarized
- includes [Java Runtime](https://adoptopenjdk.net)
- includes [Python](https://www.python.org) to power the included [Streamlink](https://streamlink.github.io)

In essence: you don't need to have Java installed to run Chatty and you can watch Streams as long as you have [IINA](https://github.com/iina/iina) or [VLC](http://www.videolan.org) in your `/Applications` folder.

## Download

Check the [releases](https://github.com/dehesselle/chatty/releases) page!

## Build

You can build app yourself using `macos/build.sh`.  At this time, the only available documentation about the build process is the script itself.

## Credits

This wouldn't have been possible without the work of other people. Thank you:

- [tduva](https://github.com/tduva) and all people contributing to [Chatty](http://chatty.github.io)
- [chrippa](https://github.com/chrippa) and all people who have contributed to [Livestreamer](http://livestreamer.io)
- all people contributing to [Streamlink](https://streamlink.github.io)
- all the authors of the various Python libraries pulled in as dependencies 

## License

See [LICENSE.txt](macos/LICENSE.txt).
