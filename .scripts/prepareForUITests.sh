#!/bin/sh -e

#
#  prepareForUITests.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 06/05/2024.
#

readonly device_identifier="$1"
readonly dirRoot="$2"

readonly device_state=`xcrun simctl list devices | grep "$device_identifier" | awk '{print $NF}' | sed 's/[()]//g'`

# Launch WireMock and move its process to the backgrund, block the standard output.
java \
-jar ${dirRoot}/WireMock/wire-mock.jar \
--root-dir ${dirRoot}/WireMock \
--port 8080 \
> /dev/null 2>&1 \
&

if [ "$device_state" != "Booted" ]; then
    xcrun simctl boot $device_identifier
    xcrun simctl bootstatus $device_identifier
fi

xcrun simctl ui $device_identifier appearance dark

xcrun simctl \
status_bar $device_identifier \
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
