import AppKit
import WebKit

// MARK: - Palette

/// Colors for a button or card surface.
/// The chrome (sidebar, toolbar, address bar, window) only ever uses `.light`.
/// Only dropdown cards switch to `.dark`, and only when the current site is dark.
private struct Palette {
    let ink, secondaryInk, glyph, hover, active, tint, border: NSColor
    let appearance: NSAppearance?

    static let light = Palette(
        ink: NSColor(calibratedWhite: 0.07, alpha: 1),
        secondaryInk: NSColor(calibratedWhite: 0.40, alpha: 1),
        glyph: NSColor(calibratedWhite: 0.15, alpha: 1),
        hover: NSColor(calibratedWhite: 0, alpha: 0.055),
        active: NSColor(calibratedWhite: 0, alpha: 0.10),
        tint: NSColor(calibratedWhite: 1, alpha: 0.60),
        border: NSColor(calibratedWhite: 0, alpha: 0.08),
        appearance: NSAppearance(named: .aqua)
    )

    // Same material, radius, border width and layout as the light card. The tint is almost nothing
    // on purpose: a heavy tint over the dark material is what made it look like flat grey.
    // Knobs if you want it lighter/darker: `tint` alpha and `border` alpha.
    static let dark = Palette(
        ink: NSColor(calibratedWhite: 0.98, alpha: 1),
        secondaryInk: NSColor(calibratedWhite: 0.70, alpha: 1),
        glyph: NSColor(calibratedWhite: 0.92, alpha: 1),
        hover: NSColor(calibratedWhite: 1, alpha: 0.09),
        active: NSColor(calibratedWhite: 1, alpha: 0.16),
        tint: NSColor(calibratedWhite: 1, alpha: 0.06),
        border: NSColor(calibratedWhite: 1, alpha: 0.16),
        appearance: NSAppearance(named: .darkAqua)
    )
}

private enum ChromePalette {
    static let background = NSColor(calibratedWhite: 1, alpha: 1)
    static let sidebarBackground = NSColor(calibratedWhite: 0.965, alpha: 1)
    // Same stone-100 veil, translucent so the native sidebar blur reads through it.
    static let sidebarGlass = NSColor(calibratedWhite: 1, alpha: 0.62)
    static let glassTint = NSColor(calibratedWhite: 1, alpha: 0.55)
    static let wellTint = NSColor(calibratedWhite: 0.94, alpha: 0.90)

    // Loading line: one flat neon purple (#BC13FE), no gradient
    static let neon = NSColor(srgbRed: 188 / 255, green: 19 / 255, blue: 254 / 255, alpha: 1)

    // Tailwind stone-900 / stone-800. A toggled-on icon (bookmark) fills with stone-900
    // instead of painting the hover-style background layer.
    static let stone900 = NSColor(srgbRed: 28 / 255, green: 25 / 255, blue: 23 / 255, alpha: 1)
    static let stone800 = NSColor(srgbRed: 41 / 255, green: 37 / 255, blue: 36 / 255, alpha: 1)
}

// MARK: - SVG path support (for the Phosphor icons)

private enum SVGPath {
    static let pin = "M235.32,81.37,174.63,20.69a16,16,0,0,0-22.63,0L98.37,74.49c-10.66-3.34-35-7.37-60.4,13.14a16,16,0,0,0-1.29,23.78L85,159.71,42.34,202.34a8,8,0,0,0,11.32,11.32L96.29,171l48.29,48.29A16,16,0,0,0,155.9,224c.38,0,.75,0,1.13,0a15.93,15.93,0,0,0,11.64-6.33c19.64-26.1,17.75-47.32,13.19-60L235.33,104A16,16,0,0,0,235.32,81.37ZM224,92.69h0l-57.27,57.46a8,8,0,0,0-1.49,9.22c9.46,18.93-1.8,38.59-9.34,48.62L48,100.08c12.08-9.74,23.64-12.31,32.48-12.31A40.13,40.13,0,0,1,96.81,91a8,8,0,0,0,9.25-1.51L163.32,32,224,92.68Z"

    static let toggle = "M176,56H80a72,72,0,0,0,0,144h96a72,72,0,0,0,0-144Zm0,128H80A56,56,0,0,1,80,72h96a56,56,0,0,1,0,112ZM80,88a40,40,0,1,0,40,40A40,40,0,0,0,80,88Zm0,64a24,24,0,1,1,24-24A24,24,0,0,1,80,152Z"

    /// Open/forward arrow shown flush right on suggestion rows (256x256 viewBox).
    static let open = "M200,32V176a8,8,0,0,1-8,8H67.31l34.35,34.34a8,8,0,0,1-11.32,11.32l-48-48a8,8,0,0,1,0-11.32l48-48a8,8,0,0,1,11.32,11.32L67.31,168H184V32a8,8,0,0,1,16,0Z"

    /// Quantum mark (16x24 viewBox), drawn into the sidebar header instead of the wordmark text.
    static let logo = "M13.4729 0H13.5075L13.5087 11.321C13.1699 11.1139 12.7725 10.8998 12.4245 10.6991L9.81099 9.19556L8.97062 8.71318C8.83216 8.63377 8.63517 8.52811 8.50556 8.44149C8.48063 8.97682 8.49819 9.65724 8.49819 10.2051L8.49795 13.4249L8.49804 15.7084C8.4981 16.0087 8.48112 16.5996 8.50591 16.8736C8.65217 16.8004 8.98168 16.7026 9.14905 16.6479L10.1971 16.3014L13.4508 15.2136L14.58 14.839C14.7838 14.7713 15.0158 14.7018 15.2118 14.6228C15.3665 14.9493 15.4536 15.3092 15.5158 15.6635C15.7214 16.8412 15.617 18.0519 15.2129 19.1771C14.3315 21.6506 11.9691 23.3342 9.4281 23.6322C9.37419 23.6385 9.27382 23.6458 9.22527 23.6582H8.41089C8.23635 23.62 7.95246 23.5969 7.76443 23.5685C7.3887 23.5117 7.01905 23.4201 6.66023 23.2951C4.99833 22.7301 3.45184 21.5302 2.65527 19.9473C2.57278 19.7833 2.28311 19.0765 2.34022 18.9438C2.36289 18.8913 3.46564 18.5443 3.57453 18.5078L6.64516 17.4834C7.20131 17.2986 7.85842 17.0975 8.40139 16.8916C7.81065 16.9217 7.16523 16.9103 6.57041 16.9107L3.65498 16.911L1.23928 16.9117C0.872001 16.9118 0.350444 16.9306 0 16.9084V8.43405L8.50374 8.43587C8.03831 8.18839 7.58636 7.91809 7.12936 7.65501L5.21408 6.55409L4.27291 6.0158C4.10553 5.91995 3.83445 5.77265 3.68914 5.65746C3.79584 5.63125 4.23539 5.35716 4.35146 5.28871L5.26359 4.75911L10.8186 1.54165L12.6612 0.477095C12.835 0.376888 13.344 0.105296 13.4729 0Z"

