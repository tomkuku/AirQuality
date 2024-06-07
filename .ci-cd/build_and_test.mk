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
all: prepare_environemnt build_and_test

prepare_environemnt:
	@echo "ℹ️ Removing Package.resolved"
	@rm -rf $(PROJECT)/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
	@touch AirQuality/Localizable/Localizable.swift

build_and_test:
	@echo "ℹ️ Building and Testing"
	set -euo pipefail && xcodebuild \
	test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION) \
	-resultBundlePath $(XCRESULT_PATH) \
	| xcbeautify