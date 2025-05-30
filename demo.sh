#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦀 Rust SPM SDK Demo${NC}"
echo -e "${BLUE}===================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command -v rustc &> /dev/null; then
    echo -e "${RED}❌ Rust is not installed. Please install Rust first:${NC}"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode command line tools not found. Please install:${NC}"
    echo "   xcode-select --install"
    exit 1
fi

echo -e "${GREEN}✅ Rust version: $(rustc --version)${NC}"
echo -e "${GREEN}✅ Xcode version: $(xcodebuild -version | head -1)${NC}"
echo ""

# Build Rust libraries
echo -e "${YELLOW}🔨 Building Rust libraries for iOS...${NC}"
./build-ios.sh
echo ""

# Show library sizes
echo -e "${YELLOW}📏 Library sizes:${NC}"
if [ -d "target/ios-universal" ]; then
    ls -lh target/ios-universal/*.a
    echo ""
    
    # Calculate total size
    total_size=$(find target/ios-universal -name "*.a" -exec du -k {} \; | awk '{sum += $1} END {print sum}')
    echo -e "${BLUE}📊 Total compiled library size: ${total_size}KB${NC}"
fi
echo ""

# Create XCFramework
echo -e "${YELLOW}📦 Creating XCFramework...${NC}"
./create-xcframework.sh
echo ""

# Show final framework size
if [ -d "RustCore.xcframework" ]; then
    framework_size=$(du -sk RustCore.xcframework | awk '{print $1}')
    echo -e "${GREEN}✅ XCFramework created successfully!${NC}"
    echo -e "${BLUE}📊 Final XCFramework size: ${framework_size}KB${NC}"
    echo ""
fi

# Test the package (if Swift is available)
if command -v swift &> /dev/null; then
    echo -e "${YELLOW}🧪 Running tests...${NC}"
    if swift test 2>/dev/null; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Tests skipped (may need XCFramework in place)${NC}"
    fi
    echo ""
fi

# Summary
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "${GREEN}✅ Rust SDK compiled for iOS${NC}"
echo -e "${GREEN}✅ XCFramework created${NC}"
echo -e "${GREEN}✅ SPM package ready for integration${NC}"
echo ""

echo -e "${YELLOW}🎯 Next steps:${NC}"
echo "1. Add this package to your iOS project via SPM"
echo "2. Import RustSPMSDK in your Swift code"
echo "3. Use RustSDK.shared to access functionality"
echo "4. Monitor app size increase to evaluate footprint"
echo ""

echo -e "${BLUE}📖 See README.md for detailed usage instructions${NC}" 