#!/bin/sh -e

#
#  cleanUpAfterUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

source "${PROJECT_DIR}/.scripts/xcode_scheme_actions_env.sh"

readonly wireMockPidFilePath="$UI_TESTS_WIRE_MOCK_PID_PATH"

# MARK: Reset status bar to default settings

xcrun simctl status_bar booted clear

# MARK: Kill WireMock

if [ -f "$wireMockPidFilePath" ]; then
    wireMockPid=$(cat "$wireMockPidFilePath")
    echo "Killing WireMock pid: $wireMockPid"
    
    while kill -KILL "$wireMockPid" 2>/dev/null; do
        echo "Waiting for killing WireMock"
        sleep 1
    done
    
    echo "WireMock process killed"
else
    echo -e "WireMock PID not found!"
fi
