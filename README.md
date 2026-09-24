# Quantum

A tiny browser for macOS. Quantum is roughly 1,700 lines of Swift that wrap Apple's own WebKit — no Electron, no bundled engine, no npm, no Xcode project, no third-party libraries.

It exists to answer one question: how little code does a browser you'd actually use every day need?

[![Build](https://github.com/duggal1/quantum/actions/workflows/build.yml/badge.svg)](https://github.com/duggal1/quantum/actions/workflows/build.yml)

## Download

Grab `Quantum.dmg` from the [latest release](../../releases/latest), open it, and drag Quantum into Applications.

- **Apple Silicon only.** Built for arm64 on macOS 15 or later.
- The app is ad-hoc signed, not notarized, so macOS will ask the first time. Right-click the app and choose **Open**, or run `xattr -dr com.apple.quarantine /Applications/Quantum.app`.

## Demo

_Video coming soon._

<!--
Paste the demo video here. Easiest way on GitHub: drag the file into the
README edit box in the browser and GitHub uploads and links it for you.

<video src="URL_GOES_HERE" controls></video>
-->

## What you get

- **Tabs** that show each site's real favicon, in a top strip or a vertical sidebar. Pick either from the tabs menu.
- **Back, forward, reload, new tab, close tab** — plus `⌘1`…`⌘9` to jump straight to a tab.
- **Pins** (bookmarks) with one-click remove, and a compact **history** viewer.
- **Local suggestions** from your own history and pins, then a Google search fallback. Typed URL-like input is never sent to a suggest service.
- **A real address field.** It's the native macOS text engine, so IME, copy/paste and cursor behaviour are what you already expect.
- **Native blur** on the sidebar, drawn with `NSVisualEffectView`. It falls back to a plain panel in fullscreen, where there's nothing behind the window to blur.
- **WebKit's own storage and HTTP cache**, so logins and site data persist and nothing is cached twice.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `⌘T` / `⌘W` | New tab / close tab |
| `⌘1`…`⌘9` | Switch to tab |
| `⌘L` | Focus the address field |
| `⌘R` | Reload |
| `⌘[` / `⌘]` | Back / forward |
| `⌘B` | Toggle the sidebar |
| `↑` `↓` `↩` `esc` | Move through suggestions, open one, dismiss them |

## Build it

Only Apple's command line tools are needed — no Xcode GUI.

```sh
./build.sh    # compiles Quantum.app
./dmg.sh      # compiles it and wraps it in Quantum.dmg
open Quantum.app
```

If `swiftc` isn't there yet, install the toolchain with `xcode-select --install`. Builds target the architecture of the machine you run them on.

## Honest sizes

Measured on the current source, arm64, `-Osize -whole-module-optimization`:

| Artifact | Size |
| --- | --- |
| Executable (`Quantum.app/Contents/MacOS/Quantum`) | 217,168 bytes |
| Complete `.app` bundle | 339,145 bytes (344 KiB on disk) |
| `Quantum.dmg` (ULMO compressed) | 149,692 bytes |
| Source ZIP | 64,684 bytes |

There's a limit to how small this can go. A Swift binary that links AppKit and WebKit starts around 200 KB on its own, and the icon is the only other meaningful weight. Quantum is small because it has almost no code in it, not because anything was stripped out of the feature list.

## Under the hood

All interface code is hand-drawn with `NSView`, Core Graphics and Cocoa text rendering — the chrome, the icons, the tab strip and the dropdown cards. There's no SwiftUI, no storyboard and no bundled icon set. The one exception is the address field, which deliberately keeps AppKit's native text editing, and the visual effect views that provide real blur. Rendering, storage and the network cache are Apple's public WebKit APIs.

Site theme detection samples what a page actually looks like and re-skins the dropdown cards to match, so a dark site gets a dark card without ever changing the app's own chrome.

## Known limitations

- Ad-hoc signed, so Gatekeeper needs one right-click on first launch.
- Apple Silicon and macOS 15+ only.
- Suggestions come from your local history plus Google's autocomplete endpoint. Keeping even fewer bits of data in the cloud was a simple query with no tracking, and it means no Apple suggest service — that isn't a public API.

## License

MIT.
