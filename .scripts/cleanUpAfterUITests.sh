#!/bin/sh -e

#
#  cleanUpAfterUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

readonly deviceIdentifier="$1"

# Stop recording
if [ -f "$recordingPidFilePath" ]; then
    simRecordingPid=$(cat "$recordingPidFilePath")
    echo "Killing simulator recording with pid: $simRecordingPid"
    kill -INT "$simRecordingPid"
    
    while kill -0 "$simRecordingPid" 2>/dev/null; do
        echo "waiting for killing"
        sleep 1
    done
    
    rm -rf "$recordingPidFilePath"
else
    echo -e "Simulator recording PID not found!"
fi

# Reset status bar to default settings
xcrun simctl status_bar $deviceIdentifier clear

# Kill WireMock
ps aux | grep "wire-mock.jar" | grep -v grep | awk '{print $2}' | xargs kill -KILL
