#!/bin/sh -e

#
#  cleanUpAfterUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

source "${PROJECT_DIR}/.scripts/xcode_scheme_actions_env.sh"

readonly wireMockPidFilePath="$UI_TESTS_WIRE_MOCK_PID_PATH"
readonly simRecordingPidFilePath="$UI_TESTS_SIM_RECORDING_PID_PATH"

# MARK: Stop recording

if [ -f "$simRecordingPidFilePath" ]; then
    simRecordingPid=$(cat "$simRecordingPidFilePath")
    echo "Killing simulator recording with pid: $simRecordingPid"
    kill -INT "$simRecordingPid"
    
    while kill -0 "$simRecordingPid" 2>/dev/null; do
        echo "waiting for killing simulator recording"
        sleep 1
    done
    
    echo "Simulator recording process killed"
else
    echo -e "Simulator recording PID not found!"
fi

# MARK: Reset status bar to default settings

xcrun simctl status_bar booted clear

# MARK: Kill WireMock

if [ -f "$wireMockPidFilePath" ]; then
    wireMockPid=$(cat "$wireMockPidFilePath")
    echo "Killing WireMock pid: $wireMockPid"
    
    while kill -0 "$wireMockPid" 2>/dev/null; do
        echo "Waiting for killing WireMock"
        sleep 1
    done
    
    echo "WireMock process killed"
else
    echo -e "WireMock PID not found!"
fi
