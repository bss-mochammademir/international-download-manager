#!/bin/bash

# Configuration
APP_NAME="IntDM"
BUILD_DIR=".build"
RELEASE_DIR="release"
APP_BUNDLE="$RELEASE_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "🚀 Building $APP_NAME..."

# 1. Clear previous builds
rm -rf $RELEASE_DIR
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# 2. Compile using Swift Package Manager
swift build -c release

# 3. Create App Bundle structure
BINARY_PATH=$(find .build -name "$APP_NAME" -type f -not -path "*.dSYM*" | head -n 1)
if [ -z "$BINARY_PATH" ]; then
    echo "❌ Binary not found!"
    exit 1
fi
cp "$BINARY_PATH" "$MACOS/"
chmod +x "$MACOS/$APP_NAME"

# 3.1 Ad-hoc sign (required for macOS Sonoma+ to launch locally)
# Clean detritus (xattr) first to avoid signing errors
xattr -cr "$APP_BUNDLE"
codesign --force --deep --sign - "$APP_BUNDLE"

# 4. Create Info.plist
cat > "$CONTENTS/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.emir.intdm</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
EOF

# 5. Convert icons to .icns
echo "🎨 Creating app icons..."
mkdir -p "$APP_NAME.iconset"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" "$APP_NAME.iconset/icon_16x16.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png" "$APP_NAME.iconset/icon_16x16@2x.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" "$APP_NAME.iconset/icon_32x32.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png" "$APP_NAME.iconset/icon_32x32@2x.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" "$APP_NAME.iconset/icon_128x128.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" "$APP_NAME.iconset/icon_128x128@2x.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" "$APP_NAME.iconset/icon_256x256.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" "$APP_NAME.iconset/icon_256x256@2x.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" "$APP_NAME.iconset/icon_512x512.png"
cp "IntDM/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" "$APP_NAME.iconset/icon_512x512@2x.png"

iconutil -c icns "$APP_NAME.iconset" -o "$RESOURCES/AppIcon.icns"
rm -rf "$APP_NAME.iconset"

echo "✅ App bundle created at $APP_BUNDLE"

# 6. Optional: Create DMG
# echo "📦 Creating DMG..."
# hdiutil create -volname "$APP_NAME" -srcfolder "$RELEASE_DIR" -ov -format UDZO "$APP_NAME.dmg"
