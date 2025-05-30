#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating XCFramework from Rust libraries...${NC}"

# Check if libraries exist
if [ ! -f "target/ios-universal/librust_spm_sdk_device.a" ] || [ ! -f "target/ios-universal/librust_spm_sdk_sim.a" ]; then
    echo -e "${RED}Rust libraries not found. Please run ./build-ios.sh first.${NC}"
    exit 1
fi

# Clean up any existing framework
rm -rf RustCore.xcframework

# Create XCFramework directly from static libraries
echo -e "${YELLOW}Creating XCFramework from static libraries...${NC}"
xcodebuild -create-xcframework \
    -library target/ios-universal/librust_spm_sdk_device.a \
    -headers include/ \
    -library target/ios-universal/librust_spm_sdk_sim.a \
    -headers include/ \
    -output RustCore.xcframework

echo -e "${GREEN}XCFramework created successfully!${NC}"
echo -e "${GREEN}Location: RustCore.xcframework${NC}"

# Show XCFramework info
echo -e "${YELLOW}XCFramework contents:${NC}"
find RustCore.xcframework -type f -name "*.a" -exec ls -lh {} \;

echo -e "${YELLOW}Framework size:${NC}"
du -sh RustCore.xcframework

echo -e "${YELLOW}XCFramework structure:${NC}"
find RustCore.xcframework -type f | head -10 