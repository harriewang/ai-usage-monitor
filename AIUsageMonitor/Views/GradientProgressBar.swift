import AppKit

/// 渐变色进度条（带动画）
class GradientProgressBar: NSView {

    var progress: CGFloat = 0 {
        didSet {
            progress = min(max(progress, 0), 1)
            needsDisplay = true
            startAnimationIfNeeded()
        }
    }

    private let barHeight: CGFloat = 14
    private let cornerRadius: CGFloat = 7
    private var shimmerTimer: Timer?
    private var shimmerOffset: CGFloat = 0
    private var displayProgress: CGFloat = 0

    override var isFlipped: Bool { false }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAnimation()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            startAnimationIfNeeded()
        } else {
            stopAnimation()
        }
    }

    private func startAnimationIfNeeded() {
        guard window != nil, shimmerTimer == nil, progress > 0 else { return }
        shimmerTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.shimmerOffset += 0.02
            if self.shimmerOffset > 1.0 {
                self.shimmerOffset -= 1.0
            }
            self.needsDisplay = true
        }
    }

    private func stopAnimation() {
        shimmerTimer?.invalidate()
        shimmerTimer = nil
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let barRect = NSRect(x: 0, y: (bounds.height - barHeight) / 2, width: bounds.width, height: barHeight)
        let barPath = NSBezierPath(roundedRect: barRect, xRadius: cornerRadius, yRadius: cornerRadius)

        // 背景轨道
        NSColor(white: 0.18, alpha: 1.0).setFill()
        barPath.fill()

        // 渐变填充
        guard progress > 0 else { return }
        let fillWidth = barRect.width * progress
        let fillRect = NSRect(x: barRect.origin.x, y: barRect.origin.y, width: fillWidth, height: barRect.height)
        let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: cornerRadius, yRadius: cornerRadius)

        // 根据进度选择渐变配色：低用量=绿黄，高用量=橙红
        let percent = progress * 100
        let gradientColors: [NSColor]
        if percent >= 90 {
            gradientColors = [.progressGreen, .progressYellow, .progressOrange, .progressRed]
        } else if percent >= 70 {
            gradientColors = [.progressGreen, .progressYellow, .progressOrange]
        } else if percent >= 50 {
            gradientColors = [.progressGreen, .progressYellow]
        } else {
            gradientColors = [.progressGreen, .progressCyan]
        }

        let mainGradient = NSGradient(colors: gradientColors)
        mainGradient?.draw(in: fillPath, angle: 0)

        // 光泽叠加层
        let shimmerX = shimmerOffset * barRect.width * 1.5 - barRect.width * 0.25
        let shimmerRect = NSRect(x: shimmerX, y: barRect.origin.y, width: barRect.width * 0.3, height: barRect.height)
        let shimmerClip = NSBezierPath(rect: fillRect)
        NSGraphicsContext.saveGraphicsState()
        shimmerClip.setClip()

        let shimmerGradient = NSGradient(colors: [
            NSColor(white: 1.0, alpha: 0.0),
            NSColor(white: 1.0, alpha: 0.08),
            NSColor(white: 1.0, alpha: 0.0)
        ])
        shimmerGradient?.draw(in: shimmerRect, angle: 0)
        NSGraphicsContext.restoreGraphicsState()

        // 顶部高光线
        let highlightRect = NSRect(x: fillRect.origin.x + 2, y: barRect.maxY - 3, width: fillRect.width - 4, height: 1.5)
        let highlightPath = NSBezierPath(roundedRect: highlightRect, xRadius: 1, yRadius: 1)
        NSColor(white: 1.0, alpha: 0.2).setFill()
        highlightPath.fill()
    }
}
