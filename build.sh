#!/bin/sh
# Builds PingBar.app into ~/Applications (Spotlight-indexed). Usage: ./build.sh
set -e
cd "$(dirname "$0")"
APP="$HOME/Applications/PingBar.app"
mkdir -p "$APP/Contents/MacOS"
swiftc -O pingbar.swift -o "$APP/Contents/MacOS/pingbar"
cat > "$APP/Contents/Info.plist" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>PingBar</string>
<key>CFBundleDisplayName</key><string>PingBar</string>
<key>CFBundleIdentifier</key><string>local.pingbar</string>
<key>CFBundleExecutable</key><string>pingbar</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PL
codesign --force --sign - "$APP"
echo "Built $APP"
