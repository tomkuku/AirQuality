#!/bin/sh -e

#
#  installBrewDependencyIfNeeded.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

set -e

if [ "$1" == "" ] ; then 
    echo "Missing required dependency name argument!"
    exit -1;
fi 

readonly isDependencyInstalled=`brew list | grep $1`

if [ "$isDependencyInstalled" == "$1" ] ; then
    echo "$1 is installed!"
else 
    echo "Installing $1!"
    brew install $1
fi