import AppKit

/// 状态行：✓ API Key 已设置 | ✓ 已连接
class StatusRowView: NSView {

    static let height: CGFloat = 32
    static let menuWidth: CGFloat = 320

    private let keyIcon = NSTextField(labelWithString: "")
    private let keyStatus = NSTextField(labelWithString: "")
    private let connectionIcon = NSTextField(labelWithString: "")
    private let connectionStatus = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(hasKey: Bool, isConnected: Bool) {
        // API Key 状态
        keyIcon.stringValue = hasKey ? "●" : "○"
        keyIcon.textColor = hasKey ? .statusOK : .statusError
        keyStatus.stringValue = hasKey ? "API Key 已设置" : "未设置 API Key"
        keyStatus.textColor = hasKey ? .textSecondary : .statusError

        // 连接状态
        connectionIcon.stringValue = isConnected ? "●" : "○"
        connectionIcon.textColor = isConnected ? .statusOK : .textTertiary
        connectionStatus.stringValue = isConnected ? "已连接" : "未连接"
        connectionStatus.textColor = isConnected ? .textSecondary : .textTertiary
    }

    private func setupViews() {
        // 左侧：API Key 状态
        keyIcon.font = .systemFont(ofSize: 8)
        keyIcon.frame = NSRect(x: 16, y: 10, width: 10, height: 12)

        keyStatus.font = .systemFont(ofSize: 11, weight: .medium)
        keyStatus.frame = NSRect(x: 28, y: 8, width: 130, height: 16)

        // 右侧：连接状态
        connectionIcon.font = .systemFont(ofSize: 8)
        connectionIcon.frame = NSRect(x: 176, y: 10, width: 10, height: 12)

        connectionStatus.font = .systemFont(ofSize: 11, weight: .medium)
        connectionStatus.frame = NSRect(x: 188, y: 8, width: 116, height: 16)

        addSubview(keyIcon)
        addSubview(keyStatus)
        addSubview(connectionIcon)
        addSubview(connectionStatus)
    }
}
