#!/bin/bash
set -e
cd "$(dirname "$0")/.."

go build -o build/cdpchrome .
echo "Build: OK"

# Quick smoke test — binary runs and prints usage/error without Chrome
if build/cdpchrome --help 2>&1 | head -1 | grep -q .; then
    echo "Run:   OK"
fi
