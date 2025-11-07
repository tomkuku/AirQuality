#!/bin/sh -e

#
#  prepareForUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

set -eo pipefail
set -E

trap 'exit 1' ERR 

readonly deviceIdentifier=$TARGET_DEVICE_IDENTIFIER
readonly dirRoot="$PROJECT_DIR"

# Launch WireMock and move its process to the backgrund, to not block the standard output.
java \
-jar ${dirRoot}/WireMock/wire-mock.jar \
--root-dir ${dirRoot}/WireMock \
--port 8080 \
> /dev/null 2>&1 &

readonly deviceState=`xcrun simctl list devices | grep "$deviceIdentifier" | awk '{print $NF}' | sed 's/[()]//g'`

if [ "$deviceState" != "Booted" ]; then
    xcrun simctl boot $deviceIdentifier
    xcrun simctl bootstatus $deviceIdentifier
fi

xcrun simctl ui $deviceIdentifier appearance light

xcrun simctl \
status_bar $deviceIdentifier \
override \
--time "9:41" \
--dataNetwork wifi \
--wifiMode active \
--wifiBars 3 \
--cellularMode active \
--cellularBars 4 \
--operatorName '' \
--batteryState charged \
--batteryLevel 100

# In the end wait until WireMock server is stand up.
while ! lsof -i :8080 > /dev/null; do
  sleep 1
done

mkdir -p ${dirRoot}/${UI_TESTS_OUTPUT_DIR}

# Wait for WireMock first to reduce size of the video.
exec xcrun simctl io $deviceIdentifier \
recordVideo \
--codec=h264 \
--display=internal \
--mask=black \
--force \
"${dirRoot}/${UI_TESTS_OUTPUT_DIR}/ui_tests_simulator.mp4" &

echo $! > $UI_TESTS_SIM_RECORDING_PID_PATH
