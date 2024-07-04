#!/bin/sh -e

#
#  installBrewDependencyIfNeeded.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

set -e

if [[ $# -eq 0 ]]; then 
    echo "Missing required dependencies names arguments!"
    exit 1
fi

for dependency in "$@"; do
    if brew list --formula | grep -q "^${dependency}\$"; then
        echo "$dependency is already installed"
    else
        echo "Installing $dependency"
        brew install "$dependency"
    fi
done