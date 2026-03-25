#!/bin/bash
set -euo pipefail

# Generate icon files from icon.svg
# Requires: convert (ImageMagick) and optionally iconutil (macOS)

SVG="${1:-icon.svg}"
OUTDIR="${2:-.}"

mkdir -p "$OUTDIR"

# Use magick (v7) if available, else convert (v6)
MAGICK="convert"
if command -v magick &>/dev/null; then MAGICK="magick"; fi

# PNG for Linux (.desktop icon) and Windows
$MAGICK -background none "$SVG" -resize 256x256 "$OUTDIR/icon-256.png"
$MAGICK -background none "$SVG" -resize 48x48 "$OUTDIR/icon-48.png"

# ICO for Windows (multi-size)
$MAGICK -background none "$SVG" \
  \( -clone 0 -resize 16x16 \) \
  \( -clone 0 -resize 32x32 \) \
  \( -clone 0 -resize 48x48 \) \
  \( -clone 0 -resize 256x256 \) \
  -delete 0 "$OUTDIR/icon.ico"

# ICNS for macOS (if iconutil is available)
if command -v iconutil &>/dev/null; then
  ICONSET="$OUTDIR/app.iconset"
  mkdir -p "$ICONSET"
  for size in 16 32 64 128 256 512; do
    $MAGICK -background none "$SVG" -resize ${size}x${size} "$ICONSET/icon_${size}x${size}.png"
    double=$((size * 2))
    $MAGICK -background none "$SVG" -resize ${double}x${double} "$ICONSET/icon_${size}x${size}@2x.png"
  done
  iconutil -c icns "$ICONSET" -o "$OUTDIR/icon.icns"
  rm -rf "$ICONSET"
  echo "Created $OUTDIR/icon.icns"
fi

echo "Icons generated in $OUTDIR"
