#!/bin/sh -e

#
#  prepareForUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

readonly deviceIdentifier=$TARGET_DEVICE_IDENTIFIER
readonly dirRoot="$PROJECT_DIR"
readonly deviceState=`xcrun simctl list devices | grep "$deviceIdentifier" | awk '{print $NF}' | sed 's/[()]//g'`

# Launch WireMock and move its process to the backgrund, block the standard output.
java \
-jar ${dirRoot}/WireMock/wire-mock.jar \
--root-dir ${dirRoot}/WireMock \
--port 8080 \
> /dev/null 2>&1 &

if [ "$deviceState" != "Booted" ]; then
    xcrun simctl boot $deviceIdentifier
    xcrun simctl bootstatus $deviceIdentifier
fi

xcrun simctl ui $deviceIdentifier appearance dark

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
