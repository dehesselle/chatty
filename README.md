# Chatty for macOS
![alt-text](/macos/app_dock.png)
## About
Being a fan of Chatty myself, I wanted it to be a bit more Mac-like on macOS. The main goal was to create a self-contained app that doesn't require you to install any 3rd party software/runtimes.

This fork tries to diverge from the original Chatty as little as possible, taking only macOS specific changes into account that are necessary.

If you're completely new to Chatty, take a look at the [original readme](README-ORIGINAL.md).

## Features
This is Chatty as you know and like it, just with a few additions:
- macOS specific changes (e.g. paths, menubar)
- packaged as native macOS application bundle
- includes JRE
- includes Streamlink (successor to Livestreamer)

You don't need to install Java and you can even watch streams without having to install Livestreamer, as long as you have [VLC](http://www.videolan.org) in your `/Applications` folder.

![alt-text](/macos/app_screenshot.png)

## Download
Check the [releases](https://github.com/dehesselle/chatty/releases) page. I provide ready-to-use builds if you don't fancy doing it yourself.

## Build
You can build the standalone app yourself using `macos/build.sh`.
>TODO documentation

## Credits
This wouldn't have been possible without the work of other people. Thank you:

- [tduva](https://github.com/tduva) and all people contributing to [Chatty](http://chatty.github.io)
- all people contributing to [Streamlink](https://streamlink.github.io)
- [chrippa](https://github.com/chrippa) and all people who have contributed to [Livestreamer](http://livestreamer.io)
