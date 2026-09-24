# QUANTUM: Build the World's Smallest Usable Browser

Your objective is to build **the world's smallest practical macOS browser without sacrificing usability, performance, or design quality.** Reuse Apple's existing WebKit engine. Do not bundle browser engines, external dependencies, or unnecessary frameworks.

The target is **10 KB for the compressed source package**. Separately measure and aggressively minimize the compiled executable and complete `.app` bundle. Never confuse compressed source size with executable size.

## 1. Fix the Design

The current browser looks generic, unfinished, and ugly. Completely refine the interface.

- Browser background: pure white.
- Search/address bar: `stone-100` at 80% opacity.
- Add genuine native blur through lightweight macOS APIs, not fake translucent backgrounds or wallpaper blur.
- Custom-code the interface. Avoid SwiftUI, prebuilt Apple UI components, external styling libraries, and heavyweight design frameworks.
- Use native macOS rendering primitives only where necessary for real blur and window functionality.
- Make everything extremely clean, precise, responsive, and visually polished.
- All interactive elements must have correct cursor behavior and hit targets.

## 2. Essential Browser Features

Implement only the functionality necessary for a usable browser:

- Multiple tabs with dynamically fetched website favicons.
- New tab, close tab, reload, back, and forward.
- Lightweight bookmark functionality.
- A minimal history viewer.
- A compact dropdown offering **Standard Tabs** or **Vertical Tabs**.
- A collapsible sidebar for vertical tabs.
- Correct active-tab highlighting and tab switching.
- Proper website loading, navigation, and failure handling.

Use lightweight custom icons. Do not bundle icon libraries.

Remove search-engine integration, autocomplete, suggestion engines, analytics, and unnecessary browser features.

## 3. Storage and Caching

Reuse WebKit's existing persistent website data store and HTTP cache.

Do not invent a separate caching engine or duplicate stored website resources.

Store bookmarks, history, and tab preferences using the smallest practical local representation. No SQL, ORM, database server, or external storage dependency.

## 4. Strict Engineering Requirements

Choose the simplest reliable implementation, not the shortest code at the expense of correctness.

Avoid redundant abstractions, unnecessary allocations, repeated initialization, bundled assets, and duplicated browser state.

Build using Apple's command-line developer tools. No Xcode GUI or third-party build system.

Compile the application, inspect the actual binary size, measure the complete app bundle, and compress the source distribution.

**Report exact byte counts for all three.**

The 10 KB compressed-source target is mandatory. Minimize the executable independently without falsely claiming that it meets 10 KB.

Do not remove essential functionality merely to manipulate the size measurement.

The final result must be extraordinarily lightweight, genuinely usable, and visually refined.