import AppKit

/// 底部操作按钮行：刷新余额 / 打开设置 / 退出
class ActionButtonsView: NSView {

    static let height: CGFloat = 48
    static let menuWidth: CGFloat = 320

    var onRefresh: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    var onQuit: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let buttonWidth: CGFloat = 90
        let spacing: CGFloat = 10
        let totalWidth = buttonWidth * 3 + spacing * 2
        let startX = (Self.menuWidth - totalWidth) / 2

        // 刷新余额
        let refreshBtn = makeStyledButton(
            title: "刷新余额",
            color: .themeAccent,
            frame: NSRect(x: startX, y: 10, width: buttonWidth, height: 28)
        )
        refreshBtn.target = self
        refreshBtn.action = #selector(refreshTapped)

        // 打开设置
        let settingsBtn = makeStyledButton(
            title: "打开设置",
            color: .textSecondary,
            frame: NSRect(x: startX + buttonWidth + spacing, y: 10, width: buttonWidth, height: 28)
        )
        settingsBtn.target = self
        settingsBtn.action = #selector(settingsTapped)

        // 退出
        let quitBtn = makeStyledButton(
            title: "退出",
            color: .statusError,
            frame: NSRect(x: startX + (buttonWidth + spacing) * 2, y: 10, width: buttonWidth, height: 28)
        )
        quitBtn.target = self
        quitBtn.action = #selector(quitTapped)

        addSubview(refreshBtn)
        addSubview(settingsBtn)
        addSubview(quitBtn)
    }

    private func makeStyledButton(title: String, color: NSColor, frame: NSRect) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.frame = frame
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 12, weight: .medium)
        button.isBordered = false
        button.contentTintColor = color
        // 添加鼠标悬停效果
        button.addTrackingRect(frame, owner: button, userData: nil, assumeInside: false)
        return button
    }

    @objc private func refreshTapped() { onRefresh?() }
    @objc private func settingsTapped() { onOpenSettings?() }
    @objc private func quitTapped() { onQuit?() }
}
