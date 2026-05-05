import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let monitor = UsageMonitor.shared
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMonitorCallback()
        monitor.startMonitoring()
    }

    // MARK: - 状态栏

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = AppIcon.menuBarIcon()
            button.imagePosition = .imageLeft
            button.toolTip = "AI 用量监控"
        }
        NSApp.applicationIconImage = AppIcon.appIcon()
        rebuildMenu()
    }

    // MARK: - 监控回调

    private func setupMonitorCallback() {
        monitor.onUpdate = { [weak self] in
            self?.rebuildMenu()
        }
    }

    // MARK: - 菜单构建

    private func rebuildMenu() {
        let callbacks = MenuBuilder.MenuCallbacks(
            onRefresh: { [weak self] in self?.refreshAll() },
            onOpenSettings: { [weak self] in self?.openSettings() },
            onQuit: { [weak self] in self?.quitApp() }
        )

        let menu = MenuBuilder.buildMenu(
            allData: monitor.data,
            allLoading: monitor.isLoading,
            allErrors: monitor.errors,
            callbacks: callbacks
        )

        statusItem.menu = menu
    }

    // MARK: - Actions

    private func refreshAll() {
        Task {
            await monitor.refreshAll()
        }
    }

    private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(self)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quitApp() {
        monitor.stopMonitoring()
        NSApp.terminate(nil)
    }
}
