#!/bin/bash 

# copyright (c) Tessella 2014

# this script install seq. 
# It assumes EPICS base is already installed and that
# the environment variable EPICS_ROOT is set and points to the installation directory.
#
# Usage:
# sudo -s
# source ./epics_seq_2-1-15_install.sh

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

echo $BASH_SOURCE   

# terminate script after first line that fails
set -e

# dependencies
apt-get -y install re2c

# seq
SEQ_DOWNLOAD="seq-2.1.15.tar.gz"
SEQ_DIRECTORY="seq-2.1.15"
wget --tries=3 --timeout=10  http://www-csr.bessy.de/control/SoftDist/sequencer/releases/$SEQ_DOWNLOAD
SUPPORT_PATH=$EPICS_ROOT/support/seq
mkdir -p $SUPPORT_PATH
tar xzvf $SEQ_DOWNLOAD -C $SUPPORT_PATH
rm $SEQ_DOWNLOAD

#symbolic link
rm -f $SUPPORT_PATH/current
ln -s $SUPPORT_PATH/$SEQ_DIRECTORY $SUPPORT_PATH/current

chmod 666 $SUPPORT_PATH/current/configure/RELEASE
sed -i -e "/^EPICS_BASE\s*=/ s,=.*,=$EPICS_ROOT/base," $SUPPORT_PATH/current/configure/RELEASE

make -C $SUPPORT_PATH/current install

