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

# asyn
MODBUS_DOWNLOAD="modbusR2-4.tgz"
MODBUS_DIRECTORY="modbusR2-4"
wget --tries=3 --timeout=10  http://cars.uchicago.edu/software/pub/$MODBUS_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/modbus
mkdir -p $SUPPORT_PATH
tar xzvf $MODBUS_DOWNLOAD -C $SUPPORT_PATH
rm $MODBUS_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$MODBUS_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SUPPORT=/corvette/home/epics/devel|SUPPORT=$EPICS_ROOT/support|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|ASYN=\$(SUPPORT)/asyn-4-19|ASYN=\$(SUPPORT)/asyn/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/corvette/usr/local/epics/base-3.14.12.2|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install
