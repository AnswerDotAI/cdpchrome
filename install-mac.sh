#!/bin/bash
set -euo pipefail

URL=$(curl -fsSL https://latest.fast.ai/latest/AnswerDotAI/cdpchrome/cdpchrome-macos.zip)
TMP=$(mktemp -d)
curl -fsSL "$URL" -o "$TMP/cdpchrome.zip"
unzip -qo "$TMP/cdpchrome.zip" -d "$TMP"
rm -rf "/Applications/CDP Chrome.app"
mv "$TMP/CDP Chrome.app" /Applications/
rm -rf "$TMP"
echo "Installed CDP Chrome.app to /Applications"
