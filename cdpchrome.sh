#!/bin/bash
set -euo pipefail

for name in google-chrome google-chrome-stable chromium-browser chromium; do
    chrome=$(command -v "$name" 2>/dev/null) && break
done
if [ -z "${chrome:-}" ]; then
    for p in /usr/bin/google-chrome-stable /usr/bin/google-chrome \
             /usr/bin/chromium-browser /usr/bin/chromium /snap/bin/chromium; do
        [ -x "$p" ] && chrome="$p" && break
    done
fi
if [ -z "${chrome:-}" ]; then
    echo "cdpchrome: Chrome/Chromium not found — install google-chrome or chromium" >&2
    exit 1
fi

DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/chrome-debug"
exec "$chrome" --remote-debugging-port=9222 --user-data-dir="$DATA_DIR" "$@"
