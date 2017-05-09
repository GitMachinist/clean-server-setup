#!/bin/bash

# Copyright (c) HiLASE 2016
# script based on template maded by David Michel Tessella 2014

# This script install areaDetector R1-9-1
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


#dependencies
#asyn
if [ ! -d $EPICS_ROOT/support/asyn ]; then
  echo "Asyn not installed. Please install asyn and try again."
  exit 1
fi

#busy
if [ ! -d $EPICS_ROOT/support/busy ]; then
  echo "Busy not installed. Please install busy and try again."
  exit 1
fi

#calc
if [ ! -d $EPICS_ROOT/support/calc ]; then
  echo "Calc not installed. Please install calc and try again."
  exit 1
fi

#sscan
if [ ! -d $EPICS_ROOT/support/sscan ]; then
  echo "Sscan not installed. Please install sscan and try again"
  exit 1
fi

#autosave
if [ ! -d $EPICS_ROOT/support/autosave ]; then
  echo "Autosave not installed. Please install autosave and try again"
  exit 1
fi


# asyn
AD_DOWNLOAD="areaDetectorR1-9-1.tgz"
AD_DIRECTORY="areaDetectorR1-9-1"
wget --tries=3 --timeout=10  http://cars.uchicago.edu/software/pub/$AD_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/areaDetector
mkdir -p $SUPPORT_PATH
tar xzvf $AD_DOWNLOAD -C $SUPPORT_PATH
rm $AD_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$AD_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SUPPORT=/corvette/home/epics/devel|SUPPORT=$EPICS_ROOT/support|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|ASYN=\$(SUPPORT)/asyn-4-21|ASYN=\$(SUPPORT)/asyn/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|CALC=\$(SUPPORT)/calc-3-0|CALC=\$(SUPPORT)/calc/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|BUSY=\$(SUPPORT)/busy-1-4|BUSY=\$(SUPPORT)/busy/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|SSCAN=\$(SUPPORT)/sscan-2-8-1|SSCAN=\$(SUPPORT)/sscan/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|AUTOSAVE=\$(SUPPORT)/autosave-5-0|AUTOSAVE=\$(SUPPORT)/autosave/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|AREA_DETECTOR=\$(SUPPORT)/areaDetector-1-9-1|AREA_DETECTOR=\$(SUPPORT)/areaDetector/current|g" $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "s|EPICS_BASE=/corvette/usr/local/epics/base-3.14.12.3|EPICS_BASE=$EPICS_ROOT/base|g" $SUPPORT_PATH/current/configure/RELEASE
make -C $SUPPORT_PATH/current install
