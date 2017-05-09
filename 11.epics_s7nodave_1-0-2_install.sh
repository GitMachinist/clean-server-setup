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
# asyn
if [ ! -d $EPICS_ROOT/support/asyn ];
then
    echo "It seems asyn is not installed. Please install it first and try again."
    exit 1
fi

# s7nodave
S7_DOWNLOAD="s7nodave-1.0.2.tar.gz"
S7_DIRECTORY="s7nodave-1.0.2"
wget --tries=3 --timeout=10  http://oss.aquenos.com/epics/s7nodave/download/$S7_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/s7nodave
mkdir -p $SUPPORT_PATH
tar xzvf $S7_DOWNLOAD -C $SUPPORT_PATH
rm $S7_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$S7_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|#SNCSEQ=$(EPICS_BASE)/../modules/soft/seq|SNCSEQ=/usr/local/epics/support/seq/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|#ASYN=/opt/epics/modules/synApps_5_5/support/asyn-4-13|ASYN=/usr/local/epics/support/asyn/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|#EPICS_BASE=/opt/epics/base-3.14.12|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install
