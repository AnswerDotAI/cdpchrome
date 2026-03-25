# Development

## Project structure

```
main.go                          # the entire app — single file
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
  build-macos-app.sh             # binary + icon → .app bundle
  install-linux.sh               # installs binary + desktop entry on Linux
.github/workflows/release.yml    # CI — calls tools/build.sh per platform
```

## How it works

`main.go` is a small file with three responsibilities:

1. **Find Chrome** — `chromeExecutable()` / `chromeAppBundle()` check platform-specific paths. On Linux it also tries `$PATH` via `LookPath`.

2. **Build args** — always passes `--remote-debugging-port=9222` and `--user-data-dir=<platform-specific path>`, plus any extra CLI args (`os.Args[1:]`).

3. **Launch** — the strategy differs per OS:
   - **macOS**: Uses `open -n -a <Chrome.app> --args ...`. The `-n` forces a new instance (otherwise `open` just activates existing Chrome and ignores `--args`). Using `open` instead of directly exec'ing Chrome's binary avoids macOS App Management TCC blocks ("prevented from modifying apps").
   - **Linux**: `syscall.Exec` replaces the process with Chrome (like `exec` in a shell script).
   - **Windows**: `exec.Command` + `Start()` spawns Chrome and exits immediately.

### macOS .app bundle

`scripts/build-macos-app.sh` creates the standard bundle structure:
```
CDP Chrome.app/
  Contents/
    Info.plist
    MacOS/cdpchrome      # the Go binary
    Resources/app.icns   # the icon
```

This makes it draggable to `/Applications` and launchable from Finder/Spotlight.

### User data directories

A separate Chrome profile is used so CDP Chrome doesn't touch the user's normal Chrome data:

| OS      | Path |
|---------|------|
| macOS   | `~/Library/Application Support/ChromeDebug` |
| Linux   | `~/.config/chrome-debug` (respects `$XDG_CONFIG_HOME`) |
| Windows | `%LOCALAPPDATA%\ChromeDebug` |

## Building

Requires Go 1.21+.

```bash
tools/build.sh              # native binary (+ .app on macOS)
tools/build.sh macos        # universal binary + .app + zip
tools/build.sh linux        # amd64 binary + tarball with .desktop + install script
tools/build.sh windows      # amd64 exe + zip
tools/build.sh all          # all of the above
```

Output goes to `build/`. CI runs `tools/build.sh <target>` for each platform, so what CI does is exactly what you can do locally.

### Updating icons

Icons in `icons/` are committed to the repo. If you change `icon.svg`, regenerate them (requires ImageMagick, and iconutil on macOS for .icns):

```bash
tools/icons.sh
```

## Testing

```bash
tools/test.sh               # builds + smoke test
```

Manual test: run `build/cdpchrome`, then `curl http://localhost:9222/json/version` should return Chrome's version info.

## Releasing

```bash
tools/bump.sh               # 0.1.0 → 0.1.1
# or
tools/bump2.sh              # 0.1.0 → 0.2.0
git commit -am "v$(cat VERSION)"
tools/release.sh            # tags vX.Y.Z and pushes — CI builds + creates GitHub release
```

CI triggers on `v*` tags. The release job uploads platform zips/tarballs to the GitHub release with auto-generated notes.
