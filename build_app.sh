#!/bin/bash
set -e

APP_NAME="SuperVoiceAssistant"
BUNDLE_ID="com.jwseo.SuperVoiceAssistant"
ICON_SOURCE="Sources/AppIcon.icns"
ASSETS_PATH="Sources/Assets.xcassets"
OUTPUT_DIR="."

echo "🚀 Building $APP_NAME..."

# 1. Build release binary
swift build -c release

# 2. Key paths
BUILD_DIR=".build/release"
BINARY_PATH="$BUILD_DIR/$APP_NAME"
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# 3. Create bundle structure
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 4. Copy binary
cp "$BINARY_PATH" "$MACOS_DIR/"

# 5. Process Icons and Assets
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$RESOURCES_DIR/"
    echo "✅ Copied AppIcon.icns"
else
    echo "⚠️ Warning: AppIcon.icns not found at $ICON_SOURCE"
fi

if [ -d "$ASSETS_PATH" ]; then
    xcrun actool "$ASSETS_PATH" --compile "$RESOURCES_DIR" --platform macosx --minimum-deployment-target 14.0 --app-icon AppIcon --output-partial-info-plist /tmp/partial.plist
    echo "✅ Compiled Assets.xcassets"
fi

# 6. Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" <<EOF
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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>Need microphone access for voice commands and transcription.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Need speech recognition for transcription.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>Need to control other apps to paste text.</string>
    <key>NSDesktopFolderUsageDescription</key>
    <string>Need access to save recordings.</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>Need access to save recordings.</string>
    <key>NSDownloadsFolderUsageDescription</key>
    <string>Need access to save recordings.</string>
    <key>NSScreenCaptureUsageDescription</key>
    <string>Need screen recording permission to capture screen content for video transcription.</string>
</dict>
</plist>
EOF

# 7. Code Sign (Ad-hoc)
codesign --force --deep --sign - "$APP_BUNDLE"

echo "🎉 Build complete: $APP_BUNDLE"
