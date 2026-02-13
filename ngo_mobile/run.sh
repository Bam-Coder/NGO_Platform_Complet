#!/bin/bash

# 🚀 NGO Agent Mobile App - Quick Start Script
# Usage: bash run.sh

set -e

echo "📱 NGO Agent Mobile App - Setup & Run"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

echo -e "${BLUE}✓ Flutter found: $(flutter --version)${NC}"
echo ""

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Generate Hive adapters (if needed)
echo -e "${BLUE}🔧 Generating build files...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || echo "Build runner skipped (optional)"
echo -e "${GREEN}✓ Build files ready${NC}"
echo ""

# Run analysis
echo -e "${BLUE}🔍 Running analysis...${NC}"
flutter analyze --no-pub
echo -e "${GREEN}✓ Analysis complete${NC}"
echo ""

# Run the app
echo -e "${BLUE}🚀 Launching app...${NC}"
echo "Choose your target:"
echo "1) Android Emulator"
echo "2) iOS Simulator"
echo "3) Physical Device"
read -p "Select (1-3): " choice

case $choice in
    1)
        flutter run -d emulator-5554
        ;;
    2)
        flutter run -d simulator
        ;;
    3)
        flutter run
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
