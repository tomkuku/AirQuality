#!/bin/sh -e

#
#  prepareXcresults.sh
#  AirQuality
#
#  Created by Tomasz Kukułka on 17/05/2024.
#

set -e

readonly result_path="result.xcresult"

if [ -d "$XCRESULTS_DIR_PATH" ]; then
    readonly xcresults_count=`find "$XCRESULTS_DIR_PATH" -mindepth 1 -maxdepth 1 -type d -name "*.xcresult" | wc -l`

    if [ "$xcresults_count" -eq 1 ]; then
        cp -r ${XCRESULTS_DIR_PATH}/*.xcresult $result_path
    elif [ "$xcresults_count" -gt 1 ]; then
        xcrun xcresulttool merge ${XCRESULTS_DIR_PATH}/*.xcresult --output-path $result_path
    fi
fi