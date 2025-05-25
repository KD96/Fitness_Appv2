#!/bin/bash

# PureLife Fitness App - App Store Setup Script
# This script helps configure the environment for App Store submission

set -e

echo "🍎 PureLife Fitness - App Store Setup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "Fitness_Appv2.xcodeproj/project.pbxproj" ]; then
    print_error "Please run this script from the root of the Fitness_Appv2 project"
    exit 1
fi

print_info "Starting App Store setup process..."

# 1. Check Ruby and Bundler
echo ""
echo "1. Checking Ruby environment..."
if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby -v)
    print_status "Ruby found: $RUBY_VERSION"
else
    print_error "Ruby not found. Please install Ruby first."
    exit 1
fi

if command -v bundler &> /dev/null; then
    print_status "Bundler found"
else
    print_warning "Bundler not found. Installing..."
    gem install bundler
fi

# 2. Install Ruby dependencies
echo ""
echo "2. Installing Ruby dependencies..."
if [ -f "Gemfile" ]; then
    bundle install
    print_status "Ruby dependencies installed"
else
    print_error "Gemfile not found"
    exit 1
fi

# 3. Check Fastlane installation
echo ""
echo "3. Checking Fastlane..."
if command -v fastlane &> /dev/null; then
    FASTLANE_VERSION=$(fastlane --version | head -n 1)
    print_status "Fastlane found: $FASTLANE_VERSION"
else
    print_error "Fastlane not found. Please install via 'bundle install'"
    exit 1
fi

# 4. Check Xcode and command line tools
echo ""
echo "4. Checking Xcode environment..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_status "Xcode found: $XCODE_VERSION"
else
    print_error "Xcode command line tools not found"
    exit 1
fi

# 5. Verify project files
echo ""
echo "5. Verifying project files..."

# Check for required files
REQUIRED_FILES=(
    "Fitness_Appv2/PrivacyInfo.xcprivacy"
    "Fitness_Appv2/Fitness_Appv2.entitlements"
    "fastlane/Fastfile"
    "fastlane/Appfile"
    "Docs/AppStoreChecklist.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status "Found: $file"
    else
        print_error "Missing: $file"
        exit 1
    fi
done

# 6. Environment variables check
echo ""
echo "6. Checking environment variables..."

if [ -z "$TEAM_ID" ]; then
    print_warning "TEAM_ID environment variable not set"
    echo "Please set your Apple Developer Team ID:"
    echo "export TEAM_ID=\"YOUR_TEAM_ID\""
fi

if [ -z "$ITC_TEAM_ID" ]; then
    print_warning "ITC_TEAM_ID environment variable not set"
    echo "Please set your App Store Connect Team ID:"
    echo "export ITC_TEAM_ID=\"YOUR_ITC_TEAM_ID\""
fi

# 7. Create necessary directories
echo ""
echo "7. Creating necessary directories..."
mkdir -p screenshots
mkdir -p metadata
mkdir -p builds
print_status "Directories created"

# 8. Fastlane setup
echo ""
echo "8. Setting up Fastlane..."

# Update Appfile with user input if needed
if grep -q "YOUR_TEAM_ID" fastlane/Appfile; then
    print_warning "Please update fastlane/Appfile with your actual Team IDs"
fi

# 9. CocoaPods check
echo ""
echo "9. Checking CocoaPods..."
if [ -f "Podfile" ]; then
    if command -v pod &> /dev/null; then
        print_info "Running pod install..."
        pod install
        print_status "CocoaPods dependencies updated"
    else
        print_warning "CocoaPods not found. Install with: gem install cocoapods"
    fi
else
    print_info "No Podfile found, skipping CocoaPods"
fi

# 10. Git status check
echo ""
echo "10. Checking git status..."
if git status --porcelain | grep -q .; then
    print_warning "You have uncommitted changes. Consider committing before proceeding."
else
    print_status "Git working directory is clean"
fi

# Summary
echo ""
echo "🎉 Setup Complete!"
echo "=================="
print_status "App Store setup completed successfully"

echo ""
echo "Next steps:"
echo "1. Update fastlane/Appfile with your Team IDs"
echo "2. Configure certificates in Apple Developer Portal"
echo "3. Take screenshots for App Store"
echo "4. Run 'fastlane beta' to build and upload to TestFlight"
echo "5. Follow the checklist in Docs/AppStoreChecklist.md"

echo ""
print_info "Useful commands:"
echo "  fastlane beta          - Build and upload to TestFlight"
echo "  fastlane screenshots   - Take App Store screenshots"
echo "  fastlane certificates  - Download certificates and profiles"
echo "  fastlane test          - Run unit tests"

echo ""
print_info "For help: fastlane --help" 