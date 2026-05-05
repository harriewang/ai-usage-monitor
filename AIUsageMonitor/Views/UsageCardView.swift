import AppKit

/// 用量卡片：圆角背景 + 标题 + 百分比 + 进度条
class UsageCardView: NSView {

    static let height: CGFloat = 100
    static let menuWidth: CGFloat = 320

    private let titleLabel = NSTextField(labelWithString: "")
    private let percentLabel = NSTextField(labelWithString: "")
    private let progressBar = GradientProgressBar()
    private let loadingSpinner = NSProgressIndicator()
    private let loadingLabel = NSTextField(labelWithString: NSLocalizedString("card.loading", comment: ""))

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        wantsLayer = true
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(usagePercent: Double?, isLoading: Bool, error: String?) {
        if isLoading {
            showLoading()
            return
        }

        hideLoading()

        if let error = error {
            showError(error)
            return
        }

        showData(usagePercent: usagePercent)
    }

    private func showLoading() {
        loadingSpinner.isHidden = false
        loadingSpinner.startAnimation(nil)
        loadingLabel.isHidden = false
        titleLabel.isHidden = true
        percentLabel.isHidden = true
        progressBar.isHidden = true
    }

    private func hideLoading() {
        loadingSpinner.isHidden = true
        loadingSpinner.stopAnimation(nil)
        loadingLabel.isHidden = true
        titleLabel.isHidden = false
        percentLabel.isHidden = false
        progressBar.isHidden = false
    }

    private func showError(_ error: String) {
        titleLabel.stringValue = NSLocalizedString("card.fetchFailed", comment: "")
        percentLabel.stringValue = error
        percentLabel.textColor = .statusError
        percentLabel.font = .systemFont(ofSize: 12)
        progressBar.progress = 0
    }

    private func showData(usagePercent: Double?) {
        titleLabel.stringValue = NSLocalizedString("card.usage5h", comment: "")
        percentLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        let percent = usagePercent ?? 0
        percentLabel.stringValue = String(format: "%.1f%%", percent)

        // 根据用量百分比变色
        if percent > 80 {
            percentLabel.textColor = .statusError
        } else if percent > 50 {
            percentLabel.textColor = .progressYellow
        } else {
            percentLabel.textColor = .textPrimary
        }

        progressBar.progress = CGFloat(percent / 100.0)
    }

    private func setupViews() {
        // 圆角卡片背景
        layer?.cornerRadius = 12
        layer?.backgroundColor = NSColor.cardBackground.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor(white: 0.3, alpha: 0.4).cgColor

        // "5小时内用量" 标题
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .textSecondary
        titleLabel.frame = NSRect(x: 16, y: 72, width: 200, height: 16)

        // 百分比
        percentLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        percentLabel.textColor = .textPrimary
        percentLabel.alignment = .right
        percentLabel.frame = NSRect(x: 200, y: 70, width: 104, height: 20)

        // 进度条
        progressBar.frame = NSRect(x: 16, y: 40, width: 288, height: 20)

        // 加载动画
        loadingSpinner.style = .spinning
        loadingSpinner.controlSize = .small
        loadingSpinner.frame = NSRect(x: 140, y: 52, width: 16, height: 16)
        loadingSpinner.isHidden = true

        loadingLabel.font = .systemFont(ofSize: 12, weight: .medium)
        loadingLabel.textColor = .textSecondary
        loadingLabel.alignment = .center
        loadingLabel.frame = NSRect(x: 0, y: 32, width: Self.menuWidth, height: 16)
        loadingLabel.isHidden = true

        addSubview(titleLabel)
        addSubview(percentLabel)
        addSubview(progressBar)
        addSubview(loadingSpinner)
        addSubview(loadingLabel)
    }
}
