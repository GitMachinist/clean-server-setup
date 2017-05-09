#!/bin/bash

# Copyright (c) HiLASE 2016
# script based on template maded by David Michel Tessella 2014

# This script install autosave R5-1
# it assumes EPICS base is already installed with all requried enviroment variables

# Usage:
# sudo -s
# . ./8.epics_autosave_5-1_install.sh

#check if user has right permissions
if [ "$(id -u)" != "0" ]; then
  echo "Sorry, you are not root. Try again using sudo."
  exit 1
fi

#terminate script after first line that fails
set -e

#autosave
AUTOSAVE_DOWNLOAD="autosave_R5-1.tar.gz"
AUTOSAVE_DIRECTORY="autosave-5-1"
wget --tries=3 --timeout=10 http://www.aps.anl.gov/bcda/synApps/tar/$AUTOSAVE_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/autosave
mkdir -p $SUPPORT_PATH
tar xzvf $AUTOSAVE_DOWNLOAD -C $SUPPORT_PATH
rm $AUTOSAVE_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$AUTOSAVE_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/home/oxygen/MOONEY/epics/bazaar/base-3.14|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install
