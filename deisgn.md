# Quantum interface language

Swift implementation guide for Quantum's hand-drawn macOS browser chrome. This replaces the former Tailwind and React conventions; it is a design specification for the AppKit renderer, not a SwiftUI component library.

## Visual direction

Quiet macOS browser chrome with a white reading canvas and compact controls. The tab strip stays visually light. A genuine, strongly blurred glass surface groups the navigation controls and address field; the blur comes from `NSVisualEffectView`, so the window backdrop remains visible through it. Keep contrast and spacing restrained. No shadows, gradients, decorative color, or dense borders.

## Surfaces and color

- Reading area: pure white (`NSColor.white`).
- Primary text and drawn glyphs: warm black (`#292725`).
- Secondary text: stone gray (`#78716c`).
- Active tab: translucent stone white (`#f5f5f4` at 90%).
- Address well: `NSVisualEffectView` using a light popover material, clipped to an 11 pt radius.
- Toolbar backing: `NSVisualEffectView` using under-window material, clipped to a 15 pt radius.
- Keep all fills light. Use no high-contrast strokes; separate regions with space and gentle surface changes.

## Layout

- Window minimum: 460 × 320 pt.
- Tab strip: 44 pt high, 12 pt side inset, 174 pt tab rhythm.
- Navigation surface: 52 pt high with 14 pt window gutters.
- Address field: 36 pt high, 12 pt text inset.
- Content fills the remaining window and stays white.
- Keep controls in a single calm row; allow the tab strip to scroll horizontally when tabs exceed available width.

## Type and controls

- Use the system sans family at regular weight. Tab and address labels are 12–13 pt.
- Draw navigation symbols in a custom `NSView`; use 16 pt glyph geometry and 34 × 36 pt hit targets.
- Active and hover feedback use only a subtle stone fill. Keep cursor, focus, and keyboard behavior clear.
- The editable address field remains borderless and background-free so text input, selection, IME, and accessibility work normally.

## Implementation boundaries

- Use Swift with AppKit and WebKit. Do not introduce SwiftUI, third-party UI frameworks, or image icon libraries.
- Use AppKit's visual effect view only for real system blur and standard window behavior; draw the visible browser chrome yourself.
- Safari's Web Inspector is supplied by WebKit. Keep the web view inspectable on supported macOS versions; do not build an in-app inspector.
- Keep SVG assets minified. Use only the supplied, compact path geometry when an SVG asset is needed.
