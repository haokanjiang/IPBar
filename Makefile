PROJECT  := IPBar.xcodeproj
SCHEME   := IPBar
CONFIG   := Debug
BUILD_DIR := build

APP_NAME := IPBar.app
APP_PATH := $(BUILD_DIR)/Build/Products/$(CONFIG)/$(APP_NAME)

.PHONY: all generate build run install clean

all: build

generate:
	xcodegen generate

build: generate
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-derivedDataPath $(BUILD_DIR) \
		-quiet

run: build
	open $(APP_PATH)

install: CONFIG := Release
install: build
	@rm -rf /Applications/$(APP_NAME)
	cp -r $(BUILD_DIR)/Build/Products/Release/$(APP_NAME) /Applications/
	@echo "Installed to /Applications/$(APP_NAME)"

clean:
	rm -rf $(BUILD_DIR)
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME) -quiet 2>/dev/null || true