    /// Rasterises a parsed path (SVG's y-down space) into an image of the requested size.
    static func image(_ d: String, viewBox: CGSize, size: NSSize, color: NSColor) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: size.width / viewBox.width, y: -size.height / viewBox.height)
            context.addPath(parse(d))
            context.setFillColor(color.cgColor)
            context.fillPath(using: .evenOdd)
        }
        image.unlockFocus()
        return image
    }

    /// Minimal SVG path parser: M L H V C S A Z (absolute + relative). Enough for Phosphor icons.
    static func parse(_ d: String) -> CGPath {
        let s = Array(d.utf8)
        var i = 0
        let path = CGMutablePath()
        var cur = CGPoint.zero
        var start = CGPoint.zero
        var cmd: UInt8 = 0
        var lastCubic: CGPoint? = nil

        func isSeparator(_ c: UInt8) -> Bool { c == 32 || c == 44 || c == 9 || c == 10 || c == 13 }
        func isDigit(_ c: UInt8) -> Bool { c >= 48 && c <= 57 }
        func skipSeparators() { while i < s.count && isSeparator(s[i]) { i += 1 } }

        func number() -> CGFloat? {
            skipSeparators()
            let begin = i
            var j = i
            if j < s.count && (s[j] == 43 || s[j] == 45) { j += 1 }
            var digits = false
            while j < s.count && isDigit(s[j]) { j += 1; digits = true }
            if j < s.count && s[j] == 46 {
                j += 1
                while j < s.count && isDigit(s[j]) { j += 1; digits = true }
            }
            guard digits else { return nil }
            if j < s.count && (s[j] == 101 || s[j] == 69) {
                var k = j + 1
                if k < s.count && (s[k] == 43 || s[k] == 45) { k += 1 }
                if k < s.count && isDigit(s[k]) {
                    while k < s.count && isDigit(s[k]) { k += 1 }
                    j = k
                }
            }
            i = j
            guard let value = Double(String(decoding: s[begin..<j], as: UTF8.self)) else { return nil }
            return CGFloat(value)
        }

        func flag() -> Bool? {
            skipSeparators()
            guard i < s.count, s[i] == 48 || s[i] == 49 else { return nil }
            let value = s[i] == 49
            i += 1
            return value
        }

        while true {
            skipSeparators()
            guard i < s.count else { break }
            let c = s[i]
            if (c >= 65 && c <= 90) || (c >= 97 && c <= 122) {
                cmd = c
                i += 1
                if cmd == 90 || cmd == 122 {
                    path.closeSubpath()
                    cur = start
                    lastCubic = nil
                    continue
                }
            } else if cmd == 0 || cmd == 90 || cmd == 122 {
                break
            }

            let relative = cmd >= 97
            let upper = relative ? cmd - 32 : cmd
            let ox: CGFloat = relative ? cur.x : 0
            let oy: CGFloat = relative ? cur.y : 0
            let previousCubic = lastCubic
            lastCubic = nil

            switch upper {
            case 77: // M
                guard let x = number(), let y = number() else { return path }
                cur = CGPoint(x: ox + x, y: oy + y)
                start = cur
                path.move(to: cur)
                cmd = relative ? 108 : 76 // extra pairs are implicit lineto
            case 76: // L
                guard let x = number(), let y = number() else { return path }
                cur = CGPoint(x: ox + x, y: oy + y)
                path.addLine(to: cur)
            case 72: // H
                guard let x = number() else { return path }
                cur = CGPoint(x: ox + x, y: cur.y)
                path.addLine(to: cur)
            case 86: // V
                guard let y = number() else { return path }
                cur = CGPoint(x: cur.x, y: oy + y)
                path.addLine(to: cur)
            case 67: // C
                guard let x1 = number(), let y1 = number(), let x2 = number(), let y2 = number(), let x = number(), let y = number() else { return path }
                let c1 = CGPoint(x: ox + x1, y: oy + y1)
                let c2 = CGPoint(x: ox + x2, y: oy + y2)
                cur = CGPoint(x: ox + x, y: oy + y)
                path.addCurve(to: cur, control1: c1, control2: c2)
                lastCubic = c2
            case 83: // S
                guard let x2 = number(), let y2 = number(), let x = number(), let y = number() else { return path }
                var c1 = cur
                if let previous = previousCubic { c1 = CGPoint(x: 2 * cur.x - previous.x, y: 2 * cur.y - previous.y) }
                let c2 = CGPoint(x: ox + x2, y: oy + y2)
                cur = CGPoint(x: ox + x, y: oy + y)
                path.addCurve(to: cur, control1: c1, control2: c2)
                lastCubic = c2
            case 65: // A
                guard let rx = number(), let ry = number(), let rotation = number(), let large = flag(), let sweep = flag(), let x = number(), let y = number() else { return path }
                let end = CGPoint(x: ox + x, y: oy + y)
                addArc(to: path, from: cur, rx: rx, ry: ry, rotation: rotation, large: large, sweep: sweep, end: end)
                cur = end
            default:
                return path
            }
        }
        return path
    }

    private static func addArc(to path: CGMutablePath, from p0: CGPoint, rx rxIn: CGFloat, ry ryIn: CGFloat, rotation: CGFloat, large: Bool, sweep: Bool, end p1: CGPoint) {
        var rx = abs(rxIn)
        var ry = abs(ryIn)
        if rx == 0 || ry == 0 || (p0.x == p1.x && p0.y == p1.y) {
            path.addLine(to: p1)
            return
        }
        let twoPi: CGFloat = 2 * CGFloat.pi
        let phi = rotation * CGFloat.pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)
        let dx = (p0.x - p1.x) / 2
        let dy = (p0.y - p1.y) / 2
        let x1p = cosPhi * dx + sinPhi * dy
        let y1p = -sinPhi * dx + cosPhi * dy

        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 {
            let k = lambda.squareRoot()
            rx *= k
            ry *= k
        }

        let rx2 = rx * rx
        let ry2 = ry * ry
        let numerator = rx2 * ry2 - rx2 * y1p * y1p - ry2 * x1p * x1p
        let denominator = rx2 * y1p * y1p + ry2 * x1p * x1p
        var coefficient = max(0, numerator / denominator).squareRoot()
        if large == sweep { coefficient = -coefficient }

        let cxp = coefficient * rx * y1p / ry
        let cyp = -coefficient * ry * x1p / rx
        let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2

        let ux = (x1p - cxp) / rx
        let uy = (y1p - cyp) / ry
        let vx = (-x1p - cxp) / rx
        let vy = (-y1p - cyp) / ry

        let theta1 = atan2(uy, ux)
        var delta = atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        if !sweep && delta > 0 { delta -= twoPi } else if sweep && delta < 0 { delta += twoPi }

        let segments = max(1, Int(ceil(abs(delta) / (CGFloat.pi / 2))))
        let step = delta / CGFloat(segments)
        let t: CGFloat = (4.0 / 3.0) * tan(step / 4)

        func map(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            let px = rx * x
            let py = ry * y
            return CGPoint(x: cosPhi * px - sinPhi * py + cx, y: sinPhi * px + cosPhi * py + cy)
        }

        var theta = theta1
        for _ in 0..<segments {
            let cos1 = cos(theta)
            let sin1 = sin(theta)
            let cos2 = cos(theta + step)
            let sin2 = sin(theta + step)
            path.addCurve(
                to: map(cos2, sin2),
                control1: map(cos1 - t * sin1, sin1 + t * cos1),
                control2: map(cos2 + t * sin2, sin2 - t * cos2)
            )
            theta += step
        }
    }
}

// MARK: - Favicon store (keyed by host, memory + disk)

/// One icon per site, shared by tabs, sidebar and every dropdown card.
/// Disk copies live in Caches so history/pinned rows show real icons after a relaunch too.
private enum FaviconStore {
    private static var memory: [String: NSImage] = [:]
    private static let directory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = base.appendingPathComponent("QuantumFavicons", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    /// "https://www.apple.com/apple-card/" -> "apple.com"
    static func key(for rawURL: String) -> String? {
        guard let host = URL(string: rawURL)?.host?.lowercased(), !host.isEmpty else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private static func file(for key: String) -> URL {
        let safe = key.map { $0.isLetter || $0.isNumber || $0 == "." || $0 == "-" ? $0 : "_" }
        return directory.appendingPathComponent(String(safe) + ".png")
    }

    static func image(for key: String) -> NSImage? {
        if let cached = memory[key] { return cached }
        guard let image = NSImage(contentsOf: file(for: key)) else { return nil }
        memory[key] = image
        return image
    }

    static func save(_ image: NSImage, for key: String) {
        memory[key] = image
        // Normalize to a 64px PNG so multi-size .ico files don't save their smallest frame.
        let normalized = NSImage(size: NSSize(width: 64, height: 64), flipped: false) { rect in
            image.draw(in: rect)
            return true
        }
        guard let tiff = normalized.tiffRepresentation,
              let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) else { return }
        try? png.write(to: file(for: key))
    }
}

// MARK: - Chrome button

private enum Glyph {
    case stroke(CGPath)
    case fill(CGPath)
}

private final class ChromeButton: NSView {
    static let tooltips: [String: String] = [
        "back": "Back", "forward": "Forward", "reload": "Reload",
        "bookmark": "Bookmark this page", "history": "History",
        "sliders": "Tabs and sidebar", "sidebar": "Toggle sidebar",
        "+": "New tab", "×": "Close"
    ]

    var symbol = ""
    /// Optional glyph drawn flush right, e.g. the open arrow on suggestion rows.
    var trailing = "" { didSet { needsDisplay = true } }
    /// Toggled-on buttons (bookmark) paint a solid stone-900 icon instead of a background layer.
    var fillWhenActive = false { didSet { needsDisplay = true } }
    var title = "" { didSet { needsDisplay = true } }
    var image: NSImage? { didSet { needsDisplay = true } }
    var active = false { didSet { needsDisplay = true } }
    var palette = Palette.light { didSet { needsDisplay = true } }
    var trailingInset: CGFloat = 10
    var action: (() -> Void)?
    private var hovered = false { didSet { needsDisplay = true } }

