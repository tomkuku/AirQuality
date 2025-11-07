#!/bin/sh -e

#
#  copyFailedUITestsSnapshots.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 17/05/2024.
#

readonly deviceIdentifier=$TARGET_DEVICE_IDENTIFIER
readonly xctrunnerBundleIdentifier="${PRODUCT_BUNDLE_IDENTIFIER}.xctrunner"
readonly applicationDataPath=`xcrun simctl get_app_container $deviceIdentifier $xctrunnerBundleIdentifier data`
readonly sourceDir=`echo "${applicationDataPath}/tmp"`

if find "$sourceDir" -type d -mindepth 1 | grep -q .; then
    mkdir -p ${PROJECT_DIR}/${UI_TESTS_OUTPUT_DIR}
    cp -r ${sourceDir}/*Tests/*.png ${PROJECT_DIR}/${UI_TESTS_OUTPUT_DIR}
fi
