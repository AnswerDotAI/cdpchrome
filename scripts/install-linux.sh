#!/bin/bash
set -euo pipefail

PREFIX="${1:-$HOME/.local}"

install -Dm755 cdpchrome "$PREFIX/bin/cdpchrome"
install -Dm644 cdpchrome.png "$PREFIX/share/icons/hicolor/256x256/apps/cdpchrome.png"
install -Dm644 cdpchrome.desktop "$PREFIX/share/applications/cdpchrome.desktop"

# Update desktop entry with installed path
sed -i "s|Exec=cdpchrome|Exec=$PREFIX/bin/cdpchrome|" "$PREFIX/share/applications/cdpchrome.desktop"
sed -i "s|Icon=cdpchrome|Icon=$PREFIX/share/icons/hicolor/256x256/apps/cdpchrome.png|" "$PREFIX/share/applications/cdpchrome.desktop"

echo "Installed to $PREFIX"
echo "Make sure $PREFIX/bin is in your PATH"
