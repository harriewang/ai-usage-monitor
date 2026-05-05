import AppKit

/// 应用图标生成器
enum AppIcon {

    /// 菜单栏图标（18x18 单色）
    static func menuBarIcon() -> NSImage {
        if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
           let image = NSImage(contentsOfFile: path) {
            return image
        }
        // 备用：生成默认图标
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        let rect = NSRect(origin: .zero, size: size)

        // 背景圆
        let bgPath = NSBezierPath(ovalIn: rect.insetBy(dx: 1, dy: 1))
        NSColor.themeAccent.setFill()
        bgPath.fill()

        // AI 文字
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9, weight: .heavy),
            .foregroundColor: NSColor.white
        ]
        let text = "AI"
        let textSize = text.size(withAttributes: attrs)
        let textPoint = NSPoint(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2
        )
        text.draw(at: textPoint, withAttributes: attrs)

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    /// 应用图标（128x128，用于 Finder/Dock）
    static func appIcon() -> NSImage {
        let size = NSSize(width: 128, height: 128)
        let image = NSImage(size: size)
        image.lockFocus()

        let rect = NSRect(origin: .zero, size: size)

        // 圆角矩形背景
        let bgPath = NSBezierPath(roundedRect: rect, xRadius: 24, yRadius: 24)
        let gradient = NSGradient(colors: [
            NSColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1.0),
            NSColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0)
        ])
        gradient?.draw(in: bgPath, angle: 135)

        // 内部圆形仪表盘
        let gaugeRect = rect.insetBy(dx: 20, dy: 24)
        let gaugePath = NSBezierPath(ovalIn: gaugeRect)
        NSColor(white: 1.0, alpha: 0.15).setFill()
        gaugePath.fill()

        // 弧形进度
        let center = NSPoint(x: gaugeRect.midX, y: gaugeRect.midY)
        let radius = gaugeRect.width / 2 - 4
        let arcPath = NSBezierPath()
        arcPath.lineWidth = 6
        arcPath.lineCapStyle = .round
        let startAngle: CGFloat = 135
        let endAngle: CGFloat = 135 + 270 * 0.65 // 65% 进度
        arcPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle)
        NSColor.white.setStroke()
        arcPath.stroke()

        // AI 文字
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 28, weight: .heavy),
            .foregroundColor: NSColor.white
        ]
        let text = "AI"
        let textSize = text.size(withAttributes: attrs)
        let textPoint = NSPoint(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2 - 4
        )
        text.draw(at: textPoint, withAttributes: attrs)

        image.unlockFocus()
        return image
    }
}
