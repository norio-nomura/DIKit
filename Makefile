PREFIX?=/usr/local
VERSION:=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" DIKit.xcodeproj/DIGenKit_Info.plist)
XCCONFIG_PATH=DIKit.xcconfig

build:
	swift build -c release -Xswiftc -static-stdlib

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/dikitgen" "$(PREFIX)/bin/dikitgen"

set_version:
	agvtool new-marketing-version ${VERSION}
	sed -i '' -e 's/current = ".*"/current = "${VERSION}"/g' Sources/DIGenKit/Version.swift

generate_xcodeproj:
	SWIFT_DETERMINISTIC_HASHING=1 swift package generate-xcodeproj --xcconfig-overrides ${XCCONFIG_PATH}
	$(MAKE) set_version VERSION=$(VERSION)
	sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \"DIKit\"|PRODUCT_BUNDLE_IDENTIFIER = org.ishkawa.DIKit|g" DIKit.xcodeproj/project.pbxproj
	sed -E -i '' -e "s|$(PWD)/.build/checkouts/(.*)\.git-+[0-9]+/Package\.swift|Carthage/Checkouts/\1/Package.swift|g" DIKit.xcodeproj/project.pbxproj
	sed -E -i '' -e "s|.build/checkouts/(.*)\.git-+[0-9]+|Carthage/Checkouts/\1|g" DIKit.xcodeproj/project.pbxproj
