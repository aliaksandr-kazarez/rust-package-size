#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔥 ULTRA-MINIMAL Rust SDK Build${NC}"
echo -e "${BLUE}===============================${NC}"
echo ""

# Check if required tools are installed
if ! command -v rustc &> /dev/null; then
    echo -e "${RED}Rust is not installed. Please install Rust first.${NC}"
    exit 1
fi

# Install iOS targets if not already installed
echo -e "${YELLOW}Adding iOS targets...${NC}"
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios
rustup target add aarch64-apple-ios-sim

# Create output directory
mkdir -p target/ultra-minimal

# Ultra-aggressive build flags
export RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-s -C link-arg=-dead_strip -C link-arg=-x"

echo -e "${YELLOW}🔥 Building ULTRA-MINIMAL libraries...${NC}"

# Build for iOS device (ARM64) with maximum optimization
echo -e "${YELLOW}Building ultra-minimal iOS device library...${NC}"
cargo build --target aarch64-apple-ios --release

# Build for iOS simulator (x86_64 - Intel)
echo -e "${YELLOW}Building ultra-minimal iOS simulator (Intel)...${NC}"
cargo build --target x86_64-apple-ios --release

# Build for iOS simulator (ARM64 - Apple Silicon)
echo -e "${YELLOW}Building ultra-minimal iOS simulator (Apple Silicon)...${NC}"
cargo build --target aarch64-apple-ios-sim --release

# Aggressive post-build optimization
echo -e "${YELLOW}🔥 Applying aggressive post-build optimizations...${NC}"

# Strip everything possible
strip -S -x target/aarch64-apple-ios/release/librust_spm_sdk.a 2>/dev/null || true
strip -S -x target/x86_64-apple-ios/release/librust_spm_sdk.a 2>/dev/null || true
strip -S -x target/aarch64-apple-ios-sim/release/librust_spm_sdk.a 2>/dev/null || true

# Additional aggressive stripping with objcopy if available
if command -v objcopy &> /dev/null; then
    echo -e "${YELLOW}Applying objcopy optimizations...${NC}"
    objcopy --strip-unneeded target/aarch64-apple-ios/release/librust_spm_sdk.a 2>/dev/null || true
fi

# Create universal library for simulator
echo -e "${YELLOW}Creating ultra-minimal universal simulator library...${NC}"
lipo -create \
    target/x86_64-apple-ios/release/librust_spm_sdk.a \
    target/aarch64-apple-ios-sim/release/librust_spm_sdk.a \
    -output target/ultra-minimal/librust_spm_sdk_sim_ultra.a

# Copy device library
cp target/aarch64-apple-ios/release/librust_spm_sdk.a target/ultra-minimal/librust_spm_sdk_device_ultra.a

echo -e "${GREEN}🎉 ULTRA-MINIMAL build completed!${NC}"
echo -e "${GREEN}Device library: target/ultra-minimal/librust_spm_sdk_device_ultra.a${NC}"
echo -e "${GREEN}Simulator library: target/ultra-minimal/librust_spm_sdk_sim_ultra.a${NC}"

echo -e "${BLUE}📊 ULTRA-MINIMAL Library Sizes:${NC}"
ls -lh target/ultra-minimal/librust_spm_sdk_*_ultra.a

echo -e "${BLUE}📉 Size Comparison:${NC}"
echo "ORIGINAL sizes:"
if [ -f "target/ios-universal/librust_spm_sdk_device.a" ]; then
    ls -lh target/ios-universal/librust_spm_sdk_*.a
fi

echo ""
echo "ULTRA-MINIMAL sizes:"
for lib in target/ultra-minimal/librust_spm_sdk_*_ultra.a; do
    size=$(du -h "$lib" | cut -f1)
    echo "$(basename "$lib"): $size"
done

echo ""
echo -e "${YELLOW}🔬 Binary Analysis:${NC}"
for lib in target/ultra-minimal/librust_spm_sdk_*_ultra.a; do
    echo "=== $(basename "$lib") ==="
    file "$lib"
    echo "Size: $(du -h "$lib" | cut -f1)"
    if command -v nm &> /dev/null; then
        symbol_count=$(nm -gU "$lib" 2>/dev/null | wc -l || echo "0")
        echo "Symbols: $symbol_count"
    fi
    echo ""
done

echo -e "${GREEN}🚀 Ready for ultra-minimal XCFramework creation!${NC}" 