    override var isFlipped: Bool { true }
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self))
    }
    override func mouseEntered(with event: NSEvent) { hovered = true }
    override func mouseExited(with event: NSEvent) { hovered = false }
    override func mouseUp(with event: NSEvent) { action?() }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    private static var glyphCache: [String: Glyph] = [:]

    private static func glyph(for symbol: String) -> Glyph? {
        if let cached = glyphCache[symbol] { return cached }
        let path = CGMutablePath()
        var filled: CGPath? = nil

        switch symbol {
        case "back":
            path.move(to: CGPoint(x: 165, y: 42)); path.addLine(to: CGPoint(x: 80, y: 128)); path.addLine(to: CGPoint(x: 165, y: 214))
        case "forward":
            path.move(to: CGPoint(x: 91, y: 42)); path.addLine(to: CGPoint(x: 176, y: 128)); path.addLine(to: CGPoint(x: 91, y: 214))
        case "reload":
            path.addArc(center: CGPoint(x: 128, y: 128), radius: 76, startAngle: 40 * .pi / 180, endAngle: 310 * .pi / 180, clockwise: false)
            path.move(to: CGPoint(x: 202, y: 52)); path.addLine(to: CGPoint(x: 204, y: 111)); path.addLine(to: CGPoint(x: 146, y: 108))
        case "bookmark":
            path.move(to: CGPoint(x: 66, y: 32)); path.addLine(to: CGPoint(x: 190, y: 32)); path.addLine(to: CGPoint(x: 190, y: 224)); path.addLine(to: CGPoint(x: 128, y: 185)); path.addLine(to: CGPoint(x: 66, y: 224)); path.closeSubpath()
        case "sidebar":
            path.addRoundedRect(in: CGRect(x: 38, y: 40, width: 180, height: 176), cornerWidth: 18, cornerHeight: 18)
            path.move(to: CGPoint(x: 94, y: 42)); path.addLine(to: CGPoint(x: 94, y: 214))
        case "history":
            path.addArc(center: CGPoint(x: 128, y: 128), radius: 83, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            path.move(to: CGPoint(x: 128, y: 73)); path.addLine(to: CGPoint(x: 128, y: 130)); path.addLine(to: CGPoint(x: 169, y: 153))
        case "globe": // fallback while a site's favicon is still loading (or has none)
            path.addEllipse(in: CGRect(x: 45, y: 45, width: 166, height: 166))
            path.addEllipse(in: CGRect(x: 90, y: 45, width: 76, height: 166))
            path.move(to: CGPoint(x: 45, y: 128)); path.addLine(to: CGPoint(x: 211, y: 128))
        case "search": // "Search Google for ..." row and Google suggestion rows
            path.addEllipse(in: CGRect(x: 44, y: 44, width: 120, height: 120))
            path.move(to: CGPoint(x: 148, y: 148)); path.addLine(to: CGPoint(x: 210, y: 210))
        case "open":
            filled = SVGPath.parse(SVGPath.open)
        case "+":
            path.move(to: CGPoint(x: 128, y: 48)); path.addLine(to: CGPoint(x: 128, y: 208))
            path.move(to: CGPoint(x: 48, y: 128)); path.addLine(to: CGPoint(x: 208, y: 128))
        case "×":
            path.move(to: CGPoint(x: 60, y: 60)); path.addLine(to: CGPoint(x: 196, y: 196))
            path.move(to: CGPoint(x: 196, y: 60)); path.addLine(to: CGPoint(x: 60, y: 196))
        case "sliders":
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * 256 / 24, y: y * 256 / 24) }
            path.move(to: p(3, 7)); path.addLine(to: p(6, 7)); path.move(to: p(3, 17)); path.addLine(to: p(9, 17))
            path.move(to: p(18, 17)); path.addLine(to: p(21, 17)); path.move(to: p(15, 7)); path.addLine(to: p(21, 7))
            path.move(to: p(6, 7)); path.addCurve(to: p(12, 7), control1: p(6, 5.9), control2: p(6, 5.2)); path.addCurve(to: p(11.85, 8.77), control1: p(12, 8.3), control2: p(11.94, 8.57)); path.addCurve(to: p(10.77, 9.85), control1: p(11.44, 9.48), control2: p(11.1, 9.83)); path.addCurve(to: p(7.23, 9.85), control1: p(9.93, 10), control2: p(8.07, 10)); path.addCurve(to: p(6, 7), control1: p(6.56, 9.48), control2: p(6, 8.3)); path.closeSubpath()
            path.move(to: p(12, 17)); path.addCurve(to: p(18, 17), control1: p(12, 15.9), control2: p(12, 15.2)); path.addCurve(to: p(17.85, 18.77), control1: p(18, 18.3), control2: p(17.94, 18.57)); path.addCurve(to: p(16.77, 19.85), control1: p(17.44, 19.48), control2: p(17.1, 19.83)); path.addCurve(to: p(13.23, 19.85), control1: p(15.93, 20), control2: p(14.07, 20)); path.addCurve(to: p(12, 17), control1: p(12.56, 19.48), control2: p(12, 18.3)); path.closeSubpath()
        case "pin":
            filled = SVGPath.parse(SVGPath.pin)
        case "tabs":
            filled = SVGPath.parse(SVGPath.toggle)
        default:
            return nil
        }

        let result: Glyph
        if let filled { result = .fill(filled) } else { result = .stroke(path) }
        glyphCache[symbol] = result
        return result
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let graphicsContext = NSGraphicsContext.current else { return }
        let context = graphicsContext.cgContext
        let iconSize: CGFloat = 14
        let iconY = (self.bounds.height - iconSize) / 2

        // A toggled-on bookmark reads as a filled icon, not as a background layer.
        let solid = fillWhenActive && active
        if (active || hovered) && !solid {
            (active ? palette.active : palette.hover).setFill()
            NSBezierPath(roundedRect: self.bounds.insetBy(dx: 2, dy: 3), xRadius: 9, yRadius: 9).fill()
        }

        if !symbol.isEmpty, let glyph = ChromeButton.glyph(for: symbol) {
            context.saveGState()
            let iconX = title.isEmpty ? (self.bounds.width - iconSize) / 2 : 12
            context.translateBy(x: iconX, y: iconY)
            context.scaleBy(x: iconSize / 256, y: iconSize / 256)
            let tint = solid ? ChromePalette.stone900.cgColor : palette.glyph.cgColor
            switch glyph {
            case .stroke(let path):
                if solid {
                    context.setFillColor(tint)
                    context.addPath(path)
                    context.fillPath(using: .evenOdd)
                }
                context.setStrokeColor(tint)
                context.setLineWidth(16)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.addPath(path)
                context.strokePath()
            case .fill(let path):
                context.setFillColor(tint)
                context.addPath(path)
                context.fillPath(using: .evenOdd)
            }
            context.restoreGState()
        }

        if !trailing.isEmpty, let glyph = ChromeButton.glyph(for: trailing) {
            context.saveGState()
            context.translateBy(x: self.bounds.width - iconSize - 12, y: iconY)
            context.scaleBy(x: iconSize / 256, y: iconSize / 256)
            switch glyph {
            case .stroke(let path):
                context.setStrokeColor(palette.secondaryInk.cgColor)
                context.setLineWidth(16)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.addPath(path)
                context.strokePath()
            case .fill(let path):
                context.setFillColor(palette.secondaryInk.cgColor)
                context.addPath(path)
                context.fillPath(using: .evenOdd)
            }
            context.restoreGState()
        }

        if let image {
            let rect = NSRect(x: 12, y: iconY, width: iconSize, height: iconSize)
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3).addClip()
            image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
            NSGraphicsContext.restoreGraphicsState()
        }

        if !title.isEmpty {
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byTruncatingTail
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: active ? .medium : .regular),
                .foregroundColor: palette.ink,
                .paragraphStyle: style
            ]
            let text = title as NSString
            let textHeight = ceil(text.size(withAttributes: attributes).height)
            let originX: CGFloat = (symbol.isEmpty && image == nil) ? 12 : 34
            let width = max(0, self.bounds.width - originX - trailingInset - (trailing.isEmpty ? 0 : 26))
            text.draw(in: NSRect(x: originX, y: (self.bounds.height - textHeight) / 2, width: width, height: textHeight), withAttributes: attributes)
        }
    }
}

// MARK: - Models

private final class BrowserTab {
    let webView: WKWebView
    var title = "New Tab"
    var isHome = true
    var isDark = false
    var favicon: NSImage?
    var progressObservation: NSKeyValueObservation?
    var loadingObservation: NSKeyValueObservation?
    init(_ webView: WKWebView) { self.webView = webView }
}

private enum ProgressState {
    case idle, loading, finishing
}

/// One row in a dropdown card. Rows with a `url` get that site's real favicon.
private struct PanelRow {
    let symbol: String
    let title: String
    var url: String? = nil
    let action: () -> Void
}

// MARK: - App

@main
private final class Quantum: NSObject, NSApplicationDelegate, NSTextFieldDelegate, WKNavigationDelegate, WKUIDelegate {
    private var window: NSWindow!
    private var pages: NSView!
    private var root: NSView!
    private var center: NSView!
    private var sidebar: NSView!
    private var sidebarBlur: NSVisualEffectView!
    private var sidebarTint: NSView!
    private var sidebarRows: NSView!
    private var tabsBar: NSView!
    private var toolbar: NSView!
    private var centerLeadingSidebar: NSLayoutConstraint!
    private var centerLeadingRoot: NSLayoutConstraint!
    private var toolbarTopTabs: NSLayoutConstraint!
    private var toolbarTopCenter: NSLayoutConstraint!
    private var backLeadingSidebarToggle: NSLayoutConstraint!
    private var backLeadingToolbar: NSLayoutConstraint!
    private var sidebarToggle: ChromeButton!
    private var addressWell: NSVisualEffectView!
    private var loadingIndicator: NSProgressIndicator!
    private var progressTrack: NSView!
    private var progressWidth: NSLayoutConstraint!
    private var bookmarkButton: ChromeButton!
    private var tabDocument: NSView!
    private var tabScroll: NSScrollView!
    private var address: NSTextField!
    private var tabs: [BrowserTab] = []
    private var currentIndex = -1
    private var history: [String] = UserDefaults.standard.stringArray(forKey: "history") ?? []
    private var bookmarks: [String] = {
        let saved = UserDefaults.standard.stringArray(forKey: "bookmarks") ?? []
        // Seed one removable default pin, once per install, without ever clobbering real pins.
        if UserDefaults.standard.bool(forKey: "pinsSeeded") || !saved.isEmpty { return saved }
        let seeded = ["https://www.google.com/"]
        UserDefaults.standard.set(true, forKey: "pinsSeeded")
        UserDefaults.standard.set(seeded, forKey: "bookmarks")
        return seeded
    }()
    private var tabMode = UserDefaults.standard.string(forKey: "tabMode") ?? "vertical"
    private var sidebarCollapsed = false
    private var overlayCard: NSVisualEffectView?
    private var overlayTint: NSView?
    private var overlayHeading: NSTextField?
    private var overlayRows: [(button: ChromeButton, url: String)] = []
    private var currentThemeIsDark = false // theme of the current site; only the dropdown card follows it
    private var spinnerOn = false
    private var progressState: ProgressState = .idle
    private var progressGeneration = 0
    private var watchProgress: CGFloat = 0
    private var loadWatchdog: DispatchWorkItem?
    private var faviconRequests = Set<String>()
    private lazy var faviconSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()
    private var googleSuggestions: [String] = []
    private var suggestWork: DispatchWorkItem?
    private var suggestTask: URLSessionDataTask?
    private lazy var suggestSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    private var currentTab: BrowserTab? { tabs.indices.contains(currentIndex) ? tabs[currentIndex] : nil }
    private var cardPalette: Palette { currentThemeIsDark ? .dark : .light }
    private var typedQuery: String { address.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Safari-format tail for the user agent. WKWebView's default UA has no "Version/x Safari/x" token, so sites
    /// (Google included) can treat it as an unknown browser. Safari's major version tracks the macOS major (26, 27, ...).
    private static let userAgentSuffix = "Version/\(max(26, ProcessInfo.processInfo.operatingSystemVersion.majorVersion)).0 Safari/605.1.15"

    /// Strict unreserved set for query values, so "&", "+", "#" or "=" in a search can't break the URL.
    private static let queryAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    static func main() {
        let application = NSApplication.shared
        let delegate = Quantum()
        application.delegate = delegate
        application.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.appearance = NSAppearance(named: .aqua)
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"), let icon = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = icon
        }
        makeMenus()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1050, height: 730), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Quantum"
        window.minSize = NSSize(width: 460, height: 320)
        window.backgroundColor = .white
        window.center()
        buildChrome()
        addTab()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: Chrome

