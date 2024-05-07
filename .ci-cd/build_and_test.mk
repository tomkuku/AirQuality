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
IOS_VERSION = 17.4
CODE_SIGNING_ALLOWED = NO

# - Targets
all: build_and_test

build_and_test:
	@echo "ℹ️ Building and Testing"
	@set -euo pipefail && xcodebuild \
	clean test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED)