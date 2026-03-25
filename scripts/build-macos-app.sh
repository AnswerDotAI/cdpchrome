#!/bin/bash
set -euo pipefail

# Build a macOS .app bundle from a pre-built binary
# Usage: build-macos-app.sh <binary-path> <icon.icns> <output.app>

BINARY="${1:?usage: build-macos-app.sh <binary> <icon.icns> <output.app>}"
ICON="${2:?}"
APP="${3:?}"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BINARY" "$APP/Contents/MacOS/cdpchrome"
chmod +x "$APP/Contents/MacOS/cdpchrome"
cp "$ICON" "$APP/Contents/Resources/app.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>CDP Chrome</string>
    <key>CFBundleDisplayName</key>
    <string>CDP Chrome</string>
    <key>CFBundleIdentifier</key>
    <string>com.cdpchrome.app</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>cdpchrome</string>
    <key>CFBundleIconFile</key>
    <string>app</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built $APP"
