#!/usr/bin/env bash
#
# https://github.com/dehesselle/chatty
#
# This script builds Chatty.app on macOS.
#
# Prerequisites:
#  - Specify macOS version and SDK location (see MACOSX_DEPLOYMENT_TARGET
#    and SDKROOT below). If you don't care about backward compatibility,
#    remove those two exports to build for your current platform.
#  - You need to have Gradle installed (https://gradle.org/). 'gradlew'
#    must be accessible in your PATH.
#  - You need to have Java JDK 14 or later installed.
#
# Descriptions of build steps:
#  - source external script 'version.sh' to set version from git tag
#  - create a 1 GiB ramdisk named 'WRKSPC' as build directory
#  - copy repository to build directory
#  - build release jar using 'gradlew'
#  - download a precompiled Python 3 framework
#  - download Streamlink (incl. dependencies)
#  - use 'jpackage' to create application bundle around jar file
#  - copy Python and Streamlink to application bundle
#  - copy launch scripts (for Streamlink+VLC and IINA) to application bundle
#  - copy all resources (images, sounds) to application bundle
#  - modify settings in 'Info.plist'
#
# Final remarks:
#  - This script does its job without any bells and whistles. It does not
#    catch errors or give meaningful error messages, it'll just break.
#

### general settings ###########################################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
REPO_DIR=$SELF_DIR/..
. $REPO_DIR/macos/version.sh   # include version information

if [ "$(uname -p)" = "arm" ]; then
  export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.3.sdk
else
  export SDKROOT=/opt/sdks/MacOSX10.11.sdk
fi

MACOSX_DEPLOYMENT_TARGET=$(/usr/libexec/PlistBuddy -c "Print :DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)
export MACOSX_DEPLOYMENT_TARGET

set -e

### create ramdisk as workspace ################################################

RAMDISK_VOL=WRKSPC
diskutil erasevolume HFS+ "$RAMDISK_VOL" $(hdiutil attach -nomount ram://2097152)
WORK_DIR=/Volumes/$RAMDISK_VOL

### build Chatty jar ###########################################################

cd $WORK_DIR
cp -r "$REPO_DIR" $WORK_DIR/chatty
cd chatty
./gradlew release

### download Python 3 framework ################################################

PY3_MAJOR=3
PY3_MINOR=9

cd $WORK_DIR
curl -L https://gitlab.com/dehesselle/python_macos/-/jobs/artifacts/master/raw/python_$PY3_MAJOR${PY3_MINOR}_$(uname -p).tar.xz?job=python$PY3_MAJOR$PY3_MINOR:$(uname -p) | tar -xp
xattr -r -d com.apple.quarantine Python.framework

export PYTHONPYCACHEPREFIX=$WORK_DIR   # redirect cache files

### download Streamlink ########################################################

STREAMLINK_VER=2.2.0
STREAMLINK_DIR=$WORK_DIR/streamlink
export PATH=$WORK_DIR/Python.framework/Versions/Current/bin:$PATH
pip3 install --prefix=$STREAMLINK_DIR --ignore-installed streamlink==$STREAMLINK_VER

sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/chardetect
sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/streamlink
sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/wsdump.py

### package jar into application bundle ########################################

cd $WORK_DIR
mkdir -p package/macosx
cp $REPO_DIR/macos/Chatty.icns package/macosx
$(/usr/libexec/java_home)/bin/jpackage \
  --icon $REPO_DIR/macos/Chatty.icns \
  --input $WORK_DIR/chatty/build/libs \
  --mac-package-identifier dehesselle.Chatty \
  --main-jar Chatty.jar \
  --name Chatty \
  --type app-image

### copy stuff to application bundle ###########################################

FRAMEWORKS_DIR=$WORK_DIR/Chatty.app/Contents/Frameworks
mkdir -p $FRAMEWORKS_DIR
mv $WORK_DIR/Python.framework $FRAMEWORKS_DIR

RESOURCE_DIR=$WORK_DIR/Chatty.app/Contents/Resources
cp -r $STREAMLINK_DIR $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/img $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/sounds $RESOURCE_DIR
cp    $WORK_DIR/chatty/macos/LICENSE.txt $RESOURCE_DIR

SCRIPTS_DIR=$RESOURCE_DIR/scripts
mkdir $SCRIPTS_DIR
cp $REPO_DIR/macos/streamlink_vlc.sh $SCRIPTS_DIR
cp $REPO_DIR/macos/iina.sh $SCRIPTS_DIR
cp $REPO_DIR/macos/play.sh $SCRIPTS_DIR

### modify plist settings ######################################################

INFO_PLIST=$WORK_DIR/Chatty.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $CHATTY_VERSION" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $CHATTY_MACOS_BUILD" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set LSApplicationCategoryType public.app-category.social-networking" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set LSMinimumSystemVersion $MACOSX_DEPLOYMENT_TARGET" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set NSHumanReadableCopyright 'Copyright © 2013-2021 by tduva'" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSRequiresAquaSystemAppearance bool false" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSSupportsAutomaticGraphicsSwitching bool true" $INFO_PLIST

### Tada! ######################################################################

echo "Build complete.=========================================================="
echo "$WORK_DIR/Chatty.app"
