#!/bin/bash 

# copyright (c) Tessella 2014

# This script install sscan 2.9
# It assumes EPICS base is already installed and that
# the environment variable EPICS_ROOT is set and points to the installation directory.
#
# Usage:
# sudo -s
# source ./epics_sscan_2-9_install.sh

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
# seq
if [ ! -d $EPICS_ROOT/support/seq ]; 
then
    echo "It seems seq is not installed. Please install it first and try again."
    exit 1
fi

# sscan
SSCAN_DOWNLOAD="sscan_R2-9.tar.gz"
SSCAN_DIRECTORY="sscan-2-9"
wget --tries=3 --timeout=10 http://www.aps.anl.gov/bcda/synApps/tar/$SSCAN_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/sscan
mkdir -p $SUPPORT_PATH
tar xzvf $SSCAN_DOWNLOAD -C $SUPPORT_PATH
rm $SSCAN_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$SSCAN_DIRECTORY $SUPPORT_PATH/current

# hack the 'RELEASE' file to put the settings we want.
chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "/^SUPPORT\s*=/ s,=.*,=$EPICS_ROOT/support," $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=$EPICS_ROOT/base," $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "/^SNCSEQ\s*=/ s,=.*,=$EPICS_ROOT/support/seq/current," $SUPPORT_PATH/current/configure/RELEASE
    
# build
make -C $SUPPORT_PATH/current install

