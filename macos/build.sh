#!/usr/bin/env bash
#
# https://github.com/dehesselle/chatty
#
# This script builds Chatty.app for macOS.
#
#  - create a 512 MiB ramdisk as build directory
#  - copy repository to build directory
#  - build release using 'gradlew'
#  - download Streamlink, copy launch script 'livestreamer'
#  - create native application bundle using 'javapackager'
#  - copy all resources to app's 'Resources' folder
#  - modify version numbers in 'Info.plist'
#
# Remarks (read: room for future improvements ;) )
#  - In its current state of development, this script won't run
#    out-of-the-box on your/any Mac. It depends on the the gnu-version of
#    'readlink' and 'gradle' needs a working Java installation.
#  - There's not really any kind of error-checking; this script will
#    not gracefully abort if something isn't right, it'll just break.
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
cp -r $REPO_DIR $WORK_DIR/chatty   # use local repository
#git clone https://github.com/dehesselle/chatty.git   # use remote repository
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
cp $REPO_DIR/macos/livestreamer.sh $STREAMLINK_DIR/bin/livestreamer

#--- build macOS app
cd $WORK_DIR
mkdir -p package/macosx
cp $REPO_DIR/macos/Chatty.icns package/macosx
javapackager -deploy -native image -srcfiles $WORK_DIR/chatty/build/libs/Chatty.jar -appclass chatty.Chatty -name Chatty -outdir $WORK_DIR/deploy -outfile Chatty -v

RESOURCE_DIR=$WORK_DIR/deploy/bundles/Chatty.app/Contents/Resources
cp -r $STREAMLINK_DIR $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/img $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/sounds $RESOURCE_DIR

INFO_PLIST=$WORK_DIR/deploy/bundles/Chatty.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $CHATTY_VERSION" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $CHATTY_MACOS_BUILD" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set NSHumanReadableCopyright 'Copyright (c) 2017 by tduva'" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSSupportsAutomaticGraphicsSwitching bool true" $INFO_PLIST

echo "Build complete."
echo "$WORK_DIR/deploy/bundles/Chatty.app"