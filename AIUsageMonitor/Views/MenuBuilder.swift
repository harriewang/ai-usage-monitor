import AppKit

/// 菜单构建器 — 无状态工厂，根据当前状态构建完整 NSMenu
enum MenuBuilder {

    struct MenuCallbacks {
        var onRefresh: (() -> Void)?
        var onOpenSettings: (() -> Void)?
        var onQuit: (() -> Void)?
    }

    /// 根据当前状态构建菜单（显示所有平台）
    static func buildMenu(
        allData: [APIProvider: UsageData],
        allLoading: [APIProvider: Bool],
        allErrors: [APIProvider: String],
        callbacks: MenuCallbacks
    ) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        // 1. 标题
        let titleItem = NSMenuItem()
        titleItem.view = makeHeaderView()
        menu.addItem(titleItem)

        menu.addItem(.separator())

        // 2. 三个平台卡片
        for (index, provider) in APIProvider.allCases.enumerated() {
            let data = allData[provider]
            let isLoading = allLoading[provider] ?? false
            let error = allErrors[provider]
            let hasKey = KeychainService.hasKey(for: provider)

            let cardView = PlatformCardView()
            cardView.configure(provider: provider, data: data, isLoading: isLoading, error: error, hasKey: hasKey)
            let cardItem = NSMenuItem()
            cardItem.view = cardView
            menu.addItem(cardItem)

            if index < APIProvider.allCases.count - 1 {
                menu.addItem(.separator())
            }
        }

        menu.addItem(.separator())

        // 3. 操作按钮
        let actionView = ActionButtonsView()
        actionView.onRefresh = callbacks.onRefresh
        actionView.onOpenSettings = callbacks.onOpenSettings
        actionView.onQuit = callbacks.onQuit
        let actionItem = NSMenuItem()
        actionItem.view = actionView
        menu.addItem(actionItem)

        return menu
    }

    /// 顶部标题视图
    private static func makeHeaderView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 36))

        let titleLabel = NSTextField(labelWithString: NSLocalizedString("menu.title", comment: ""))
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .textPrimary
        titleLabel.frame = NSRect(x: 16, y: 8, width: 200, height: 20)
        view.addSubview(titleLabel)

        return view
    }
}
