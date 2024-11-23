#!/bin/sh -e

#
#  moveFailedSnapshotsImages.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 17/05/2024.
#

readonly deviceId=`xcrun simctl list | grep -i booted | awk -F '[()]' '{print $2}'`
readonly applicationDataPath=`xcrun simctl get_app_container $deviceId com.air.quality.test.xctrunner data`
readonly sourceDir=`echo "${applicationDataPath}/tmp"`

if find "$sourceDir" -type d -mindepth 1 | grep -q .; then
    mkdir -p UITestsSnapshots
    cp ${sourceDir}/*Tests/*.png UITestsSnapshots
fi