# Development

## Project structure

```
cdpchrome.sh                     # Linux launcher script
install-mac.sh                   # macOS installer (curl | bash)
install-windows.ps1              # Windows installer (creates Start Menu shortcut)
icon.svg                         # source icon
icons/                           # pre-built icons (committed; regenerate with tools/icons.sh)
cdpchrome.desktop                # Linux desktop entry
VERSION                          # current version (read by tools/*.sh)
tools/
  build.sh                       # build for any target (used locally and by CI)
  icons.sh                       # regenerate icons/ from icon.svg (needs ImageMagick)
  test.sh                        # smoke test
  bump.sh / bump2.sh             # patch / minor version bump
  release.sh                     # tag + push (triggers CI release)
scripts/
  build-macos-app.sh             # icon → .app bundle (shell script launcher)
  install-linux.sh               # installs script + desktop entry on Linux
.github/workflows/release.yml    # CI — calls tools/build.sh per platform
```

## How it works

Each platform has a simple script that finds Chrome and launches it with `--remote-debugging-port=9222` and a dedicated `--user-data-dir`.

- **macOS**: `scripts/build-macos-app.sh` creates a `.app` bundle containing a bash launcher. The launcher finds Chrome in `/Applications` and uses `arch -arm64` to run it.
- **Linux**: `cdpchrome.sh` searches `$PATH` then well-known locations for Chrome/Chromium, then `exec`s it.
- **Windows**: `install-windows.ps1` finds `chrome.exe` in Program Files/LocalAppData, then creates a Start Menu shortcut pointing to Chrome with the CDP args baked in.

### User data directories

A separate Chrome profile is used so CDP Chrome doesn't touch the user's normal Chrome data:

| OS      | Path |
|---------|------|
| macOS   | `~/Library/Application Support/ChromeDebug` |
| Linux   | `~/.config/chrome-debug` (respects `$XDG_CONFIG_HOME`) |
| Windows | `%LOCALAPPDATA%\ChromeDebug` |

## Building

No compiler needed — just shell scripts.

```bash
tools/build.sh              # native build (+ .app on macOS)
tools/build.sh macos        # .app + zip
tools/build.sh linux        # script + tarball with .desktop + install script
tools/build.sh windows      # installer ps1 + icon zip
tools/build.sh all          # all of the above
```

Output goes to `build/`. CI runs `tools/build.sh all` on ubuntu-latest.

### Updating icons

Icons in `icons/` are committed to the repo. If you change `icon.svg`, regenerate them (requires ImageMagick, and iconutil on macOS for .icns):

```bash
tools/icons.sh
```

## Testing

```bash
tools/test.sh               # builds + syntax checks
```

Manual test: run `build/cdpchrome` (or open `build/CDP Chrome.app` on macOS), then `curl http://localhost:9222/json/version` should return Chrome's version info.

## Releasing

```bash
tools/bump.sh               # 0.1.0 → 0.1.1
# or
tools/bump2.sh              # 0.1.0 → 0.2.0
git commit -am "v$(cat VERSION)"
tools/release.sh            # tags vX.Y.Z and pushes — CI builds + creates GitHub release
```

CI triggers on `v*` tags. The release job uploads platform zips/tarballs to the GitHub release with auto-generated notes.
