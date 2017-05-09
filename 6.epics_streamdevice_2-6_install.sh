#!/bin/bash 

# Copyright (c) Tessella 2014

# This script install streamdevice 2.6
# It assumes EPICS base is already installed and that
# + the environment variable EPICS_ROOT is set and points to the installation directory.
# + the environment variable EPICS_HOST_ARCH is set 
# and points to the correct architecture (e.g. 32 or 64 bit)
#
# Usage:
# sudo -s
# source ./epics_streamdevice_2-6_install.sh


# check if user has right permissions
if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root. Please try again using sudo."
	exit 1
fi

# check if script is being sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Sorry, the script is not being sourced. Please try again using '. $BASH_SOURCE'"
    exit 1
fi

# terminate script after first line that fails
set -e

# dependencies
# asyn
if [ ! -d $EPICS_ROOT/support/asyn ]; 
then
    echo "It seems asyn is not installed. Please install it first and try again."
    exit 1
fi

# streamdevice
STREAMDEVICE_DOWNLOAD="StreamDevice-2-6.tgz"
STREAMDEVICE_DIRECTORY="StreamDevice-2-6"
wget --tries=3 --timeout=10  http://epics.web.psi.ch/software/streamdevice/$STREAMDEVICE_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/stream
mkdir -p $SUPPORT_PATH
tar xzvf $STREAMDEVICE_DOWNLOAD -C $SUPPORT_PATH
rm -f $STREAMDEVICE_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current

ln -s $SUPPORT_PATH/$STREAMDEVICE_DIRECTORY $SUPPORT_PATH/current

#look at makefiles and change TOP to point to one level up
sed -i -e "/^TOP\s*=/ s,= ..,= .," $SUPPORT_PATH/current/Makefile
sed -i -e "/^TOP\s*=/ s,=../..,=..," $SUPPORT_PATH/current/src/Makefile
sed -i -e "/^TOP\s*=/ s,=../..,=..," $SUPPORT_PATH/current/srcSynApps/Makefile
sed -i -e "/^TOP\s*=/ s,=../..,=..," $SUPPORT_PATH/current/streamApp/Makefile

#make a configure folder
pushd $SUPPORT_PATH/current
yes | $EPICS_ROOT/base/bin/$EPICS_HOST_ARCH/makeBaseApp.pl -t support

# link asyn to stream device
echo -e ASYN=$EPICS_ROOT/support/asyn/current >> $SUPPORT_PATH/current/configure/RELEASE

#build it
make -C $SUPPORT_PATH/current/ install

popd

