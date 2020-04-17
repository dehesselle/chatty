#!/usr/bin/env bash
#
# https://github.com/dehesselle/chatty
#
# This script builds Chatty.app for macOS.
#
# In short, this script does the following:
#  - create a 2 GiB ramdisk as build directory
#  - copy repository to build directory
#  - build release using 'gradle'
#  - download Python 3 framework
#  - download Streamlink, copy launch scripts for VLC and IINA
#  - create native application bundle using 'javapackager'
#  - copy all resources to the 'Resources' folder
#  - modify version numbers in 'Info.plist'
#
# If you want to do this yourself, please take note:
#  - You need a working installation of 'gradle' in your PATH.
#  - This script does its job without any bells and whistles. It does not
#    catch errors or give meaningful error messages, it'll just break.
#

#--- general settings
SELF_DIR=$(cd $(dirname "$0"); pwd -P)
REPO_DIR=$SELF_DIR/..
. $REPO_DIR/macos/version.sh   # include version information

export MACOSX_DEPLOYMENT_TARGET=10.9
export SDKROOT=/opt/sdks/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk

set -e

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
PY3_MAJOR=3
PY3_MINOR=8
PY3_PATCH=2
PY3_BUILD=3   # custom framework build number

cd $WORK_DIR
curl -L https://github.com/dehesselle/py3framework/releases/download/py$PY3_MAJOR$PY3_MINOR$PY3_PATCH.$PY3_BUILD/py$PY3_MAJOR$PY3_MINOR${PY3_PATCH}_framework_$PY3_BUILD.tar.xz | tar -xJp --exclude="Versions/$PY3_MAJOR.$PY3_MINOR/lib/python$PY3_MAJOR.$PY3_MINOR/test/"'*'

#--- download Streamlink
STREAMLINK_VER=1.3.1
STREAMLINK_DIR=$WORK_DIR/streamlink
export PATH=$WORK_DIR/Python.framework/Versions/Current/bin:$PATH
pip3 install --install-option="--prefix=$STREAMLINK_DIR" --ignore-installed streamlink==$STREAMLINK_VER

sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/chardetect
sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/streamlink
sed -i '' "1s/.*/#!\/usr\/bin\/env python$PY3_MAJOR.$PY3_MINOR\
/" $STREAMLINK_DIR/bin/wsdump.py

#--- build macOS app
cd $WORK_DIR
mkdir -p package/macosx
cp $REPO_DIR/macos/Chatty.icns package/macosx
javapackager -deploy -native image -srcdir $WORK_DIR/chatty/build/libs -srcfiles Chatty.jar -appclass chatty.Chatty -name Chatty -outdir $WORK_DIR/deploy -outfile Chatty -v -nosign

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
/usr/libexec/PlistBuddy -c "Set LSApplicationCategoryType public.app-category.social-networking" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set LSMinimumSystemVersion $MACOSX_DEPLOYMENT_TARGET" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Set NSHumanReadableCopyright 'Copyright © 2013-2020 by tduva'" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSRequiresAquaSystemAppearance bool false" $INFO_PLIST
/usr/libexec/PlistBuddy -c "Add NSSupportsAutomaticGraphicsSwitching bool true" $INFO_PLIST

echo "Build complete.=========================================================="
echo "$WORK_DIR/deploy/Chatty.app"
