import AppKit

/// 单个平台的用量卡片
class PlatformCardView: NSView {

    static let height: CGFloat = 96
    static let menuWidth: CGFloat = 400

    private let iconView = NSImageView()
    private let nameLabel = NSTextField(labelWithString: "")
    private let statusDot = NSTextField(labelWithString: "")
    private let progressBar = GradientProgressBar()
    private let usedLabel = NSTextField(labelWithString: "")     // 已用 x/total
    private let percentLabel = NSTextField(labelWithString: "")  // 百分比
    private let cycleLabel = NSTextField(labelWithString: "")    // 更新周期
    private let timeRangeLabel = NSTextField(labelWithString: "") // 时间范围
    private let remainingLabel = NSTextField(labelWithString: "") // 剩余时间
    private let spinner = NSProgressIndicator()

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(provider: APIProvider, data: UsageData?, isLoading: Bool, error: String?, hasKey: Bool) {
        // 左侧图标
        let name = provider.iconImageName ?? provider.rawValue
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let img = NSImage(contentsOfFile: path) {
            iconView.image = img
        }
        nameLabel.stringValue = provider.localizedName

        if !hasKey {
            statusDot.stringValue = "○"
            statusDot.textColor = .textTertiary
            usedLabel.stringValue = NSLocalizedString("menu.noKey", comment: "")
            usedLabel.textColor = .textTertiary
            percentLabel.stringValue = ""
            progressBar.progress = 0
            cycleLabel.stringValue = ""
            timeRangeLabel.stringValue = ""
            remainingLabel.stringValue = ""
            stopSpinner()
        } else if isLoading {
            statusDot.stringValue = "●"
            statusDot.textColor = .progressYellow
            usedLabel.stringValue = NSLocalizedString("menu.loading", comment: "")
            usedLabel.textColor = .textSecondary
            percentLabel.stringValue = ""
            progressBar.progress = 0
            cycleLabel.stringValue = ""
            timeRangeLabel.stringValue = ""
            remainingLabel.stringValue = ""
            startSpinner()
        } else if let error = error {
            statusDot.stringValue = "●"
            statusDot.textColor = .statusError
            usedLabel.stringValue = error
            usedLabel.textColor = .statusError
            percentLabel.stringValue = ""
            progressBar.progress = 0
            cycleLabel.stringValue = ""
            timeRangeLabel.stringValue = ""
            remainingLabel.stringValue = ""
            stopSpinner()
        } else if let data = data {
            statusDot.stringValue = "●"
            statusDot.textColor = .statusOK

            // 合并显示：72/600 8%已使用
            let usedText = data.extraInfo ?? data.balanceText
            let percentText = data.usagePercent != nil ? String(format: "%.1f%%", data.usagePercent!) : ""
            usedLabel.stringValue = "\(usedText) \(percentText)"
            usedLabel.textColor = .textPrimary
            percentLabel.stringValue = ""

            if let percent = data.usagePercent {
                progressBar.progress = CGFloat(percent / 100.0)
            } else {
                progressBar.progress = 0
            }

            // 时间信息
            cycleLabel.stringValue = data.cycleInfo
            timeRangeLabel.stringValue = data.timeRange
            remainingLabel.stringValue = data.remainingTime
            stopSpinner()
        } else {
            statusDot.stringValue = "○"
            statusDot.textColor = .textTertiary
            usedLabel.stringValue = "--"
            usedLabel.textColor = .textTertiary
            percentLabel.stringValue = ""
            progressBar.progress = 0
            cycleLabel.stringValue = ""
            timeRangeLabel.stringValue = ""
            remainingLabel.stringValue = ""
            stopSpinner()
        }
    }

    private func startSpinner() {
        spinner.isHidden = false
        spinner.startAnimation(nil)
    }

    private func stopSpinner() {
        spinner.isHidden = true
        spinner.stopAnimation(nil)
    }

    private func setupViews() {
        // 左侧图标（垂直居中，y=36，22x22）
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 11
        iconView.layer?.masksToBounds = true
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.frame = NSRect(x: 12, y: 36, width: 22, height: 22)
        addSubview(iconView)

        // 平台名 + 状态点（y=58）
        nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = .textPrimary
        nameLabel.frame = NSRect(x: 42, y: 58, width: 100, height: 16)
        addSubview(nameLabel)

        statusDot.font = .systemFont(ofSize: 8)
        statusDot.frame = NSRect(x: 142, y: 60, width: 10, height: 12)
        addSubview(statusDot)

        // 重置时间（y=58，右对齐）
        remainingLabel.font = .systemFont(ofSize: 10)
        remainingLabel.textColor = .textTertiary
        remainingLabel.alignment = .right
        remainingLabel.frame = NSRect(x: 250, y: 60, width: 138, height: 12)
        addSubview(remainingLabel)

        // 进度条（y=36，宽=346）
        progressBar.frame = NSRect(x: 42, y: 36, width: 346, height: 14)
        addSubview(progressBar)

        // 已用/总量（y=6，左对齐）
        usedLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        usedLabel.textColor = .textSecondary
        usedLabel.alignment = .left
        usedLabel.drawsBackground = false
        usedLabel.frame = NSRect(x: 42, y: 6, width: 220, height: 14)
        addSubview(usedLabel)

        // 百分比（y=6，左对齐）
        percentLabel.font = .systemFont(ofSize: 11, weight: .bold)
        percentLabel.alignment = .left
        percentLabel.drawsBackground = false
        percentLabel.frame = NSRect(x: 262, y: 6, width: 50, height: 14)
        addSubview(percentLabel)

        // 时间范围（y=6，右对齐）
        timeRangeLabel.font = .systemFont(ofSize: 10)
        timeRangeLabel.textColor = .textTertiary
        timeRangeLabel.alignment = .right
        timeRangeLabel.frame = NSRect(x: 250, y: 6, width: 138, height: 12)
        addSubview(timeRangeLabel)

        // 加载动画
        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.frame = NSRect(x: 290, y: 40, width: 14, height: 14)
        spinner.isHidden = true
        addSubview(spinner)
    }
}
