#!/usr/bin/env bash
#
# https://github.com/dehesselle/chatty
#
# This script builds Chatty.app for macOS (on macOS!).
#
# In short, this script does the following:
#  - create a 512 MiB ramdisk as build directory
#  - copy repository to build directory
#  - build release using 'gradlew'
#  - download Streamlink, copy launch script 'streamlink_vlc.sh'
#  - create native application bundle using 'javapackager'
#  - copy all resources to the 'Resources' folder
#  - modify version numbers in 'Info.plist'
#
# If you want to do this yourself, please take note:
#  - You need a working installation of 'gradle' in your $PATH.
#  - You need GNU-readlink, 'greadlink',  e.g. via 'coreutils' from homebrew.
#  - This script does its job without a lot of bells and whistles. It does not
#    catch errors or give meaningful error messages, it'll just break.
#

#--- general settings
REPO_DIR=$(dirname $(greadlink -f $0))/..
. $REPO_DIR/macos/version.sh   # include version information

#--- create temporary workspace
RAMDISK_VOL=WRKSPC
diskutil erasevolume HFS+ "$RAMDISK_VOL" $(hdiutil attach -nomount ram://1048576)
WORK_DIR=/Volumes/$RAMDISK_VOL

#--- build chatty
cd $WORK_DIR
cp -r $REPO_DIR $WORK_DIR/chatty
cd chatty
./gradlew release

#--- download Streamlink
SITE_PKG_DIR=$WORK_DIR/pip/lib/python2.7/site-packages
STREAMLINK_DIR=$WORK_DIR/streamlink
PIP_DIR=$WORK_DIR/pip
mkdir -p $SITE_PKG_DIR
export PYTHONPATH=$SITE_PKG_DIR
easy_install --prefix=$PIP_DIR pip
$PIP_DIR/bin/pip install --install-option="--prefix=$STREAMLINK_DIR" --ignore-installed streamlink
cp $REPO_DIR/macos/streamlink_vlc.sh $STREAMLINK_DIR/bin/streamlink_vlc.sh

#--- build macOS app
cd $WORK_DIR
mkdir -p package/macosx
cp $REPO_DIR/macos/Chatty.icns package/macosx
javapackager -deploy -native image -srcfiles $WORK_DIR/chatty/build/libs/Chatty.jar -appclass chatty.Chatty -name Chatty -outdir $WORK_DIR/deploy -outfile Chatty -v

RESOURCE_DIR=$WORK_DIR/deploy/bundles/Chatty.app/Contents/Resources
cp -r $STREAMLINK_DIR $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/img $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/sounds $RESOURCE_DIR
cp    $WORK_DIR/chatty/LICENSE.txt $WORK_DIR/deploy/bundles/Chatty.app/Contents

INFO_PLIST=$WORK_DIR/deploy/bundles/Chatty.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $CHATTY_VERSION" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $CHATTY_MACOS_BUILD" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set NSHumanReadableCopyright 'Copyright (c) 2013-2017 by tduva'" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSSupportsAutomaticGraphicsSwitching bool true" $INFO_PLIST

echo "Build complete."
echo "$WORK_DIR/deploy/bundles/Chatty.app"
