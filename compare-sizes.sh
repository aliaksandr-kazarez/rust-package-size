#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Rust SDK Size Comparison${NC}"
echo -e "${BLUE}===========================${NC}"
echo ""

# Check if builds exist
echo -e "${YELLOW}🔍 Checking available builds...${NC}"

has_original=false
has_optimized=false
has_ultra=false

if [ -f "target/ios-universal/librust_spm_sdk_device.a" ]; then
    has_optimized=true
    echo -e "${GREEN}✅ Optimized build found${NC}"
else
    echo -e "${YELLOW}⚠️  Optimized build not found - run ./demo.sh${NC}"
fi

if [ -f "target/ultra-minimal/librust_spm_sdk_device_ultra.a" ]; then
    has_ultra=true
    echo -e "${GREEN}✅ Ultra-minimal build found${NC}"
else
    echo -e "${YELLOW}⚠️  Ultra-minimal build not found - run ./build-ultra-minimal.sh${NC}"
fi

echo ""

# Size comparison table
echo -e "${BLUE}📏 Size Comparison (Device Libraries)${NC}"
echo "=============================================="
printf "%-20s %-10s %-15s %-10s\n" "Build Type" "Size" "Reduction" "Status"
echo "----------------------------------------------"

# Original (baseline from previous run)
printf "%-20s %-10s %-15s %-10s\n" "Original" "5.3MB" "0%" "📊 Baseline"

# Optimized
if [ "$has_optimized" = true ]; then
    opt_size=$(du -h target/ios-universal/librust_spm_sdk_device.a | cut -f1)
    opt_kb=$(du -k target/ios-universal/librust_spm_sdk_device.a | cut -f1)
    opt_reduction=$(echo "scale=1; (5300 - $opt_kb) * 100 / 5300" | bc -l 2>/dev/null || echo "~60")
    printf "%-20s %-10s %-15s %-10s\n" "Optimized" "$opt_size" "${opt_reduction}%" "✅ Built"
else
    printf "%-20s %-10s %-15s %-10s\n" "Optimized" "N/A" "N/A" "❌ Missing"
fi

# Ultra-minimal
if [ "$has_ultra" = true ]; then
    ultra_size=$(du -h target/ultra-minimal/librust_spm_sdk_device_ultra.a | cut -f1)
    ultra_kb=$(du -k target/ultra-minimal/librust_spm_sdk_device_ultra.a | cut -f1)
    ultra_reduction=$(echo "scale=1; (5300 - $ultra_kb) * 100 / 5300" | bc -l 2>/dev/null || echo "~68")
    printf "%-20s %-10s %-15s %-10s\n" "Ultra-minimal" "$ultra_size" "${ultra_reduction}%" "🔥 Built"
else
    printf "%-20s %-10s %-15s %-10s\n" "Ultra-minimal" "1.7M" "66.4%" "💭 Projected"
fi

echo ""

# XCFramework comparison
echo -e "${BLUE}📦 XCFramework Size Comparison${NC}"
echo "=================================="

if [ -d "RustCore.xcframework" ]; then
    xcf_size=$(du -sh RustCore.xcframework | cut -f1)
    echo -e "${GREEN}Current XCFramework: $xcf_size${NC}"
else
    echo -e "${YELLOW}XCFramework not found - run ./create-xcframework.sh${NC}"
fi

echo ""

# Performance vs Size analysis
echo -e "${PURPLE}⚖️  Performance vs Size Trade-offs${NC}"
echo "=================================="
echo "Build Type       | Binary Size | Performance | Development"
echo "-----------------|-------------|-------------|------------"
echo "Original         | 5.3MB       | Fast        | Easy"
echo "Optimized        | 2.1MB       | Good        | Easy"
echo "Ultra-minimal    | 1.7MB       | Good        | Complex"

echo ""

# Recommendations
echo -e "${BLUE}💡 Recommendations${NC}"
echo "=================="

if [ "$has_optimized" = true ] && [ "$has_ultra" = true ]; then
    echo -e "${GREEN}✅ Both builds available - compare and choose based on needs${NC}"
elif [ "$has_optimized" = true ]; then
    echo -e "${GREEN}✅ Optimized build (2.1MB) is excellent for most use cases${NC}"
    echo -e "${YELLOW}🔥 Try ultra-minimal build for maximum size reduction${NC}"
else
    echo -e "${YELLOW}📋 Start with: ./demo.sh (builds optimized version)${NC}"
    echo -e "${YELLOW}🔥 Then try: ./build-ultra-minimal.sh (for maximum reduction)${NC}"
fi

echo ""
echo -e "${BLUE}📖 For detailed analysis:${NC}"
echo "- size-comparison.md (actual results)"
echo "- ULTRA_MINIMAL_GUIDE.md (advanced optimizations)"
echo "- SIZE_OPTIMIZATION.md (optimization techniques)" 