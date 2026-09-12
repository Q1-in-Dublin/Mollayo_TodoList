// Backup of the original (blue checkmark) app icon generator — kept for reference / rollback.
// Not used by build.sh anymore; see generate_icon.swift for the active (goldfish) icon.
import AppKit

let sizes: [(name: String, px: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

guard CommandLine.arguments.count > 1 else {
    fputs("usage: generate_icon_checkmark.swift <output .iconset dir>\n", stderr)
    exit(1)
}
let outDir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func drawIcon(px: Int) -> NSBitmapImageRep {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext

    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let cornerRadius = s * 0.2237
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    cg.saveGState()
    cg.addPath(path)
    cg.clip()
    let colors = [
        NSColor(calibratedRed: 0.04, green: 0.52, blue: 1.0, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.0, green: 0.44, blue: 0.98, alpha: 1).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
    cg.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])
    cg.restoreGState()

    let scale = s / 512.0
    let check = CGMutablePath()
    check.move(to: CGPoint(x: 140 * scale, y: 245 * scale))
    check.addLine(to: CGPoint(x: 222 * scale, y: 160 * scale))
    check.addLine(to: CGPoint(x: 392 * scale, y: 372 * scale))

    cg.setStrokeColor(NSColor.white.cgColor)
    cg.setLineWidth(58 * scale)
    cg.setLineCap(.round)
    cg.setLineJoin(.round)
    cg.addPath(check)
    cg.strokePath()

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
