// Mollayoo app icon: the same "fish.fill" glyph used elsewhere in the app
// (sidebar button, snooze button, About screen), tinted blue, on a
// teal-to-navy water background.
// Earlier revisions (blue checkmark, "?!" bubble goldfish, chubby mochi-fish,
// hand-drawn silhouette) are kept in generate_icon_checkmark.swift / git
// history for reference.
import AppKit

let sizes: [(name: String, px: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

guard CommandLine.arguments.count > 1 else {
    fputs("usage: generate_icon.swift <output .iconset dir>\n", stderr)
    exit(1)
}
let outDir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
}

/// Renders `fish.fill` at high resolution and recolors it (template-image tint trick).
func tintedFish(size: NSSize, tint: NSColor) -> NSImage {
    let config = NSImage.SymbolConfiguration(pointSize: 1000, weight: .regular)
    guard let symbol = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else {
        fatalError("fish.fill symbol unavailable")
    }
    symbol.isTemplate = true

    let tinted = NSImage(size: size)
    tinted.lockFocus()
    tint.set()
    let rect = NSRect(origin: .zero, size: size)
    symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    rect.fill(using: .sourceAtop)
    tinted.unlockFocus()
    return tinted
}

func drawIcon(px: Int) -> NSBitmapImageRep {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext

    // Background squircle, vertical teal-to-navy gradient.
    let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: s * 0.22, cornerHeight: s * 0.22, transform: nil)
    cg.saveGState()
    cg.addPath(bgPath)
    cg.clip()
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: [color(0.078, 0.420, 0.522).cgColor, color(0.016, 0.165, 0.235).cgColor] as CFArray,
                                 locations: [0, 1])!
    cg.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: s), end: .zero, options: [])
    cg.restoreGState()

    // Fish glyph, centered, sized to fit within ~64% of the icon's width.
    let probe = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: nil)!
        .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 1000, weight: .regular))!
    let aspect = probe.size.height / probe.size.width
    let drawWidth = s * 0.64
    let drawSize = NSSize(width: drawWidth, height: drawWidth * aspect)
    let fish = tintedFish(size: drawSize, tint: color(0.788, 0.573, 0.169))

    let origin = CGPoint(x: (s - drawSize.width) / 2, y: (s - drawSize.height) / 2)
    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: -s * 0.02), blur: s * 0.03, color: color(0.008, 0.086, 0.125, 0.4).cgColor)
    fish.draw(in: CGRect(origin: origin, size: drawSize))
    cg.restoreGState()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

for (name, px) in sizes {
    let rep = drawIcon(px: px)
    guard let data = rep.representation(using: .png, properties: [:]) else { continue }
    let url = URL(fileURLWithPath: outDir).appendingPathComponent("\(name).png")
    try? data.write(to: url)
}

print("wrote \(sizes.count) icon sizes to \(outDir)")
