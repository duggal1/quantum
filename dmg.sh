#!/bin/zsh
# Build Quantum and wrap it in a compressed disk image for macOS on Apple Silicon.
set -eu
cd "$(dirname "$0")"
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo "Quantum ships for Apple Silicon. Run ./dmg.sh on an arm64 Mac." >&2
  exit 1
fi

./build.sh

STAGE="$(mktemp -d)"
cp -R Quantum.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f Quantum.dmg
# ULMO (lzfse) packs smaller than the usual UDZO here and is native on Apple Silicon.
hdiutil create -quiet -volname Quantum -srcfolder "$STAGE" -ov -format ULMO -fs HFS+ Quantum.dmg
rm -rf "$STAGE"

echo "DMG bytes: $(stat -f '%z' Quantum.dmg)"
