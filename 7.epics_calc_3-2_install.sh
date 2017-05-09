#!/bin/bash

# Copyright (c) HiLASE 2016
# script based on template maded by David Michel Tessella 2014

# This script install calc R3-2
# it assumes EPICS base is already installed with all requried enviroment variables

# Usage:
# sudo -s
# . ./7.epics_areadetector_1-9-1_install.sh

#check if user has right permissions
if [ "$(id -u)" != "0" ]; then
  echo "Sorry, you are not root. Try again using sudo."
  exit 1
fi

#terminate script after first line that fails
set -e


#calc
CALC_DOWNLOAD="calc_R3-2.tar.gz"
CALC_DIRECTORY="calc-3-2"
wget --tries=3 --timeout=10 http://www.aps.anl.gov/bcda/synApps/tar/$CALC_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/calc
mkdir -p $SUPPORT_PATH
tar xzvf $CALC_DOWNLOAD -C $SUPPORT_PATH
rm $CALC_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$CALC_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SUPPORT=/home/oxygen/MOONEY/epics/synAppsSVN/support|SUPPORT=$EPICS_ROOT/support|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SSCAN=\$(SUPPORT)/sscan-2-8|SSCAN=\$(SUPPORT)/sscan/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/home/oxygen/MOONEY/epics/base-3.15.0.1|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install
