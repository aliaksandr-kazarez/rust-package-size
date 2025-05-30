#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Rust SDK for iOS targets with size optimizations...${NC}"

# Check if required tools are installed
if ! command -v rustc &> /dev/null; then
    echo -e "${RED}Rust is not installed. Please install Rust first.${NC}"
    exit 1
fi

# Install iOS targets if not already installed
echo -e "${YELLOW}Adding iOS targets...${NC}"
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios  # For simulator on Intel Macs
rustup target add aarch64-apple-ios-sim  # For simulator on Apple Silicon

# Create output directory
mkdir -p target/ios-universal

# Set additional environment variables for size optimization
export RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-s"

# Build for iOS device (ARM64)
echo -e "${YELLOW}Building for iOS device (aarch64-apple-ios)...${NC}"
cargo build --target aarch64-apple-ios --release

# Build for iOS simulator (x86_64 - Intel)
echo -e "${YELLOW}Building for iOS simulator (x86_64-apple-ios)...${NC}"
cargo build --target x86_64-apple-ios --release

# Build for iOS simulator (ARM64 - Apple Silicon)
echo -e "${YELLOW}Building for iOS simulator (aarch64-apple-ios-sim)...${NC}"
cargo build --target aarch64-apple-ios-sim --release

# Strip symbols from libraries for additional size reduction
echo -e "${YELLOW}Stripping symbols for size reduction...${NC}"
strip target/aarch64-apple-ios/release/librust_spm_sdk.a 2>/dev/null || true
strip target/x86_64-apple-ios/release/librust_spm_sdk.a 2>/dev/null || true
strip target/aarch64-apple-ios-sim/release/librust_spm_sdk.a 2>/dev/null || true

# Create universal library for simulator
echo -e "${YELLOW}Creating universal simulator library...${NC}"
lipo -create \
    target/x86_64-apple-ios/release/librust_spm_sdk.a \
    target/aarch64-apple-ios-sim/release/librust_spm_sdk.a \
    -output target/ios-universal/librust_spm_sdk_sim.a

# Copy device library
cp target/aarch64-apple-ios/release/librust_spm_sdk.a target/ios-universal/librust_spm_sdk_device.a

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}Device library: target/ios-universal/librust_spm_sdk_device.a${NC}"
echo -e "${GREEN}Simulator library: target/ios-universal/librust_spm_sdk_sim.a${NC}"

# Show library sizes
echo -e "${YELLOW}Optimized library sizes:${NC}"
ls -lh target/ios-universal/librust_spm_sdk_*.a

# Compare with previous sizes if available
echo -e "${YELLOW}Size reduction achieved:${NC}"
for lib in target/ios-universal/librust_spm_sdk_*.a; do
    size=$(du -k "$lib" | cut -f1)
    echo "$(basename "$lib"): ${size}KB"
done 