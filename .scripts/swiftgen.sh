#!/bin/sh -e

#
#  swiftgen.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 17/05/2024.
#

set -e

if test -d "/opt/homebrew/bin/"; then
  export PATH="/opt/homebrew/bin/:${PATH}"
fi

if which swiftgen >/dev/null; then
    swiftgen config lint  --config '.swiftgen.yml' 1>/dev/null
    swiftgen --config .swiftgen.yml
else
  echo "SwiftGen not installed!"
  exit -1
fi