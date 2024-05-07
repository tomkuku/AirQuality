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
IOS_VERSION = 17.0.1
CODE_SIGNING_ALLOWED = NO

# - Targets
all: prepare_environemnt build_and_test

prepare_environemnt:
	@echo "ℹ️ Reseting simulators"
	@# Shutdown all devices and boot again to be sure that right simulator is booted
	@xcrun simctl shutdown all
	@xcrun simctl boot $(DEVICE)
	@# Uninstall app and erase simulator to avoid error while tests
	@xcrun simctl shutdown $(DEVICE)
	@xcrun simctl erase $(DEVICE)
	@echo "ℹ️ Removing DerivedData" 
	@rm -rf ~/Library/Developer/Xcode/DerivedData
	@rm -rf $(PROJECT)/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

build_and_test:
	@echo "ℹ️ Building and Testing"
	@set -euo pipefail && xcodebuild \
	clean test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION)