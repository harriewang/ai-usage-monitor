import AppKit

/// 菜单标题行：平台名 + 当前余额
class TitleMenuItemView: NSView {

    static let height: CGFloat = 52
    static let menuWidth: CGFloat = 320

    private let iconView = NSTextField(labelWithString: "")
    private let titleLabel = NSTextField(labelWithString: "")
    private let balanceLabel = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(provider: APIProvider, balance: String?) {
        iconView.stringValue = provider.icon
        titleLabel.stringValue = "监控 AI 5小时余量"
        balanceLabel.stringValue = balance ?? "--"
    }

    private func setupViews() {
        // 平台图标圆
        iconView.wantsLayer = true
        iconView.layer?.cornerRadius = 14
        iconView.layer?.backgroundColor = NSColor.themeAccent.cgColor
        iconView.font = .systemFont(ofSize: 14, weight: .heavy)
        iconView.textColor = .white
        iconView.alignment = .center
        iconView.cell?.alignment = .center
        iconView.frame = NSRect(x: 16, y: 16, width: 28, height: 28)

        // 标题
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .textTertiary
        titleLabel.frame = NSRect(x: 52, y: 30, width: 200, height: 14)

        // 余额
        balanceLabel.font = .systemFont(ofSize: 24, weight: .bold)
        balanceLabel.textColor = .textPrimary
        balanceLabel.frame = NSRect(x: 52, y: 4, width: 252, height: 28)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(balanceLabel)
    }
}
