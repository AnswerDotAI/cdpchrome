#!/bin/bash
set -e
cd "$(dirname "$0")/.."

tools/build.sh native
echo "Build: OK"

# Check Linux script syntax
bash -n cdpchrome.sh && echo "Syntax check (cdpchrome.sh): OK"

# Check PowerShell syntax if available
if command -v pwsh >/dev/null 2>&1; then
    pwsh -NoProfile -Command "Get-Command -Syntax install-windows.ps1" >/dev/null 2>&1 && echo "Syntax check (install-windows.ps1): OK"
fi
