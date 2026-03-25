#!/bin/bash
set -e
cd "$(dirname "$0")/.."

TARGET="${1:-native}"  # native, macos, linux, windows
VERSION=$(cat VERSION | tr -d '[:space:]')
LDFLAGS="-s -w -X main.version=$VERSION"
mkdir -p build

build_macos() {
    CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags="$LDFLAGS" -o build/cdpchrome-amd64 .
    CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -ldflags="$LDFLAGS" -o build/cdpchrome-arm64 .
    lipo -create -output build/cdpchrome build/cdpchrome-amd64 build/cdpchrome-arm64
    rm build/cdpchrome-amd64 build/cdpchrome-arm64
    bash scripts/build-macos-app.sh build/cdpchrome icons/icon.icns "build/CDP Chrome.app"
    cd build && zip -r cdpchrome-macos.zip "CDP Chrome.app"
    echo "Built build/cdpchrome-macos.zip"
}

build_linux() {
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="$LDFLAGS" -o build/cdpchrome .
    mkdir -p build/pkg
    cp build/cdpchrome build/pkg/
    cp icons/icon-256.png build/pkg/cdpchrome.png
    cp cdpchrome.desktop build/pkg/
    cp scripts/install-linux.sh build/pkg/install.sh
    chmod +x build/pkg/install.sh build/pkg/cdpchrome
    cd build && tar czf cdpchrome-linux-amd64.tar.gz -C pkg .
    rm -rf build/pkg
    echo "Built build/cdpchrome-linux-amd64.tar.gz"
}

build_windows() {
    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags="$LDFLAGS" -o build/cdpchrome.exe .
    cd build && zip cdpchrome-windows-amd64.zip cdpchrome.exe
    echo "Built build/cdpchrome-windows-amd64.zip"
}

case "$TARGET" in
    native) go build -ldflags="$LDFLAGS" -o build/cdpchrome .
            if [ "$(uname)" = "Darwin" ]; then
                bash scripts/build-macos-app.sh build/cdpchrome icons/icon.icns "build/CDP Chrome.app"
            fi
            echo "Built build/cdpchrome" ;;
    macos)   build_macos ;;
    linux)   build_linux ;;
    windows) build_windows ;;
    all)     build_macos; build_linux; build_windows ;;
    *)       echo "Usage: build.sh [native|macos|linux|windows|all]"; exit 1 ;;
esac
