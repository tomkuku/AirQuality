#
#  build-and-test.mk
#  AirQuality
#
#  Created by Tomasz Kukułka on 07/05/2024.
#

PROJECT = AirQuality.xcodeproj
UI_TEST_SCHEME = UITests
UNIT_TEST_SCHEME = UnitTests
PLATFORM = 'iOS Simulator'
DEVICE = 'iPhone 15 Pro'
OS_VERSION = 18.0
XCRESULT_PATH = danger.xcresult

# - Targets
all: prepare_environemnt generate_xcodeproj unit_tests ui_tests

prepare_environemnt:
	@touch AirQuality/Localizable/Localizable.swift
	@touch AirQuality/Assets/Assets.swift
	@touch AirQuality/Assets/Params.swift

generate_xcodeproj:
	@echo "ℹ️ Generating $(PROJECT)"
	@xcodegen generate

unit_tests:
	@echo "ℹ️ Building and Testing"
	set -euo pipefail && xcodebuild \
	test \
	-project $(PROJECT) \
	-scheme $(UNIT_TEST_SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION) \
	-resultBundlePath $(XCRESULT_PATH) \
	| xcbeautify

ui_tests:
	@echo "ℹ️ Building and Testing"
	set -euo pipefail && xcodebuild \
	test \
	-project $(PROJECT) \
	-scheme $(UI_TEST_SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION) \
	-resultBundlePath $(XCRESULT_PATH) \
	| xcbeautify
