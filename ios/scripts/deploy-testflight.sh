#!/bin/bash
set -euo pipefail

# TestFlight Deployment Script
# Usage: ./scripts/deploy-testflight.sh [--bump-version]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

# Configuration
PROJECT="SwiftApp.xcodeproj"
SCHEME="SwiftApp"
BUNDLE_ID="com.tron.davy"
TEAM_ID="L6JNH6A9TS"
API_KEY="8YS58G4DK8"
API_ISSUER="1264dd88-7902-45a9-ad36-ec021517b959"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$PROJECT_DIR"

# Check for API key file
API_KEY_FILE="$HOME/.private_keys/AuthKey_${API_KEY}.p8"
if [ ! -f "$API_KEY_FILE" ]; then
    log_error "API key file not found: $API_KEY_FILE"
    log_error "Copy your App Store Connect API key to this location"
    exit 1
fi

# Parse arguments
BUMP_VERSION=false
for arg in "$@"; do
    case $arg in
        --bump-version)
            BUMP_VERSION=true
            shift
            ;;
    esac
done

# Bump build number if requested
if [ "$BUMP_VERSION" = true ]; then
    log_info "Bumping build number..."
    BUILD_NUMBER=$(date +%Y%m%d%H%M)
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PROJECT_DIR/SwiftApp/Info.plist"
    log_info "Build number set to: $BUILD_NUMBER"
fi

# Clean build directory
log_info "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create exportOptions.plist
log_info "Creating export options..."
cat > "$BUILD_DIR/exportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>match AppStore $BUNDLE_ID</string>
    </dict>
    <key>uploadSymbols</key>
    <true/>
    <key>manageAppVersionAndBuildNumber</key>
    <true/>
</dict>
</plist>
EOF

# Build archive
log_info "Building archive..."
xcodebuild -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    archive \
    -archivePath "$BUILD_DIR/SwiftApp.xcarchive" \
    -quiet

if [ ! -d "$BUILD_DIR/SwiftApp.xcarchive" ]; then
    log_error "Archive failed!"
    exit 1
fi
log_info "Archive created successfully"

# Export IPA
log_info "Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/SwiftApp.xcarchive" \
    -exportOptionsPlist "$BUILD_DIR/exportOptions.plist" \
    -exportPath "$BUILD_DIR" \
    -quiet

if [ ! -f "$BUILD_DIR/SwiftApp.ipa" ]; then
    log_error "Export failed!"
    exit 1
fi
log_info "IPA exported successfully"

# Upload to TestFlight
log_info "Uploading to TestFlight..."
xcrun altool --upload-app \
    --file "$BUILD_DIR/SwiftApp.ipa" \
    --type ios \
    --apiKey "$API_KEY" \
    --apiIssuer "$API_ISSUER"

log_info "Upload complete! Check App Store Connect for processing status."
