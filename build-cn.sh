#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
OUT="${WATTSON_CN_OUTPUT:-$PWD/dist}"
mkdir -p "$OUT"
swift build -c release
APP="$OUT/Wattson-CN.app"
# Refuse to overwrite an unknown bundle.
if [ -d "$APP" ]; then
    ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")
    [ "$ID" = "com.filip.wattson.cn" ] || { echo 'Unexpected existing app; stopping.'; exit 1; }
fi
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Wattson "$APP/Contents/MacOS/Wattson-CN"
cp Resources/Info.plist "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.filip.wattson.cn' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable Wattson-CN' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName Wattson-CN' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Wattson-CN' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations array' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations:0 string en' "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations:1 string zh-Hans' "$APP/Contents/Info.plist"
cp -R .build/release/Wattson_Wattson.bundle "$APP/Contents/Resources/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
cp LICENSE "$APP/Contents/Resources/LICENSE"
printf 'APPL????' > "$APP/Contents/PkgInfo"
codesign --force --sign - --timestamp=none "$APP"
codesign --verify --deep --strict "$APP"
echo "Built: $APP"
