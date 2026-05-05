import AppKit

/// 设置窗口 — API Key 管理
class SettingsWindowController: NSWindowController {

    private var keyFields: [APIProvider: NSTextField] = [:]
    private var statusLabels: [APIProvider: NSTextField] = [:]
    private var testButtons: [APIProvider: NSButton] = [:]

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = NSLocalizedString("settings.title", comment: "")
        window.center()
        window.isReleasedWhenClosed = false

        self.init(window: window)
        setupUI()
        loadExistingKeys()
    }

    // MARK: - UI 构建

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let headerLabel = makeLabel(text: NSLocalizedString("settings.header", comment: ""), fontSize: 18, bold: true)
        headerLabel.frame = NSRect(x: 24, y: 310, width: 400, height: 24)
        contentView.addSubview(headerLabel)

        let descLabel = makeLabel(text: NSLocalizedString("settings.description", comment: ""), fontSize: 12, bold: false)
        descLabel.textColor = .secondaryLabelColor
        descLabel.frame = NSRect(x: 24, y: 288, width: 400, height: 16)
        contentView.addSubview(descLabel)

        var yOffset: CGFloat = 248

        for provider in APIProvider.allCases {
            // 平台名
            let nameLabel = makeLabel(text: provider.localizedName, fontSize: 14, bold: true)
            nameLabel.frame = NSRect(x: 24, y: yOffset, width: 80, height: 20)
            contentView.addSubview(nameLabel)

            // Key 输入框
            let keyField = NSTextField()
            if provider == .miMo {
                keyField.placeholderString = NSLocalizedString("settings.placeholder.mimo", comment: "")
            } else {
                keyField.placeholderString = String(format: NSLocalizedString("settings.placeholder.key", comment: ""), provider.rawValue)
            }
            keyField.frame = NSRect(x: 110, y: yOffset, width: 240, height: 24)
            keyField.font = .systemFont(ofSize: 13)
            contentView.addSubview(keyField)
            keyFields[provider] = keyField

            // 测试按钮
            let testBtn = NSButton(title: NSLocalizedString("settings.button.test", comment: ""), target: self, action: #selector(testConnection(_:)))
            testBtn.tag = APIProvider.allCases.firstIndex(of: provider) ?? 0
            testBtn.bezelStyle = .rounded
            testBtn.font = .systemFont(ofSize: 12)
            testBtn.frame = NSRect(x: 358, y: yOffset - 2, width: 50, height: 28)
            contentView.addSubview(testBtn)
            testButtons[provider] = testBtn

            // 保存按钮
            let saveBtn = NSButton(title: NSLocalizedString("settings.button.save", comment: ""), target: self, action: #selector(saveKey(_:)))
            saveBtn.tag = APIProvider.allCases.firstIndex(of: provider) ?? 0
            saveBtn.bezelStyle = .rounded
            saveBtn.font = .systemFont(ofSize: 12)
            saveBtn.frame = NSRect(x: 414, y: yOffset - 2, width: 50, height: 28)
            contentView.addSubview(saveBtn)

            // 状态标签
            let statusLabel = makeLabel(text: "", fontSize: 11, bold: false)
            statusLabel.frame = NSRect(x: 110, y: yOffset - 20, width: 354, height: 14)
            contentView.addSubview(statusLabel)
            statusLabels[provider] = statusLabel

            yOffset -= 72
        }

        // 底部按钮
        let closeBtn = NSButton(title: NSLocalizedString("settings.button.close", comment: ""), target: self, action: #selector(closeWindow))
        closeBtn.bezelStyle = .rounded
        closeBtn.font = .systemFont(ofSize: 13)
        closeBtn.frame = NSRect(x: 380, y: 16, width: 80, height: 28)
        contentView.addSubview(closeBtn)
    }

    // MARK: - 数据加载

    private func loadExistingKeys() {
        for provider in APIProvider.allCases {
            if provider == .miMo {
                if KeychainService.loadMiMoCookie() != nil {
                    statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.cookieSaved", comment: "")
                    statusLabels[provider]?.textColor = .systemGreen
                } else {
                    statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.cookieNotSet", comment: "")
                    statusLabels[provider]?.textColor = .secondaryLabelColor
                }
            } else if KeychainService.load(for: provider) != nil {
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.keySaved", comment: "")
                statusLabels[provider]?.textColor = .systemGreen
            } else {
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.keyNotSet", comment: "")
                statusLabels[provider]?.textColor = .secondaryLabelColor
            }
        }
    }

    private func maskKey(_ key: String) -> String {
        guard key.count > 8 else { return "****" }
        let prefix = key.prefix(4)
        let suffix = key.suffix(4)
        return "\(prefix)****\(suffix)"
    }

    // MARK: - Actions

    @objc private func saveKey(_ sender: NSButton) {
        let index = sender.tag
        guard index < APIProvider.allCases.count else { return }
        let provider = APIProvider.allCases[index]
        guard let keyField = keyFields[provider] else { return }

        let keyValue = keyField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if keyValue.contains("****") {
            if provider == .miMo {
                if KeychainService.loadMiMoCookie() != nil {
                    statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.skipSave", comment: "")
                    statusLabels[provider]?.textColor = .secondaryLabelColor
                    return
                }
            } else {
                if KeychainService.hasKey(for: provider) {
                    statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.skipSave", comment: "")
                    statusLabels[provider]?.textColor = .secondaryLabelColor
                    return
                }
            }
        }

        guard !keyValue.isEmpty else {
            if provider == .miMo {
                KeychainService.deleteMiMoCookie()
            } else {
                KeychainService.delete(for: provider)
            }
            keyField.stringValue = ""
            statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.deleted", comment: "")
            statusLabels[provider]?.textColor = .systemOrange
            return
        }

        if provider == .miMo {
            let success = KeychainService.saveMiMoCookie(keyValue)
            if success {
                keyField.stringValue = maskKey(keyValue)
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.cookieSaved", comment: "")
                statusLabels[provider]?.textColor = .systemGreen
                Task { await UsageMonitor.shared.refresh(provider: .miMo) }
            } else {
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.saveFailed", comment: "")
                statusLabels[provider]?.textColor = .systemRed
            }
        } else {
            let success = KeychainService.save(key: keyValue, for: provider)
            if success {
                keyField.stringValue = maskKey(keyValue)
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.keySaved", comment: "")
                statusLabels[provider]?.textColor = .systemGreen
            } else {
                statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.saveFailed", comment: "")
                statusLabels[provider]?.textColor = .systemRed
            }
        }
    }

    @objc private func testConnection(_ sender: NSButton) {
        let index = sender.tag
        guard index < APIProvider.allCases.count else { return }
        let provider = APIProvider.allCases[index]

        guard KeychainService.hasKey(for: provider) else {
            statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.needSaveFirst", comment: "")
            statusLabels[provider]?.textColor = .systemOrange
            return
        }

        sender.isEnabled = false
        sender.title = NSLocalizedString("settings.status.testing", comment: "")
        statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.testingConnection", comment: "")
        statusLabels[provider]?.textColor = .secondaryLabelColor

        Task {
            do {
                _ = try await APIService.fetchUsage(for: provider)
                await MainActor.run {
                    statusLabels[provider]?.stringValue = NSLocalizedString("settings.status.connectionSuccess", comment: "")
                    statusLabels[provider]?.textColor = .systemGreen
                    sender.isEnabled = true
                    sender.title = NSLocalizedString("settings.button.test", comment: "")
                }
            } catch {
                await MainActor.run {
                    statusLabels[provider]?.textColor = .systemRed
                    statusLabels[provider]?.stringValue = "✗ \(error.localizedDescription)"
                    sender.isEnabled = true
                    sender.title = NSLocalizedString("settings.button.test", comment: "")
                }
            }
        }
    }

    @objc private func closeWindow() {
        window?.close()
    }

    // MARK: - Helpers

    private func makeLabel(text: String, fontSize: CGFloat, bold: Bool) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: fontSize, weight: bold ? .semibold : .regular)
        label.lineBreakMode = .byTruncatingTail
        return label
    }
}
