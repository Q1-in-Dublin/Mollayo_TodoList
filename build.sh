#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Mollayo"
BUNDLE_ID="com.local.mollayo"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/TodoApp" "$APP_DIR/Contents/MacOS/$APP_NAME"

# SPM's resource bundle (localization .lproj folders) — without this, Bundle.module
# only finds it by accident via a dev-build sibling-directory fallback, and
# localization silently breaks once the .app is copied anywhere else (e.g. /Applications).
cp -R "$BUILD_DIR/TodoApp_TodoApp.bundle" "$APP_DIR/Contents/Resources/"

ICONSET="$BUILD_DIR/AppIcon.iconset"
rm -rf "$ICONSET"
swift Scripts/generate_icon.swift "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP_DIR/Contents/Resources/AppIcon.icns"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Mollayo</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR"

echo "Built: $APP_DIR"
