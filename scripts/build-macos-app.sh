#!/bin/bash
set -euo pipefail

# Build a macOS .app bundle with a shell script launcher
# Usage: build-macos-app.sh <icon.icns> <output.app>

ICON="${1:?usage: build-macos-app.sh <icon.icns> <output.app>}"
APP="${2:?}"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ICON" "$APP/Contents/Resources/app.icns"

cat > "$APP/Contents/MacOS/cdpchrome" <<'LAUNCHER'
#!/bin/bash
for chrome in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "$HOME/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
    [ -x "$chrome" ] && exec arch -arm64 "$chrome" \
        --remote-debugging-port=9222 \
        --user-data-dir="$HOME/Library/Application Support/ChromeDebug" \
        "$@"
done
osascript -e 'display alert "CDP Chrome" message "Google Chrome not found in Applications."'
LAUNCHER
chmod +x "$APP/Contents/MacOS/cdpchrome"

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
