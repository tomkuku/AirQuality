#!/bin/sh -e

#
#  cleanUpAfterUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

readonly device_identifier="$1"

xcrun simctl status_bar $device_identifier clear

# ps aux | grep "wire-mock.jar" | grep -v grep | awk '{print $2}' | xargs kill -KILL
