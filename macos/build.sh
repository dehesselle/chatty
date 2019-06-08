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

export MACOSX_DEPLOYMENT_TARGET=10.12

#--- create temporary workspace
RAMDISK_VOL=WRKSPC
diskutil erasevolume HFS+ "$RAMDISK_VOL" $(hdiutil attach -nomount ram://2097152)
WORK_DIR=/Volumes/$RAMDISK_VOL

#--- build chatty
cd $WORK_DIR
cp -r $REPO_DIR $WORK_DIR/chatty
cd chatty
./gradlew release

#--- download Python.framework
cd $WORK_DIR
curl -L https://github.com/dehesselle/py3framework/releases/download/py368.1/py368_framework_1.tar.xz | tar xJp

#--- download Streamlink
STREAMLINK_DIR=$WORK_DIR/streamlink
export PATH=$WORK_DIR/Python.framework/Versions/Current/bin:$PATH
pip3 install --install-option="--prefix=$STREAMLINK_DIR" --ignore-installed streamlink

sed -i '' '1s/.*/#!\/usr\/bin\/env python3.6\
/' $STREAMLINK_DIR/bin/chardetect
sed -i '' '1s/.*/#!\/usr\/bin\/env python3.6\
/' $STREAMLINK_DIR/bin/streamlink
sed -i '' '1s/.*/#!\/usr\/bin\/env python3.6\
/' $STREAMLINK_DIR/bin/wsdump.py

#--- build macOS app
cd $WORK_DIR
mkdir -p package/macosx
cp $REPO_DIR/macos/Chatty.icns package/macosx
javapackager -deploy -native image -srcdir $WORK_DIR/chatty/build/libs -srcfiles Chatty.jar -appclass chatty.Chatty -name Chatty -outdir $WORK_DIR/deploy -outfile Chatty -v

FRAMEWORKS_DIR=$WORK_DIR/deploy/Chatty.app/Contents/Frameworks
mkdir -p $FRAMEWORKS_DIR
mv $WORK_DIR/Python.framework $FRAMEWORKS_DIR

RESOURCE_DIR=$WORK_DIR/deploy/Chatty.app/Contents/Resources
cp -r $STREAMLINK_DIR $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/img $RESOURCE_DIR
cp -r $WORK_DIR/chatty/assets/sounds $RESOURCE_DIR
cp    $WORK_DIR/chatty/macos/LICENSE.txt $RESOURCE_DIR

SCRIPTS_DIR=$RESOURCE_DIR/scripts
mkdir $SCRIPTS_DIR
cp $REPO_DIR/macos/streamlink_vlc.sh $SCRIPTS_DIR
cp $REPO_DIR/macos/iina.sh $SCRIPTS_DIR
cp $REPO_DIR/macos/play.sh $SCRIPTS_DIR

INFO_PLIST=$WORK_DIR/deploy/Chatty.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $CHATTY_VERSION" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $CHATTY_MACOS_BUILD" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set NSHumanReadableCopyright 'Copyright (c) 2013-2019 by tduva'" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSSupportsAutomaticGraphicsSwitching bool true" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set LSMinimumSystemVersion 10.12" $INFO_PLIST

echo "Build complete."
echo "$WORK_DIR/deploy/Chatty.app"
