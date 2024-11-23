#!/bin/sh -e

#
#  moveFailedSnapshotsImages.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 17/05/2024.
#

readonly deviceId=`xcrun simctl list | grep -i booted | awk -F '[()]' '{print $2}'`
readonly applicationDataPath=`xcrun simctl get_app_container $deviceId com.air.quality.test.xctrunner data`

mkdir UITestsSnapshots

cp ${applicationDataPath}/tmp/*Tests/*.png UITestsSnapshots

zip -r images.zip UITestsSnapshots/*