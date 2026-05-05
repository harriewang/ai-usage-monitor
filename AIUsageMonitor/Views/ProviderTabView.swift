import AppKit

/// 平台切换 Tab 视图
class ProviderTabView: NSView {

    static let height: CGFloat = 48
    static let menuWidth: CGFloat = 320

    var onTabSelected: ((APIProvider) -> Void)?

    private var buttons: [NSButton] = []
    private var bgViews: [NSView] = []
    private let underline = NSView()

    private(set) var selectedProvider: APIProvider = .minimax

    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: Self.menuWidth, height: Self.height))
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(selected: APIProvider) {
        self.selectedProvider = selected
        updateSelection(animated: false)
    }

    private func setupViews() {
        let providers = APIProvider.allCases
        let buttonWidth = Self.menuWidth / CGFloat(providers.count)
        let padding: CGFloat = 4

        for (index, provider) in providers.enumerated() {
            let x = CGFloat(index) * buttonWidth + padding
            let w = buttonWidth - padding * 2

            // 背景高亮视图
            let bgView = NSView()
            bgView.wantsLayer = true
            bgView.layer?.cornerRadius = 6
            bgView.layer?.backgroundColor = NSColor.clear.cgColor
            bgView.frame = NSRect(x: x, y: 8, width: w, height: 30)
            addSubview(bgView)
            bgViews.append(bgView)

            // 按钮
            let button = NSButton(title: provider.rawValue, target: self, action: #selector(tabClicked(_:)))
            button.tag = index
            button.bezelStyle = .inline
            button.font = .systemFont(ofSize: 13, weight: .medium)
            button.isBordered = false
            button.contentTintColor = .textSecondary
            button.frame = NSRect(x: x, y: 10, width: w, height: 26)
            addSubview(button)
            buttons.append(button)
        }

        // 下划线指示器
        underline.wantsLayer = true
        underline.layer?.backgroundColor = NSColor.themeAccent.cgColor
        underline.layer?.cornerRadius = 1.5
        underline.frame = NSRect(x: 12, y: 4, width: buttonWidth - 24, height: 3)
        addSubview(underline)
    }

    private func updateSelection(animated: Bool) {
        let index = APIProvider.allCases.firstIndex(of: selectedProvider) ?? 0
        let buttonWidth = Self.menuWidth / CGFloat(APIProvider.allCases.count)
        let targetX = CGFloat(index) * buttonWidth + 12

        for (i, button) in buttons.enumerated() {
            let isSelected = (i == index)
            button.contentTintColor = isSelected ? .themeAccent : .textSecondary
            button.font = .systemFont(ofSize: 13, weight: isSelected ? .semibold : .medium)

            // 背景高亮
            if i < bgViews.count {
                bgViews[i].layer?.backgroundColor = isSelected
                    ? NSColor.themeAccent.withAlphaComponent(0.1).cgColor
                    : NSColor.clear.cgColor
            }
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                underline.animator().frame.origin.x = targetX
            }
        } else {
            underline.frame.origin.x = targetX
        }
    }

    @objc private func tabClicked(_ sender: NSButton) {
        let index = sender.tag
        guard index < APIProvider.allCases.count else { return }
        selectedProvider = APIProvider.allCases[index]
        updateSelection(animated: true)
        onTabSelected?(selectedProvider)
    }
}
