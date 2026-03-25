package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"syscall"
)

var version = "dev"

func chromeAppBundle() (string, error) {
	candidates := []string{
		"/Applications/Google Chrome.app",
		filepath.Join(os.Getenv("HOME"), "Applications", "Google Chrome.app"),
	}
	for _, c := range candidates {
		if _, err := os.Stat(c); err == nil {
			return c, nil
		}
	}
	return "", fmt.Errorf("Google Chrome.app not found in Applications")
}

func chromeExecutable() (string, error) {
	switch runtime.GOOS {
	case "darwin":
		app, err := chromeAppBundle()
		if err != nil {
			return "", err
		}
		return filepath.Join(app, "Contents", "MacOS", "Google Chrome"), nil
	case "linux":
		for _, name := range []string{"google-chrome", "google-chrome-stable", "chromium-browser", "chromium"} {
			if p, err := exec.LookPath(name); err == nil {
				return p, nil
			}
		}
		candidates := []string{
			"/usr/bin/google-chrome-stable",
			"/usr/bin/google-chrome",
			"/usr/bin/chromium-browser",
			"/usr/bin/chromium",
			"/snap/bin/chromium",
		}
		for _, c := range candidates {
			if _, err := os.Stat(c); err == nil {
				return c, nil
			}
		}
		return "", fmt.Errorf("Chrome/Chromium not found — install google-chrome or chromium")
	case "windows":
		bases := []string{os.Getenv("PROGRAMFILES"), os.Getenv("PROGRAMFILES(X86)"), os.Getenv("LOCALAPPDATA")}
		for _, base := range bases {
			if base == "" {
				continue
			}
			p := filepath.Join(base, "Google", "Chrome", "Application", "chrome.exe")
			if _, err := os.Stat(p); err == nil {
				return p, nil
			}
		}
		return "", fmt.Errorf("Google Chrome not found in Program Files or LocalAppData")
	}
	return "", fmt.Errorf("unsupported OS: %s", runtime.GOOS)
}

func userDataDir() string {
	switch runtime.GOOS {
	case "darwin":
		return filepath.Join(os.Getenv("HOME"), "Library", "Application Support", "ChromeDebug")
	case "linux":
		if d := os.Getenv("XDG_CONFIG_HOME"); d != "" {
			return filepath.Join(d, "chrome-debug")
		}
		return filepath.Join(os.Getenv("HOME"), ".config", "chrome-debug")
	case "windows":
		return filepath.Join(os.Getenv("LOCALAPPDATA"), "ChromeDebug")
	}
	return filepath.Join(os.Getenv("HOME"), ".chrome-debug")
}

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
		fmt.Println("cdpchrome", version)
		return
	}

	args := []string{
		"--remote-debugging-port=9222",
		"--user-data-dir=" + userDataDir(),
	}
	args = append(args, os.Args[1:]...)

	// On macOS, use `open -a` to launch Chrome via LaunchServices.
	// This avoids App Management TCC blocks that happen when one app
	// directly executes another app's binary.
	if runtime.GOOS == "darwin" {
		app, err := chromeAppBundle()
		if err != nil {
			fmt.Fprintf(os.Stderr, "cdpchrome: %v\n", err)
			os.Exit(1)
		}
		openArgs := []string{"-n", "-a", app, "--args"}
		openArgs = append(openArgs, args...)
		cmd := exec.Command("open", openArgs...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "cdpchrome: %v\n", err)
			os.Exit(1)
		}
		return
	}

	chrome, err := chromeExecutable()
	if err != nil {
		fmt.Fprintf(os.Stderr, "cdpchrome: %v\n", err)
		os.Exit(1)
	}

	if runtime.GOOS == "windows" {
		cmd := exec.Command(chrome, args...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		if err := cmd.Start(); err != nil {
			fmt.Fprintf(os.Stderr, "cdpchrome: %v\n", err)
			os.Exit(1)
		}
		os.Exit(0)
	}

	// Linux CLI: exec replaces the process
	execArgs := append([]string{chrome}, args...)
	if err := syscall.Exec(chrome, execArgs, os.Environ()); err != nil {
		fmt.Fprintf(os.Stderr, "cdpchrome: exec: %v\n", err)
		os.Exit(1)
	}
}
