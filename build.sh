#!/bin/zsh
# Build Quantum with Apple's command line Swift compiler and system frameworks.
set -eu
cd "$(dirname "$0")"
if [ "$(uname -s)" != Darwin ]; then
  echo "Quantum is a native macOS app. Run ./build.sh on a Mac." >&2
  exit 1
fi
SWIFTC="$(xcrun --find swiftc)"
APP="$PWD/Quantum.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>Quantum</string>
<key>CFBundleIdentifier</key><string>dev.quantum.browser</string>
<key>CFBundleName</key><string>Quantum</string>
<key>CFBundleDisplayName</key><string>Quantum</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.3.0</string>
<key>CFBundleVersion</key><string>2</string>
<key>LSMinimumSystemVersion</key><string>15.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>CFBundleIconFile</key><string>AppIcon.icns</string>
<key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoadsInWebContent</key><true/><key>NSAllowsLocalNetworking</key><true/></dict>
</dict></plist>
PLIST
cp icon.svg "$APP/Contents/Resources/"
ICONSET="$APP/Contents/Resources/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 64 128 256 512; do
  sips -z "$size" "$size" AppIcon.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" AppIcon.png --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"
TEMP_BINARY="/tmp/Quantum-build-$$"
zsh -lc 'xcrun swiftc -target "$(uname -m)-apple-macosx15.0" -Osize -whole-module-optimization -parse-as-library "$1" -framework AppKit -framework WebKit -o "$2"' quantum Quantum.swift "$TEMP_BINARY"
mv "$TEMP_BINARY" "$APP/Contents/MacOS/Quantum"
# Remove nonessential debug and local symbol tables before signing the executable.
strip -S -x "$APP/Contents/MacOS/Quantum"
codesign --force --sign - "$APP"
echo "Built: $APP"
echo "Executable bytes: $(stat -f '%z' "$APP/Contents/MacOS/Quantum")"
echo "Bundle disk usage (KiB): $(du -sk "$APP" | cut -f1)"
echo "Launch with: open '$APP'"
