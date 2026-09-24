# Quantum v2

Minimal macOS WebKit browser. White-only interface, custom-drawn navigation and tab controls, real editable native address field, multiple independent WebKit tabs, local ranked history suggestions, search fallback and persistent WebKit website storage. No SwiftUI, Electron, npm, SQL, bundled engine, Xcode project or third-party code.

## Build on a Mac

```sh
xcode-select --install  # only if Command Line Tools missing
./build.sh
open Quantum.app
```

macOS 12+ required. The ZIP contains source, **not** a precompiled macOS application. The script prints the real compiled executable and bundle sizes. A native, usable browser cannot be honestly guaranteed to compile to 1 KB or 10 KB. WebKit website data is disk-persistent by design and cannot have an absolute 1 KB cap.

## Controls

- `⌘T` new tab; `⌘W` close tab; `⌘1`…`⌘9` switch tabs, or click tabs and ×.
- `⌘L` address/search; `⌘R` reload; `⌘[` / `⌘]` back/forward.
- Enter navigates; ↑/↓ select local suggestions; Escape closes them.
- Links requesting a new window open a new Quantum tab. Background tabs retain their independent navigation state.

Safari's private search suggestion service is **not available as a supported public API**. The implemented alternative ranks local history by hostname prefix, URL prefix and substring, then provides a web search action. It does not send keystrokes to a third-party autocomplete endpoint.

The controls are drawn with `NSView` and text via Cocoa drawing. The address field deliberately retains the native macOS text-editing engine for IME, accessibility, copy/paste and cursor behavior. The web content and storage use Apple's public WebKit APIs.
