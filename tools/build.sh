#!/bin/bash
set -e
cd "$(dirname "$0")/.."

TARGET="${1:-native}"
mkdir -p build

build_macos() {
    bash scripts/build-macos-app.sh icons/icon.icns "build/CDP Chrome.app"
    cd build && zip -r cdpchrome-macos.zip "CDP Chrome.app"
    echo "Built build/cdpchrome-macos.zip"
}

build_linux() {
    mkdir -p build/pkg
    cp cdpchrome.sh build/pkg/cdpchrome
    cp icons/icon-256.png build/pkg/cdpchrome.png
    cp cdpchrome.desktop build/pkg/
    cp scripts/install-linux.sh build/pkg/install.sh
    chmod +x build/pkg/install.sh build/pkg/cdpchrome
    cd build && tar czf cdpchrome-linux-amd64.tar.gz -C pkg .
    rm -rf build/pkg
    echo "Built build/cdpchrome-linux-amd64.tar.gz"
}

build_windows() {
    cd build && zip cdpchrome-windows.zip -j ../install-windows.ps1 ../icons/icon.ico
    echo "Built build/cdpchrome-windows.zip"
}

case "$TARGET" in
    native) if [ "$(uname)" = "Darwin" ]; then
                bash scripts/build-macos-app.sh icons/icon.icns "build/CDP Chrome.app"
            else
                cp cdpchrome.sh build/cdpchrome && chmod +x build/cdpchrome
            fi
            echo "Built to build/" ;;
    macos)   build_macos ;;
    linux)   build_linux ;;
    windows) build_windows ;;
    all)     build_macos; build_linux; build_windows ;;
    *)       echo "Usage: build.sh [native|macos|linux|windows|all]"; exit 1 ;;
esac
