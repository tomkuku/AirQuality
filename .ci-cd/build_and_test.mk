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
DANGER_XCRESULT = tests_results.xcresult

# - Targets
all: prepare_environemnt build_and_test

prepare_environemnt:
	@echo "ℹ️ Reseting simulators"
	@# Shutdown all devices and boot again to be sure that right simulator is booted
	@xcrun simctl shutdown all
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

run_danger:
	@echo "ℹ️ Running danger"
	@# Copy the newest .xcresult into home dir for danger-xcode_summary
	# @cp -r ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)*/Logs/Test/*.xcresult $(DANGER_XCRESULT)
	@bundle install
	@bundle exec danger