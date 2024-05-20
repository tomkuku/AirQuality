#!/bin/sh -e

#
#  swiftlint.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

set -e

if test -d "/opt/homebrew/bin/"; then
  export PATH="/opt/homebrew/bin/:${PATH}"
fi

if which swiftlint >/dev/null; then
    if [ "$CONFIGURATION" == "Tests" ]; then
      echo "Linting files for tests configuration."
      swiftlint lint --config ".swiftlint-tests.yml"
    else
      echo "Linting files for default configuration."
      swiftlint lint --config ".swiftlint.yml"
    fi
else
  echo "SwiftLint not installed!"
  exit -1
fi