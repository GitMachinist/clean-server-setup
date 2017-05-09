#!/bin/bash 

# Copyright (c) Tessella 2014

# This script install asyn 4.21
# It assumes EPICS base is already installed and that
# the environment variable EPICS_ROOT is set and points to the installation directory.
#
# Usage:
# sudo -s
# source ./epics_asyn_4-21_install.sh

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

# asyn
ASYN_DOWNLOAD="asyn4-21.tar.gz"
ASYN_DIRECTORY="asyn4-21"
wget --tries=3 --timeout=10  http://www.aps.anl.gov/epics/download/modules/$ASYN_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/asyn
mkdir -p $SUPPORT_PATH
tar xzvf $ASYN_DOWNLOAD -C $SUPPORT_PATH
rm $ASYN_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$ASYN_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SUPPORT=/corvette/home/epics/devel|SUPPORT=$EPICS_ROOT/support|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/corvette/usr/local/epics/base-3.14.12.3|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e 's\SNCSEQ=$(SUPPORT)/seq-2-1-10\SNCSEQ=$(SUPPORT)/seq/current\g' $SUPPORT_PATH/current/configure/RELEASE
sed -i -e 's\IPAC=$(SUPPORT)/ipac-2-11\#IPAC=$(SUPPORT)/ipac/current\g' $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install



