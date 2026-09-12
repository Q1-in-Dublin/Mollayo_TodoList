// Molayo app icon: sleek goldfish silhouette ("B · Deep Water Gold" from the
// design canvas) - teal-to-navy water background, blue gradient fish (color
// matched to the approved reference image), soft highlight sheen, drop
// shadow. No eye/mouth/bubble.
// The context is flipped once so path coordinates below match the source
// SVG's viewBox (0 0 200 200) numbers exactly.
// Earlier revisions (blue checkmark, "?!" bubble goldfish, chubby mochi-fish)
// are kept in generate_icon_checkmark.swift / git history for reference.
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

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    NSColor(calibratedRed: r, green: g, blue: b, alpha: a).cgColor
}

func drawIcon(px: Int) -> NSBitmapImageRep {
    let s = CGFloat(px)
    let scale = s / 200.0
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext

    // Flip so (0,0) is top-left and y grows downward, matching the source SVG's
    // viewBox exactly — every coordinate below is the SVG number times `scale`.
    cg.translateBy(x: 0, y: s)
    cg.scaleBy(x: 1, y: -1)

    func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }

    // Background squircle, vertical teal-to-navy gradient.
    let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: 44 * scale, cornerHeight: 44 * scale, transform: nil)
    cg.saveGState()
    cg.addPath(bgPath)
    cg.clip()
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: [color(0.078, 0.420, 0.522), color(0.016, 0.165, 0.235)] as CFArray,
                                 locations: [0, 1])!
    cg.drawLinearGradient(bgGradient, start: pt(0, 0), end: pt(0, 200), options: [])
    cg.restoreGState()

    // Fish silhouette: nose -> back -> tail spike -> notch -> tail spike -> belly -> nose.
    let fish = CGMutablePath()
    fish.move(to: pt(178, 102))
    fish.addCurve(to: pt(75, 58), control1: pt(165, 60), control2: pt(110, 50))
    fish.addCurve(to: pt(15, 50), control1: pt(55, 45), control2: pt(25, 35))
    fish.addLine(to: pt(45, 102))
    fish.addLine(to: pt(15, 155))
    fish.addCurve(to: pt(78, 148), control1: pt(25, 168), control2: pt(55, 158))
    fish.addCurve(to: pt(178, 102), control1: pt(115, 155), control2: pt(160, 145))
    fish.closeSubpath()

    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: -6 * scale), blur: 6 * scale, color: color(0.008, 0.086, 0.125, 0.45))
    cg.addPath(fish)
    cg.clip()
    let fishGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                   colors: [color(0.298, 0.592, 1.0), color(0.043, 0.341, 0.839)] as CFArray,
                                   locations: [0, 1])!
    cg.drawLinearGradient(fishGradient, start: pt(15, 35), end: pt(178, 168), options: [])
    cg.restoreGState()

    // Soft highlight sheen, clipped to the fish only.
    cg.saveGState()
    cg.addPath(fish)
    cg.clip()
    cg.setBlendMode(.softLight)
    let sheenGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [color(1, 1, 1, 0.6), color(1, 1, 1, 0)] as CFArray,
                                    locations: [0, 1])!
    cg.drawLinearGradient(sheenGradient, start: pt(35, 30), end: pt(115, 120), options: [])
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