    private func makeTint(in parent: NSView, radius: CGFloat) -> NSView {
        let tint = NSView()
        tint.translatesAutoresizingMaskIntoConstraints = false
        tint.wantsLayer = true
        tint.layer?.cornerRadius = radius
        tint.layer?.borderWidth = 0.5
        parent.addSubview(tint)
        NSLayoutConstraint.activate([
            tint.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            tint.topAnchor.constraint(equalTo: parent.topAnchor),
            tint.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
        return tint
    }

    private func buildChrome() {
        guard let content = window.contentView else { return }
        root = content
        root.wantsLayer = true
        root.layer?.backgroundColor = ChromePalette.background.cgColor
        center = NSView(); sidebar = NSView(); tabsBar = NSView(); toolbar = NSView(); pages = NSView()
        [center, sidebar].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; root.addSubview($0) }
        [pages, tabsBar, toolbar].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; center.addSubview($0) }
        sidebar.wantsLayer = true
        sidebar.layer?.backgroundColor = NSColor.clear.cgColor
        // Native blur of what is behind the window, veiled by the stone-100 tint.
        let blur = NSVisualEffectView(); sidebarBlur = blur
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.material = .sidebar
        blur.blendingMode = .behindWindow
        blur.state = .followsWindowActiveState
        sidebar.addSubview(blur, positioned: .below, relativeTo: nil)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor), blur.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            blur.topAnchor.constraint(equalTo: sidebar.topAnchor), blur.bottomAnchor.constraint(equalTo: sidebar.bottomAnchor)
        ])
        sidebarTint = makeTint(in: sidebar, radius: 0)
        sidebarTint.layer?.borderWidth = 0
        sidebarTint.layer?.backgroundColor = ChromePalette.sidebarGlass.cgColor
        for name in [NSWindow.didEnterFullScreenNotification, NSWindow.didExitFullScreenNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(windowFullScreenChanged), name: name, object: window)
        }
        applySidebarBlur()
        let sideHeader = NSView(); sideHeader.translatesAutoresizingMaskIntoConstraints = false; sidebar.addSubview(sideHeader)
        let brand = NSImageView()
        brand.image = SVGPath.image(SVGPath.logo, viewBox: CGSize(width: 16, height: 24), size: NSSize(width: 12, height: 18), color: Palette.light.ink)
        brand.toolTip = "Quantum"
        brand.translatesAutoresizingMaskIntoConstraints = false; sideHeader.addSubview(brand)
        let collapse = button("sidebar", in: sideHeader) { [weak self] in self?.toggleSidebar() }
        let newTabButton = button("+", in: sideHeader) { [weak self] in self?.newTab() }
        sidebarRows = NSView(); sidebarRows.translatesAutoresizingMaskIntoConstraints = false; sidebar.addSubview(sidebarRows)
        NSLayoutConstraint.activate([
            sidebar.leadingAnchor.constraint(equalTo: root.leadingAnchor), sidebar.topAnchor.constraint(equalTo: root.topAnchor), sidebar.bottomAnchor.constraint(equalTo: root.bottomAnchor), sidebar.widthAnchor.constraint(equalToConstant: 244),
            center.trailingAnchor.constraint(equalTo: root.trailingAnchor), center.topAnchor.constraint(equalTo: root.topAnchor), center.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            sideHeader.topAnchor.constraint(equalTo: sidebar.topAnchor, constant: 8), sideHeader.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 12), sideHeader.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -12), sideHeader.heightAnchor.constraint(equalToConstant: 38),
            brand.leadingAnchor.constraint(equalTo: sideHeader.leadingAnchor, constant: 8), brand.centerYAnchor.constraint(equalTo: sideHeader.centerYAnchor), brand.widthAnchor.constraint(equalToConstant: 12), brand.heightAnchor.constraint(equalToConstant: 18),
            collapse.trailingAnchor.constraint(equalTo: newTabButton.leadingAnchor, constant: -2), collapse.centerYAnchor.constraint(equalTo: sideHeader.centerYAnchor), collapse.widthAnchor.constraint(equalToConstant: 34), collapse.heightAnchor.constraint(equalToConstant: 34),
            newTabButton.trailingAnchor.constraint(equalTo: sideHeader.trailingAnchor), newTabButton.centerYAnchor.constraint(equalTo: sideHeader.centerYAnchor), newTabButton.widthAnchor.constraint(equalToConstant: 34), newTabButton.heightAnchor.constraint(equalToConstant: 34),
            sidebarRows.topAnchor.constraint(equalTo: sideHeader.bottomAnchor, constant: 8), sidebarRows.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 8), sidebarRows.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -8), sidebarRows.bottomAnchor.constraint(equalTo: sidebar.bottomAnchor, constant: -12)
        ])
        centerLeadingSidebar = center.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor)
        centerLeadingRoot = center.leadingAnchor.constraint(equalTo: root.leadingAnchor)
        centerLeadingSidebar.isActive = true

        // Toolbar glass: adaptive material + explicit tint. Always light.
        let glass = NSVisualEffectView()
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.material = .popover
        glass.blendingMode = .withinWindow
        glass.state = .active
        glass.wantsLayer = true
        glass.layer?.cornerRadius = 15
        glass.layer?.masksToBounds = true
        toolbar.addSubview(glass, positioned: .below, relativeTo: nil)
        let glassTint = makeTint(in: glass, radius: 15)
        glassTint.layer?.backgroundColor = ChromePalette.glassTint.cgColor
        glassTint.layer?.borderColor = Palette.light.border.cgColor

        NSLayoutConstraint.activate([
            tabsBar.topAnchor.constraint(equalTo: center.topAnchor), tabsBar.leadingAnchor.constraint(equalTo: center.leadingAnchor), tabsBar.trailingAnchor.constraint(equalTo: center.trailingAnchor), tabsBar.heightAnchor.constraint(equalToConstant: 44),
            toolbar.leadingAnchor.constraint(equalTo: center.leadingAnchor, constant: 12), toolbar.trailingAnchor.constraint(equalTo: center.trailingAnchor, constant: -12), toolbar.heightAnchor.constraint(equalToConstant: 52),
            glass.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 2), glass.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: -2), glass.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor), glass.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            pages.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 4), pages.leadingAnchor.constraint(equalTo: center.leadingAnchor), pages.trailingAnchor.constraint(equalTo: center.trailingAnchor), pages.bottomAnchor.constraint(equalTo: center.bottomAnchor)
        ])
        toolbarTopTabs = toolbar.topAnchor.constraint(equalTo: tabsBar.bottomAnchor)
        toolbarTopCenter = toolbar.topAnchor.constraint(equalTo: center.topAnchor)
        toolbarTopTabs.isActive = true

        tabScroll = NSScrollView()
        tabScroll.translatesAutoresizingMaskIntoConstraints = false
        tabScroll.drawsBackground = false
        tabScroll.hasHorizontalScroller = true
        tabScroll.hasVerticalScroller = false
        tabScroll.autohidesScrollers = true
        tabDocument = NSView()
        tabScroll.documentView = tabDocument
        tabsBar.addSubview(tabScroll)
        let plus = button("+", in: tabsBar) { [weak self] in self?.newTab() }
        NSLayoutConstraint.activate([
            tabScroll.leadingAnchor.constraint(equalTo: tabsBar.leadingAnchor, constant: 12), tabScroll.topAnchor.constraint(equalTo: tabsBar.topAnchor), tabScroll.bottomAnchor.constraint(equalTo: tabsBar.bottomAnchor), tabScroll.trailingAnchor.constraint(equalTo: plus.leadingAnchor, constant: -4),
            plus.trailingAnchor.constraint(equalTo: tabsBar.trailingAnchor, constant: -12), plus.centerYAnchor.constraint(equalTo: tabsBar.centerYAnchor), plus.widthAnchor.constraint(equalToConstant: 34), plus.heightAnchor.constraint(equalToConstant: 36)
        ])

        sidebarToggle = button("sidebar", in: toolbar) { [weak self] in self?.toggleSidebar() }
        let back = button("back", in: toolbar) { [weak self] in self?.goBack() }
        let forward = button("forward", in: toolbar) { [weak self] in self?.goForward() }
        let reload = button("reload", in: toolbar) { [weak self] in self?.reload() }

        let well = NSVisualEffectView(); addressWell = well
        well.translatesAutoresizingMaskIntoConstraints = false
        well.material = .popover
        well.blendingMode = .withinWindow
        well.state = .active
        well.wantsLayer = true
        well.layer?.cornerRadius = 11
        well.layer?.masksToBounds = true
        toolbar.addSubview(well)
        let wellTint = makeTint(in: well, radius: 11)
        wellTint.layer?.borderWidth = 0
        wellTint.layer?.backgroundColor = ChromePalette.wellTint.cgColor

        address = NSTextField()
        address.translatesAutoresizingMaskIntoConstraints = false
        address.font = .systemFont(ofSize: 13)
        address.textColor = Palette.light.ink
        address.placeholderAttributedString = NSAttributedString(
            string: "Search or enter address",
            attributes: [.foregroundColor: Palette.light.secondaryInk, .font: NSFont.systemFont(ofSize: 13)]
        )
        address.isBordered = false
        address.isBezeled = false
        address.drawsBackground = false
        address.focusRingType = .none
        address.delegate = self
        // NOTE: isContinuous removed on purpose. On a text field it can fire the action on every keystroke.
        address.target = self
        address.action = #selector(go(_:))
        well.addSubview(address)

        loadingIndicator = NSProgressIndicator()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.style = .spinning
        loadingIndicator.controlSize = .small
        loadingIndicator.isDisplayedWhenStopped = false
        loadingIndicator.isHidden = true
        well.addSubview(loadingIndicator)

        bookmarkButton = button("bookmark", in: toolbar) { [weak self] in self?.toggleBookmark() }
        bookmarkButton.fillWhenActive = true
        let historyButton = button("history", in: toolbar) { [weak self] in self?.showHistory() }
        let settings = button("sliders", in: toolbar) { [weak self] in self?.showSettings() }
        NSLayoutConstraint.activate([
            sidebarToggle.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 6), sidebarToggle.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor), sidebarToggle.widthAnchor.constraint(equalToConstant: 34), sidebarToggle.heightAnchor.constraint(equalToConstant: 36),
            back.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor), back.widthAnchor.constraint(equalToConstant: 34), back.heightAnchor.constraint(equalToConstant: 36),
            forward.leadingAnchor.constraint(equalTo: back.trailingAnchor), forward.centerYAnchor.constraint(equalTo: back.centerYAnchor), forward.widthAnchor.constraint(equalTo: back.widthAnchor), forward.heightAnchor.constraint(equalTo: back.heightAnchor),
            reload.leadingAnchor.constraint(equalTo: forward.trailingAnchor), reload.centerYAnchor.constraint(equalTo: back.centerYAnchor), reload.widthAnchor.constraint(equalTo: back.widthAnchor), reload.heightAnchor.constraint(equalTo: back.heightAnchor),
            well.leadingAnchor.constraint(equalTo: reload.trailingAnchor, constant: 6), well.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -8), well.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor), well.heightAnchor.constraint(equalToConstant: 36),
            address.leadingAnchor.constraint(equalTo: well.leadingAnchor, constant: 12), address.trailingAnchor.constraint(equalTo: loadingIndicator.leadingAnchor, constant: -8), address.centerYAnchor.constraint(equalTo: well.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: well.trailingAnchor, constant: -10), loadingIndicator.centerYAnchor.constraint(equalTo: well.centerYAnchor), loadingIndicator.widthAnchor.constraint(equalToConstant: 14), loadingIndicator.heightAnchor.constraint(equalToConstant: 14),
            settings.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -4), settings.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor), settings.widthAnchor.constraint(equalToConstant: 34), settings.heightAnchor.constraint(equalToConstant: 36),
            historyButton.trailingAnchor.constraint(equalTo: settings.leadingAnchor), historyButton.centerYAnchor.constraint(equalTo: settings.centerYAnchor), historyButton.widthAnchor.constraint(equalToConstant: 34), historyButton.heightAnchor.constraint(equalToConstant: 36),
            bookmarkButton.trailingAnchor.constraint(equalTo: historyButton.leadingAnchor), bookmarkButton.centerYAnchor.constraint(equalTo: settings.centerYAnchor), bookmarkButton.widthAnchor.constraint(equalToConstant: 34), bookmarkButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Progress line: one flat neon purple, 1pt, sits above the pages (sibling, so no re-adding needed)
        progressTrack = NSView()
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.wantsLayer = true
        progressTrack.layer?.backgroundColor = ChromePalette.neon.cgColor
        progressTrack.isHidden = true
        center.addSubview(progressTrack, positioned: .above, relativeTo: pages)
        progressWidth = progressTrack.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressTrack.topAnchor.constraint(equalTo: pages.topAnchor),
            progressTrack.leadingAnchor.constraint(equalTo: pages.leadingAnchor),
            progressTrack.heightAnchor.constraint(equalToConstant: 1),
            progressWidth
        ])

        backLeadingSidebarToggle = back.leadingAnchor.constraint(equalTo: sidebarToggle.trailingAnchor)
        backLeadingToolbar = back.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 6)
        backLeadingSidebarToggle.isActive = true
        applyTabMode()
    }

    private func button(_ symbol: String, in parent: NSView, action: @escaping () -> Void) -> ChromeButton {
        let view = ChromeButton()
        view.symbol = symbol
        view.action = action
        view.translatesAutoresizingMaskIntoConstraints = false
        view.toolTip = ChromeButton.tooltips[symbol]
        parent.addSubview(view)
        return view
    }

    // MARK: Panels (dropdown cards)

    private func showPanel(_ title: String, rows: [PanelRow]) {
        hidePanel()
        let palette = cardPalette
        let card = NSVisualEffectView()
        card.material = .popover
        card.blendingMode = .withinWindow
        card.state = .active
        card.appearance = palette.appearance
        card.wantsLayer = true
        card.layer?.cornerRadius = 14
        card.layer?.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(card)
        overlayCard = card

        let tint = makeTint(in: card, radius: 14)
        tint.layer?.backgroundColor = palette.tint.cgColor
        tint.layer?.borderColor = palette.border.cgColor
        overlayTint = tint

        let heading = NSTextField(labelWithString: title)
        heading.font = .systemFont(ofSize: 12, weight: .medium)
        heading.textColor = palette.secondaryInk
        heading.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(heading)
        overlayHeading = heading

        let dismiss = button("×", in: card) { [weak self] in self?.hidePanel() }
        dismiss.palette = palette
        let placement: [NSLayoutConstraint]
        if title == "Suggestions" {
            placement = [card.leadingAnchor.constraint(equalTo: addressWell.leadingAnchor), card.widthAnchor.constraint(equalTo: addressWell.widthAnchor)]
        } else {
            placement = [card.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -18), card.widthAnchor.constraint(equalToConstant: 340)]
        }
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 7), card.heightAnchor.constraint(equalToConstant: CGFloat(52 + rows.count * 42)),
            heading.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16), heading.topAnchor.constraint(equalTo: card.topAnchor, constant: 14), heading.heightAnchor.constraint(equalToConstant: 18),
            dismiss.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8), dismiss.topAnchor.constraint(equalTo: card.topAnchor, constant: 7), dismiss.widthAnchor.constraint(equalToConstant: 30), dismiss.heightAnchor.constraint(equalToConstant: 30)
        ] + placement)
        for (index, row) in rows.enumerated() {
            let item = button(row.symbol, in: card) { [weak self] in self?.hidePanel(); row.action() }
            item.palette = palette
            item.title = row.title
            if title == "Suggestions" { item.trailing = "open" }
            if let url = row.url {
                // Real favicon if we have it; otherwise the fallback glyph until it lands (see storeFavicon)
                if let icon = favicon(for: url) { item.symbol = ""; item.image = icon }
                overlayRows.append((item, url))
            }
            NSLayoutConstraint.activate([
                item.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
                item.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
                item.topAnchor.constraint(equalTo: card.topAnchor, constant: CGFloat(42 + index * 42)),
                item.heightAnchor.constraint(equalToConstant: 38)
            ])
        }
    }

    private func hidePanel() {
        overlayCard?.removeFromSuperview()
        overlayCard = nil
        overlayTint = nil
        overlayHeading = nil
        overlayRows.removeAll()
    }

    /// Re-skins an already-open card when the site theme changes under it (theme sampling runs a few times per load).
    private func restyleCard() {
        guard let card = overlayCard else { return }
        let palette = cardPalette
        card.appearance = palette.appearance
        overlayTint?.layer?.backgroundColor = palette.tint.cgColor
        overlayTint?.layer?.borderColor = palette.border.cgColor
        overlayHeading?.textColor = palette.secondaryInk
        card.subviews.compactMap { $0 as? ChromeButton }.forEach { $0.palette = palette }
    }

    private func showSettings() {
        let standard = tabMode == "standard"
        showPanel("Tabs and sidebar", rows: [
            PanelRow(symbol: "tabs", title: "Standard Tabs\(standard ? "  ✓" : "")", action: { [weak self] in self?.setTabMode("standard") }),
            PanelRow(symbol: "sidebar", title: "Vertical Tabs\(standard ? "" : "  ✓")", action: { [weak self] in self?.setTabMode("vertical") }),
            PanelRow(symbol: "pin", title: "Show pinned", action: { [weak self] in self?.showBookmarks() }),
            PanelRow(symbol: "history", title: "Show history", action: { [weak self] in self?.showHistory() })
        ])
    }

    private func setTabMode(_ mode: String) {
        tabMode = mode
        UserDefaults.standard.set(mode, forKey: "tabMode")
        sidebarCollapsed = mode == "standard"
        applyTabMode()
        hidePanel()
    }

    private func toggleBookmark() {
        if let url = currentTab?.webView.url?.absoluteString, currentTab?.isHome == false {
            if bookmarks.contains(url) { bookmarks.removeAll { $0 == url } } else { bookmarks.insert(url, at: 0) }
            bookmarks = Array(bookmarks.prefix(100))
            UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
            bookmarkButton.active = bookmarks.contains(url)
            renderSidebar()
            if !sidebar.isHidden { return } // pinned list is already visible in the sidebar
        }
        showBookmarks()
    }

    private func removeBookmark(_ url: String) {
        bookmarks.removeAll { $0 == url }
        UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
        if let current = currentTab?.webView.url?.absoluteString { bookmarkButton.active = bookmarks.contains(current) }
        renderSidebar()
    }

    private func openPinned(_ url: String) {
        if let index = tabs.firstIndex(where: { $0.isHome == false && $0.webView.url?.absoluteString == url }) {
            selectTab(index)
        } else {
            navigate(url)
        }
    }

    private func showBookmarks() {
        if bookmarks.isEmpty {
            showPanel("Pinned", rows: [PanelRow(symbol: "pin", title: "Nothing pinned yet", action: { [weak self] in self?.hidePanel() })])
        } else {
            let rows: [PanelRow] = bookmarks.prefix(6).map { url in
                PanelRow(symbol: "pin", title: url, url: url, action: { [weak self] in self?.openPinned(url) })
            }
            showPanel("Pinned", rows: rows)
        }
    }

    private func showHistory() {
        if history.isEmpty {
            showPanel("Recent history", rows: [PanelRow(symbol: "history", title: "No history yet", action: { [weak self] in self?.hidePanel() })])
        } else {
            let rows: [PanelRow] = history.prefix(6).map { url in
                PanelRow(symbol: "globe", title: url, url: url, action: { [weak self] in self?.navigate(url) })
            }
            showPanel("Recent history", rows: rows)
        }
    }

    // MARK: Search suggestions (Google)

    private func showSearchSuggestions() {
        suggestWork?.cancel()
        suggestTask?.cancel()
        let query = typedQuery
        guard !query.isEmpty else { googleSuggestions = []; hidePanel(); return }
        // Keep earlier Google suggestions that still match what's typed, so the card doesn't jump while the next batch loads
        googleSuggestions = googleSuggestions.filter { $0.range(of: query, options: [.anchored, .caseInsensitive]) != nil }
        renderSuggestions(for: query)
        // Typed URLs and domains are never sent to Google
        guard !isURLLike(query) else { return }
        let work = DispatchWorkItem { [weak self] in self?.fetchGoogleSuggestions(for: query) }
        suggestWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }

    private func renderSuggestions(for query: String) {
        var seen = Set<String>()
        let matches = (bookmarks + history)
            .filter { $0.localizedCaseInsensitiveContains(query) && seen.insert($0).inserted }
            .prefix(3)
        var rows: [PanelRow] = matches.map { url in
            PanelRow(symbol: "globe", title: url, url: url, action: { [weak self] in self?.navigate(url) })
        }
        if isURLLike(query) {
            rows.append(PanelRow(symbol: "globe", title: "Go to “\(query)”", action: { [weak self] in self?.navigate(query) }))
        } else {
            rows.append(PanelRow(symbol: "search", title: "Search Google for “\(query)”", action: { [weak self] in self?.search(query) }))
            for suggestion in googleSuggestions.filter({ $0.caseInsensitiveCompare(query) != .orderedSame }).prefix(4) {
                rows.append(PanelRow(symbol: "search", title: suggestion, action: { [weak self] in self?.search(suggestion) }))
            }
        }
        showPanel("Suggestions", rows: rows)
    }

    /// Google's autocomplete endpoint (unofficial but long-stable). Response shape: ["query", ["suggestion", ...]]
    private func fetchGoogleSuggestions(for query: String) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: Quantum.queryAllowed),
              let url = URL(string: "https://suggestqueries.google.com/complete/search?client=firefox&q=" + encoded) else { return }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3)
        request.httpShouldHandleCookies = false
        let task = suggestSession.dataTask(with: request) { [weak self] data, _, _ in
            // Some locales come back Latin-1 instead of UTF-8, so fall back before parsing
            guard let data,
                  let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1),
                  let json = try? JSONSerialization.jsonObject(with: Data(text.utf8)) as? [Any],
                  json.count > 1, let list = json[1] as? [String] else { return }
            DispatchQueue.main.async {
                // Ignore late answers: the text changed, or the card was closed / replaced
                guard let self, self.typedQuery == query, self.overlayHeading?.stringValue == "Suggestions" else { return }
                self.googleSuggestions = list
                self.renderSuggestions(for: query)
            }
        }
        suggestTask = task
        task.resume()
    }

    // MARK: Theme (site darkness only drives the dropdown card; the chrome never changes)

    /// Samples what the page actually looks like (snapshot) instead of trusting CSS backgrounds.
    private func sampleTheme(of webView: WKWebView) {
        let size = webView.bounds.size
        guard size.width > 1, size.height > 1 else { return }
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: size.width, height: min(size.height, 320))
        config.snapshotWidth = 96
        webView.takeSnapshot(with: config) { [weak self, weak webView] image, _ in
            guard let self, let webView, webView === self.currentTab?.webView else { return }
            if let image, let dark = Quantum.isDark(image) {
                self.setSiteTheme(dark: dark)
            } else {
                self.sampleThemeViaScript(webView)
            }
        }
    }

    private static func isDark(_ image: NSImage) -> Bool? {
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil), cg.width > 0, cg.height > 0 else { return nil }
        let w = 48
        let h = max(1, min(64, Int((Double(cg.height) / Double(cg.width) * Double(w)).rounded())))
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let data = ctx.data else { return nil }
        ctx.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        ctx.interpolationQuality = .medium
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        let pixels = data.bindMemory(to: UInt8.self, capacity: w * h * 4)
        var darkCount = 0
        for index in 0..<(w * h) {
            let r = Double(pixels[index * 4])
            let g = Double(pixels[index * 4 + 1])
            let b = Double(pixels[index * 4 + 2])
            if (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255 < 0.4 { darkCount += 1 }
        }
        return Double(darkCount) / Double(w * h) > 0.5
    }

    private func sampleThemeViaScript(_ webView: WKWebView) {
        let script = """
        (() => {
          const clear = c => !c || c === 'transparent' || c.endsWith(', 0)');
          for (const el of [document.body, document.documentElement]) {
            if (!el) continue;
            const c = getComputedStyle(el).backgroundColor;
            if (!clear(c)) return c;
          }
          return 'rgb(255, 255, 255)';
        })()
        """
        webView.evaluateJavaScript(script) { [weak self, weak webView] value, _ in
            guard let self, let webView, webView === self.currentTab?.webView, let css = value as? String else { return }
            let parts = css.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).compactMap { Double($0) }
            var dark = false
            if parts.count >= 3 {
                dark = (0.2126 * parts[0] + 0.7152 * parts[1] + 0.0722 * parts[2]) / 255 < 0.42
            }
            DispatchQueue.main.async { self.setSiteTheme(dark: dark) }
        }
    }

    private func scheduleThemeCheck(for webView: WKWebView) {
        for delay in [0.12, 0.7, 1.8] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak webView] in
                guard let self, let webView, webView === self.currentTab?.webView, self.currentTab?.isHome == false else { return }
                self.sampleTheme(of: webView)
            }
        }
    }

    private func setSiteTheme(dark: Bool) {
        currentTab?.isDark = dark
        applyCardTheme(dark: dark)
    }

    private func applyCardTheme(dark: Bool) {
        guard dark != currentThemeIsDark else { return }
        currentThemeIsDark = dark
        restyleCard()
    }

    // MARK: Menus

    private func makeMenus() {
        let main = NSMenu()
        let appItem = NSMenuItem(title: "Quantum", action: nil, keyEquivalent: ""); let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit Quantum", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu; main.addItem(appItem)
        let fileItem = NSMenuItem(title: "File", action: nil, keyEquivalent: ""); let file = NSMenu()
        for (title, selector, key) in [("New Tab", #selector(newTabAction(_:)), "t"), ("Close Tab", #selector(closeTabAction(_:)), "w")] {
            let item = file.addItem(withTitle: title, action: selector, keyEquivalent: key); item.target = self
        }
        fileItem.submenu = file; main.addItem(fileItem)
        let editItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: ""); let edit = NSMenu()
        for (title, selector, key) in [("Undo", #selector(UndoManager.undo), "z"), ("Cut", #selector(NSText.cut(_:)), "x"), ("Copy", #selector(NSText.copy(_:)), "c"), ("Paste", #selector(NSText.paste(_:)), "v"), ("Select All", #selector(NSText.selectAll(_:)), "a")] {
            edit.addItem(withTitle: title, action: selector, keyEquivalent: key)
        }
        editItem.submenu = edit; main.addItem(editItem)
        let viewItem = NSMenuItem(title: "View", action: nil, keyEquivalent: ""); let view = NSMenu()
        for (title, selector, key) in [("Address", #selector(focusAddress(_:)), "l"), ("Reload", #selector(reloadAction(_:)), "r"), ("Back", #selector(backAction(_:)), "["), ("Forward", #selector(forwardAction(_:)), "]")] {
            let item = view.addItem(withTitle: title, action: selector, keyEquivalent: key); item.target = self
        }
        view.addItem(.separator())
        let sidebarItem = view.addItem(withTitle: "Show Sidebar", action: #selector(showSidebarAction(_:)), keyEquivalent: "b")
        sidebarItem.target = self
        for number in 1...9 {
            let item = view.addItem(withTitle: "Tab \(number)", action: #selector(jumpTab(_:)), keyEquivalent: "\(number)")
            item.target = self; item.tag = number - 1
        }
        viewItem.submenu = view; main.addItem(viewItem); NSApp.mainMenu = main
    }

    // MARK: Tabs

    private func addTab(configuration: WKWebViewConfiguration = WKWebViewConfiguration(), home: Bool = true) {
        if home { configuration.applicationNameForUserAgent = Quantum.userAgentSuffix }
        // WebKit renders every site natively; these only lift artificial limits that make heavy
        // JavaScript apps (window.open flows, fullscreen players, JS-gated content) degrade.
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let web = WKWebView(frame: .zero, configuration: configuration)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.translatesAutoresizingMaskIntoConstraints = false
        web.isHidden = true
        web.appearance = NSAppearance(named: .aqua) // pages don't flip just because the card did
        if #available(macOS 13.3, *) { web.isInspectable = true }
        pages.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: pages.topAnchor),
            web.leadingAnchor.constraint(equalTo: pages.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: pages.trailingAnchor),
            web.bottomAnchor.constraint(equalTo: pages.bottomAnchor)
        ])
        let tab = BrowserTab(web)
        tab.isHome = home

        // Spinner + progress line follow the web view's real loading state (single source of truth)
        tab.progressObservation = web.observe(\.estimatedProgress, options: [.new]) { [weak self, weak web] _, _ in
            DispatchQueue.main.async {
                guard let self, let web, web === self.currentTab?.webView else { return }
                self.syncLoadingUI()
            }
        }
        tab.loadingObservation = web.observe(\.isLoading, options: [.new]) { [weak self, weak web] _, _ in
            DispatchQueue.main.async {
                guard let self, let web, web === self.currentTab?.webView else { return }
                self.syncLoadingUI()
            }
        }

        tabs.append(tab)
        selectTab(tabs.count - 1)
        if home { loadHome(tab) }
        renderTabs()
    }

    private func renderTabs() {
        tabDocument.subviews.forEach { $0.removeFromSuperview() }
        let width: CGFloat = 174
        tabDocument.frame = NSRect(x: 0, y: 0, width: max(tabScroll.contentSize.width, CGFloat(tabs.count) * width), height: 44)
        for (index, tab) in tabs.enumerated() {
            let item = ChromeButton()
            item.active = index == currentIndex
            item.translatesAutoresizingMaskIntoConstraints = true
            item.frame = NSRect(x: CGFloat(index) * width, y: 4, width: width - 20, height: 36)
            item.toolTip = tab.title
            item.title = tab.title
            item.image = tab.favicon
            item.trailingInset = 32
            item.action = { [weak self] in self?.selectTab(index) }
            tabDocument.addSubview(item)
            let close = ChromeButton()
            close.symbol = "×"
            close.translatesAutoresizingMaskIntoConstraints = true
            close.frame = NSRect(x: CGFloat(index) * width + width - 48, y: 5, width: 28, height: 34)
            close.toolTip = "Close tab"
            close.action = { [weak self] in self?.closeTab(index) }
            tabDocument.addSubview(close)
        }
        tabScroll.contentView.scroll(to: NSPoint(x: max(0, CGFloat(currentIndex + 1) * width - tabScroll.contentSize.width), y: 0))
        tabScroll.reflectScrolledClipView(tabScroll.contentView)
        renderSidebar()
    }

    private func displayTitle(for rawURL: String) -> String {
        guard let host = URL(string: rawURL)?.host else { return rawURL }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private func renderSidebar() {
        guard sidebarRows != nil else { return }
        sidebarRows.subviews.forEach { $0.removeFromSuperview() }
        var offset: CGFloat = 0

        func section(_ title: String) {
            let label = NSTextField(labelWithString: title.uppercased())
            label.font = .systemFont(ofSize: 10, weight: .semibold)
            label.textColor = Palette.light.secondaryInk
            label.translatesAutoresizingMaskIntoConstraints = false
            sidebarRows.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: sidebarRows.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: sidebarRows.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: sidebarRows.topAnchor, constant: offset),
                label.heightAnchor.constraint(equalToConstant: 14)
            ])
            offset += 20
        }

        @discardableResult
        func row(_ symbol: String, _ title: String, selected: Bool = false, action: @escaping () -> Void) -> ChromeButton {
            let item = ChromeButton()
            item.symbol = symbol
            item.title = title
            item.active = selected
            item.translatesAutoresizingMaskIntoConstraints = false
            item.action = action
            sidebarRows.addSubview(item)
            NSLayoutConstraint.activate([
                item.leadingAnchor.constraint(equalTo: sidebarRows.leadingAnchor),
                item.trailingAnchor.constraint(equalTo: sidebarRows.trailingAnchor),
                item.topAnchor.constraint(equalTo: sidebarRows.topAnchor, constant: offset),
                item.heightAnchor.constraint(equalToConstant: 34)
            ])
            offset += 36
            return item
        }

        func addClose(to item: ChromeButton, _ action: @escaping () -> Void) {
            item.trailingInset = 34
            let close = ChromeButton()
            close.symbol = "×"
            close.translatesAutoresizingMaskIntoConstraints = false
            close.action = action
            sidebarRows.addSubview(close)
            NSLayoutConstraint.activate([
                close.trailingAnchor.constraint(equalTo: item.trailingAnchor, constant: -2),
                close.centerYAnchor.constraint(equalTo: item.centerYAnchor),
                close.widthAnchor.constraint(equalToConstant: 26),
                close.heightAnchor.constraint(equalToConstant: 28)
            ])
        }

        row("+", "New Tab") { [weak self] in self?.newTab() }
        row("pin", "Pinned") { [weak self] in self?.showBookmarks() }
        row("history", "History") { [weak self] in self?.showHistory() }

        if !bookmarks.isEmpty {
            offset += 8
            section("Pinned")
            let currentURL = currentTab?.webView.url?.absoluteString
            for url in bookmarks.prefix(12) {
                let selected = currentTab?.isHome == false && currentURL == url
                let item = row("pin", displayTitle(for: url), selected: selected) { [weak self] in self?.openPinned(url) }
                if let icon = favicon(for: url) { item.symbol = ""; item.image = icon }
                item.toolTip = url
                addClose(to: item) { [weak self] in self?.removeBookmark(url) }
            }
        }

        offset += 8
        section("Tabs")

        for (index, tab) in tabs.enumerated() {
            let item = ChromeButton()
            item.title = tab.title
            item.image = tab.favicon
            item.active = index == currentIndex
            item.translatesAutoresizingMaskIntoConstraints = false
            item.toolTip = tab.title
            item.action = { [weak self] in self?.selectTab(index) }
            sidebarRows.addSubview(item)
            NSLayoutConstraint.activate([
                item.leadingAnchor.constraint(equalTo: sidebarRows.leadingAnchor),
                item.trailingAnchor.constraint(equalTo: sidebarRows.trailingAnchor),
                item.topAnchor.constraint(equalTo: sidebarRows.topAnchor, constant: offset),
                item.heightAnchor.constraint(equalToConstant: 34)
            ])
            addClose(to: item) { [weak self] in self?.closeTab(index) }
            offset += 38
        }
    }

    private func applyTabMode() {
        let vertical = tabMode == "vertical"
        tabsBar.isHidden = vertical
        toolbarTopTabs.isActive = !vertical
        toolbarTopCenter.isActive = vertical
        let showToolbarSidebar = !vertical || sidebarCollapsed
        sidebarToggle.isHidden = !showToolbarSidebar
        backLeadingSidebarToggle.isActive = showToolbarSidebar
        backLeadingToolbar.isActive = !showToolbarSidebar
        sidebar.isHidden = !vertical || sidebarCollapsed
        window.minSize = NSSize(width: vertical && !sidebarCollapsed ? 700 : 460, height: 320)
        centerLeadingSidebar.isActive = vertical && !sidebarCollapsed
        centerLeadingRoot.isActive = !vertical || sidebarCollapsed
        root.layoutSubtreeIfNeeded()
    }

    /// A fullscreen window has nothing behind it, so the blur turns to a plain solid panel there.
    @objc private func windowFullScreenChanged() { applySidebarBlur() }

    private func applySidebarBlur() {
        let full = window?.styleMask.contains(.fullScreen) ?? false
        sidebarBlur?.isHidden = full
        sidebarTint?.layer?.backgroundColor = (full ? ChromePalette.sidebarBackground : ChromePalette.sidebarGlass).cgColor
    }

    private func toggleSidebar() {
        sidebarCollapsed.toggle()
        if tabMode != "vertical" { tabMode = "vertical" }
        applyTabMode()
    }

    private func openSidebar() {
        sidebarCollapsed = false
        tabMode = "vertical"
        UserDefaults.standard.set(tabMode, forKey: "tabMode")
        applyTabMode()
    }

    // MARK: Loading UI (spinner + line)

    private func setSpinner(_ on: Bool) {
        guard on != spinnerOn else { return }
        spinnerOn = on
        if on {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimation(nil)
        } else {
            loadingIndicator.stopAnimation(nil)
            loadingIndicator.isHidden = true
        }
    }

    private func showProgress(_ value: CGFloat) {
        if progressState != .loading {
            progressGeneration += 1
            progressState = .loading
            progressWidth.constant = 0
            progressTrack.alphaValue = 1
            progressTrack.isHidden = false
            watchProgress = 0
            armLoadWatchdog()
        } else if value >= watchProgress + 0.05 {
            // Still making progress, so the load is alive: push the stall watchdog out.
            watchProgress = value
            armLoadWatchdog()
        }
        let target = max(0.08, min(0.95, value)) * pages.bounds.width
        guard target > progressWidth.constant else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            self.progressWidth.animator().constant = target
        }
    }

    private func finishProgress() {
        guard progressState == .loading else { return }
        progressState = .finishing
        progressGeneration += 1
        let generation = progressGeneration
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.18
            self.progressWidth.animator().constant = self.pages.bounds.width
        }, completionHandler: { [weak self] in
            guard let self, self.progressGeneration == generation else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                self.progressTrack.animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                guard let self, self.progressGeneration == generation else { return }
                self.resetProgress()
            })
        })
    }

    private func resetProgress() {
        progressGeneration += 1
        progressState = .idle
        progressTrack.isHidden = true
        progressTrack.alphaValue = 1
        progressWidth.constant = 0
    }

    /// JS-heavy sites (SPAs, never-ending background fetches) can keep `isLoading` true or
    /// `estimatedProgress` below 1 long after the page is on screen, which used to leave the
    /// spinner and neon line running forever. The navigation callbacks end the UI directly and
    /// this watchdog ends it too if a load goes 12s without any progress at all.
    private func armLoadWatchdog() {
        loadWatchdog?.cancel()
        let generation = progressGeneration
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.progressGeneration == generation, self.progressState == .loading else { return }
            self.endLoadingUI()
        }
        loadWatchdog = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 12, execute: work)
    }

    private func endLoadingUI() {
        loadWatchdog?.cancel()
        loadWatchdog = nil
        setSpinner(false)
        if progressState == .loading { finishProgress() }
    }

    /// Reads the current tab's real state. Spinner is on only while a real (non-home) page is loading.
    private func syncLoadingUI() {
        guard let tab = currentTab, !tab.isHome else {
            endLoadingUI()
            resetProgress()
            return
        }
        let progress = tab.webView.estimatedProgress
        if tab.webView.isLoading && progress < 1 {
            setSpinner(true)
            showProgress(CGFloat(progress))
        } else {
            endLoadingUI()
        }
    }

    // MARK: Tab actions

    private func selectTab(_ index: Int) {
        guard tabs.indices.contains(index) else { return }
        currentTab?.webView.isHidden = true
        currentIndex = index
        guard let tab = currentTab else { return }
        tab.webView.isHidden = false
        address.stringValue = tab.isHome ? "" : (tab.webView.url?.absoluteString ?? "")
        bookmarkButton.active = tab.webView.url.map { bookmarks.contains($0.absoluteString) } ?? false
        window.title = "Quantum · \(tab.title)"
        resetProgress()
        applyCardTheme(dark: tab.isHome ? false : tab.isDark)
        if !tab.isHome { scheduleThemeCheck(for: tab.webView) }
        syncLoadingUI()
        renderTabs()
    }

    private func closeTab(_ index: Int) {
        guard tabs.indices.contains(index) else { return }
        let tab = tabs.remove(at: index)
        tab.progressObservation = nil
        tab.loadingObservation = nil
        tab.webView.stopLoading()
        tab.webView.navigationDelegate = nil
        tab.webView.uiDelegate = nil
        tab.webView.removeFromSuperview()
        if tabs.isEmpty { currentIndex = -1; addTab(); return }
        if index == currentIndex {
            currentIndex = -1
            selectTab(min(index, tabs.count - 1))
        } else {
            if index < currentIndex { currentIndex -= 1 }
            renderTabs()
        }
    }

    private func newTab() { hidePanel(); addTab(); window.makeFirstResponder(address); address.selectText(nil) }
    private func goBack() { if currentTab?.webView.canGoBack == true { currentTab?.webView.goBack() } }
    private func goForward() { if currentTab?.webView.canGoForward == true { currentTab?.webView.goForward() } }
    private func reload() {
        guard let tab = currentTab else { return }
        if tab.isHome { loadHome(tab) } else { tab.webView.reload() }
    }

    private func loadHome(_ tab: BrowserTab) {
        tab.isHome = true
        tab.title = "New Tab"
        tab.isDark = false
        if tab === currentTab {
            applyCardTheme(dark: false)
            syncLoadingUI()
        }
        let icon = Bundle.main.url(forResource: "icon", withExtension: "svg")
            .flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
        let html = """
        <!doctype html>
        <meta name='viewport' content='width=device-width,initial-scale=1'>
        <style>
        body{margin:0;min-height:100vh;display:grid;place-items:center;background:#fff;color:#78716c;font:13px -apple-system}
        main{transform:translateY(-7vh);text-align:center}
        svg{width:18px;height:27px}
        p{margin-top:20px}
        </style>
        <main>\(icon)<p>Search or enter an address above</p></main>
        """
        tab.webView.loadHTMLString(html, baseURL: nil)
        if tab === currentTab {
            address.stringValue = ""
            window.title = "Quantum"
            renderTabs()
        }
    }

    @objc private func go(_ sender: Any?) {
        let input = address.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        navigate(input)
    }

    private func isURLLike(_ input: String) -> Bool {
        input.hasPrefix("http://") || input.hasPrefix("https://") || (input.contains(".") && !input.contains(" "))
    }

    private func searchURL(for query: String) -> URL? {
        query.addingPercentEncoding(withAllowedCharacters: Quantum.queryAllowed)
            .flatMap { URL(string: "https://www.google.com/search?q=" + $0) }
    }

    /// Always a Google search, even if the text looks like a domain (used by the suggestion rows).
    private func search(_ query: String) {
        if let url = searchURL(for: query) { navigate(url.absoluteString) }
    }

    private func navigate(_ input: String) {
        var url: URL?
        if input.hasPrefix("http://") || input.hasPrefix("https://") {
            url = URL(string: input)
        } else if isURLLike(input) {
            url = URL(string: "https://" + input)
        } else {
            url = searchURL(for: input)
        }
        guard let target = url, let tab = currentTab else { return }
        suggestWork?.cancel()
        suggestTask?.cancel()
        googleSuggestions = []
        hidePanel()
        tab.isHome = false
        address.stringValue = target.absoluteString
        tab.webView.load(URLRequest(url: target))
        syncLoadingUI()
    }

    @objc private func newTabAction(_ sender: Any?) { newTab() }
    @objc private func closeTabAction(_ sender: Any?) { closeTab(currentIndex) }
    @objc private func reloadAction(_ sender: Any?) { reload() }
    @objc private func backAction(_ sender: Any?) { goBack() }
    @objc private func forwardAction(_ sender: Any?) { goForward() }
    @objc private func focusAddress(_ sender: Any?) { window.makeFirstResponder(address); address.selectText(nil) }
    @objc private func showSidebarAction(_ sender: Any?) { openSidebar() }
    @objc private func jumpTab(_ sender: NSMenuItem) { selectTab(sender.tag) }

    // MARK: Text field delegate

    func control(_ control: NSControl, textView: NSTextView, doCommandBy command: Selector) -> Bool {
        if command.description == "insertNewline:" { go(nil); return true }
        return false
    }

    func controlTextDidChange(_ notification: Notification) { showSearchSuggestions() }

    // MARK: Navigation delegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard webView === currentTab?.webView else { return }
        syncLoadingUI()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if webView === currentTab?.webView, currentTab?.isHome == false {
            address.stringValue = webView.url?.absoluteString ?? ""
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let tab = tabs.first(where: { $0.webView === webView }) else { return }
        // The document is done even when background requests keep the web view "loading".
        if webView === currentTab?.webView { DispatchQueue.main.async { [weak self] in self?.endLoadingUI() } }
        if tab.isHome { return }
        guard let url = webView.url, ["http", "https"].contains(url.scheme) else { return }

        if tab === currentTab { scheduleThemeCheck(for: webView) }
        tab.title = webView.title?.isEmpty == false ? webView.title! : (url.host ?? "Page")
        if tab === currentTab {
            address.stringValue = url.absoluteString
            window.title = "Quantum · \(tab.title)"
        }
        // Show this site's cached icon right away (or none) so a tab never keeps the previous site's icon
        tab.favicon = FaviconStore.key(for: url.absoluteString).flatMap { FaviconStore.image(for: $0) }
        fetchFavicon(for: tab, in: webView)
        if tab === currentTab { bookmarkButton.active = bookmarks.contains(url.absoluteString) }
        renderTabs()

        history.removeAll { $0 == url.absoluteString }
        history.insert(url.absoluteString, at: 0)
        var compact: [String] = []
        var budget = 900
        for item in history {
            let cost = item.utf8.count + 4
            guard cost <= budget else { continue }
            compact.append(item)
            budget -= cost
            if compact.count == 100 { break }
        }
        history = compact
        UserDefaults.standard.set(compact, forKey: "history")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard webView === currentTab?.webView else { return }
        DispatchQueue.main.async { [weak self] in self?.endLoadingUI() }
        if (error as NSError).code != NSURLErrorCancelled {
            window.title = "Quantum · Could not open page"
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard webView === currentTab?.webView else { return }
        DispatchQueue.main.async { [weak self] in self?.endLoadingUI() }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard webView === currentTab?.webView else { return }
        DispatchQueue.main.async { [weak self] in self?.endLoadingUI() }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        addTab(configuration: configuration, home: false)
        return currentTab?.webView
    }

    func webViewDidClose(_ webView: WKWebView) {
        if let index = tabs.firstIndex(where: { $0.webView === webView }) { closeTab(index) }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // MARK: Favicons

    /// Tab path: uses the icon the page itself declares (best quality), then stores it for every card.
    private func fetchFavicon(for tab: BrowserTab, in webView: WKWebView) {
        guard let pageURL = webView.url else { return }
        let script = #"document.querySelector('link[rel~="apple-touch-icon"]')?.href || document.querySelector('link[rel~="icon"]')?.href || ''"#
        webView.evaluateJavaScript(script) { [weak self, weak tab] result, _ in
            guard let self, let tab else { return }
            let declaredURL = (result as? String).flatMap(URL.init(string:))
            let defaults = [URL(string: "/apple-touch-icon.png", relativeTo: pageURL), URL(string: "/favicon.ico", relativeTo: pageURL)].compactMap { $0 }
            var candidates = [declaredURL].compactMap { $0 }
            for url in defaults where !candidates.contains(url) { candidates.append(url) }
            self.loadFavicon(from: candidates) { [weak self, weak tab] image in
                guard let self, let tab, self.tabs.contains(where: { $0 === tab }) else { return }
                tab.favicon = image
                self.storeFavicon(image, for: pageURL.absoluteString)
                self.renderTabs()
            }
        }
    }

    /// Card/sidebar path: cached icon for this URL's site, or nil and a background fetch from the site root.
    private func favicon(for rawURL: String) -> NSImage? {
        guard let key = FaviconStore.key(for: rawURL) else { return nil }
        if let image = FaviconStore.image(for: key) { return image }
        guard faviconRequests.insert(key).inserted, let url = URL(string: rawURL), let scheme = url.scheme, let host = url.host else { return nil }
        let candidates = ["/apple-touch-icon.png", "/favicon.ico"].compactMap { URL(string: "\(scheme)://\(host)\($0)") }
        loadFavicon(from: candidates) { [weak self] image in self?.storeFavicon(image, for: rawURL) }
        return nil
    }

    /// Saves the icon, then swaps it into any open card row and pinned sidebar row for that site.
    private func storeFavicon(_ image: NSImage, for rawURL: String) {
        guard let key = FaviconStore.key(for: rawURL) else { return }
        FaviconStore.save(image, for: key)
        for row in overlayRows where FaviconStore.key(for: row.url) == key {
            row.button.symbol = ""
            row.button.image = image
        }
        if bookmarks.contains(where: { FaviconStore.key(for: $0) == key }) { renderSidebar() }
    }

    private func loadFavicon(from candidates: [URL], completion: @escaping (NSImage) -> Void) {
        guard let url = candidates.first else { return }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 4)
        request.httpShouldHandleCookies = false
        faviconSession.dataTask(with: request) { [weak self] data, response, _ in
            guard let self else { return }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 200
            if status == 200, let data, let image = NSImage(data: data) {
                DispatchQueue.main.async { completion(image) }
            } else {
                self.loadFavicon(from: Array(candidates.dropFirst()), completion: completion)
            }
        }.resume()
    }
}