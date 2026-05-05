import AppKit

extension NSColor {
    /// 主题色（蓝色系）
    static let themeAccent = NSColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1.0)
    static let themeAccentLight = NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    static let themeAccentDark = NSColor(red: 0.15, green: 0.4, blue: 0.85, alpha: 1.0)

    /// 渐变进度条色（彩虹渐变）
    static let progressCyan = NSColor(red: 0.0, green: 0.85, blue: 0.95, alpha: 1.0)
    static let progressBlue = NSColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)
    static let progressGreen = NSColor(red: 0.2, green: 0.85, blue: 0.5, alpha: 1.0)
    static let progressYellow = NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    static let progressOrange = NSColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0)
    static let progressRed = NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)

    /// 文字色（自适应深色/浅色模式）
    static let textPrimary = NSColor.labelColor
    static let textSecondary = NSColor.secondaryLabelColor
    static let textTertiary = NSColor.tertiaryLabelColor

    /// 状态色
    static let statusOK = NSColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
    static let statusWarning = NSColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0)
    static let statusError = NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)

    /// 背景色
    static let cardBackground = NSColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1.0)
    static let cardBorder = NSColor(white: 0.3, alpha: 0.4)
    static let menuBackground = NSColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1.0)

    /// 分隔线
    static let separator = NSColor(white: 0.3, alpha: 0.5)
}
