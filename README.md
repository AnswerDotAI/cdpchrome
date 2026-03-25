# cdpchrome

Launch Google Chrome with [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) (CDP) remote debugging enabled. A standalone binary that works from the command line, Finder, Explorer, or Linux desktop launchers.

Chrome is launched with `--remote-debugging-port=9222` and a dedicated user data directory so it doesn't interfere with your normal Chrome profile.

## Install

**macOS**:
```bash
curl -fsSL https://raw.githubusercontent.com/AnswerDotAI/cdpchrome/main/install-mac.sh | bash
```

This downloads the latest release and installs `CDP Chrome.app` to Applications.

Alternatively, download from [Releases](../../releases), unzip, and drag to Applications. If you install this way, macOS will block the app on first launch because it's not signed — go to **System Settings > Privacy & Security** and click **Open Anyway**.

**Linux**: Extract the tarball and run the install script:
```bash
tar xzf cdpchrome-linux-amd64.tar.gz
./install.sh            # installs to ~/.local by default
./install.sh /usr/local # or system-wide
```

**Windows**: Unzip and run `cdpchrome.exe`.

## Usage

```bash
cdpchrome                    # launch Chrome with CDP on port 9222
cdpchrome https://example.com  # open a specific URL
```

Then connect to CDP at `http://localhost:9222`.

### User data directories

A separate profile is used so CDP Chrome doesn't conflict with your regular Chrome:

| OS | Path |
|---|---|
| macOS | `~/Library/Application Support/ChromeDebug` |
| Linux | `~/.config/chrome-debug` |
| Windows | `%LOCALAPPDATA%\ChromeDebug` |

## Development

See [DEV.md](DEV.md) for building from source, releasing, and internals.
