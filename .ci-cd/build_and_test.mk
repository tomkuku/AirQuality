#
#  build-and-test.mk
#  AirQuality
#
#  Created by Tomasz Kukułka on 07/05/2024.
#

PROJECT = AirQuality.xcodeproj
SCHEME = Development
PLATFORM = 'iOS Simulator'
DEVICE = 'iPhone 15 Pro'
OS_VERSION = 17.4
XCRESULT_PATH = danger.xcresult

# - Targets
all: prepare_environemnt generate_xcodeproj build_and_test

prepare_environemnt:
	@touch AirQuality/Localizable/Localizable.swift

generate_xcodeproj:
	@echo "ℹ️ Generating $(PROJECT)"
	@xcodegen generate

build_and_test:
	@echo "ℹ️ Building and Testing"
	set -euo pipefail && xcodebuild \
	test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION) \
	-resultBundlePath $(XCRESULT_PATH) \
	| xcbeautify