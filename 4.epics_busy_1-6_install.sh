#!/bin/bash 

# copyright (c) Tessella 2014

# This script install busy 1.6
# It assumes EPICS base is already installed and that
# the environment variable EPICS_ROOT is set and points to the installation directory.
#
# Usage:
# sudo -s
# source ./epics_busy_1-6_install.sh

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

# busy
BUSY_DOWNLOAD="busy_R1-6.tar.gz"
BUSY_DIRECTORY="busy-1-6"
wget --tries=3 --timeout=10  http://www.aps.anl.gov/bcda/synApps/tar/$BUSY_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/busy
mkdir -p $SUPPORT_PATH
tar xzvf $BUSY_DOWNLOAD -C $SUPPORT_PATH
rm $BUSY_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$BUSY_DIRECTORY $SUPPORT_PATH/current

# hack the 'RELEASE' file to put the settings we want.
chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SUPPORT=/corvette/home/epics/devel|SUPPORT=$EPICS_ROOT/support|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|ASYN=\$(SUPPORT)/asyn-4-17|ASYN=\$(SUPPORT)/asyn/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/corvette/usr/local/epics/base-3.14.12.1|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install

