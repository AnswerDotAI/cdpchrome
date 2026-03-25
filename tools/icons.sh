#!/bin/bash
set -euo pipefail

# Regenerate icons/ from icon.svg
# Requires: ImageMagick and iconutil (macOS)
# Run this after changing icon.svg, then commit the results.

cd "$(dirname "$0")/.."

MAGICK="convert"
if command -v magick &>/dev/null; then MAGICK="magick"; fi

$MAGICK -background none icon.svg -resize 256x256 icons/icon-256.png
$MAGICK -background none icon.svg -resize 48x48 icons/icon-48.png

$MAGICK -background none icon.svg \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  \( -clone 0 -resize 256x256 \) \
  -delete 0 icons/icon.ico

if command -v iconutil &>/dev/null; then
  ICONSET=$(mktemp -d)
  for size in 16 32 64 128 256 512; do
    $MAGICK -background none icon.svg -resize ${size}x${size} "$ICONSET/icon_${size}x${size}.png"
    double=$((size * 2))
    $MAGICK -background none icon.svg -resize ${double}x${double} "$ICONSET/icon_${size}x${size}@2x.png"
  done
  iconutil -c icns "$ICONSET" -o icons/icon.icns
  rm -rf "$ICONSET"
fi

echo "Icons regenerated in icons/"
