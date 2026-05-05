import Foundation

/// 用量监控管理器
class UsageMonitor {
    static let shared = UsageMonitor()

    /// 各平台的最新数据
    private(set) var data: [APIProvider: UsageData] = [:]

    /// 加载状态
    private(set) var isLoading: [APIProvider: Bool] = [:]

    /// 错误信息
    private(set) var errors: [APIProvider: String] = [:]

    /// 状态更新回调
    var onUpdate: (() -> Void)?

    private var timer: Timer?

    /// 开始定时刷新
    func startMonitoring() {
        stopMonitoring()
        // 立即刷新所有平台
        Task { await refreshAll() }
        // 定时器
        let interval = AppSettings.shared.refreshInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.refreshAll() }
        }
    }

    /// 停止监控
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    /// 刷新所有平台
    func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            for provider in APIProvider.allCases {
                guard KeychainService.hasKey(for: provider) else { continue }
                group.addTask { [weak self] in
                    await self?.refresh(provider: provider)
                }
            }
        }
    }

    /// 刷新指定平台
    func refresh(provider: APIProvider) async {
        await MainActor.run {
            isLoading[provider] = true
            errors[provider] = nil
            onUpdate?()
        }

        do {
            let result = try await APIService.fetchUsage(for: provider)
            await MainActor.run {
                data[provider] = result
                isLoading[provider] = false
                onUpdate?()
            }
        } catch {
            await MainActor.run {
                isLoading[provider] = false
                errors[provider] = error.localizedDescription
                onUpdate?()
            }
        }
    }
}
