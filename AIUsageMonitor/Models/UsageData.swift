import Foundation

/// 统一的用量数据模型
struct UsageData {
    let provider: APIProvider
    let balance: Double?        // 余额/剩余量
    let usagePercent: Double?   // 用量百分比
    let rawJSON: [String: Any]?
    let fetchedAt: Date
    let extraInfo: String?      // 详情文案
    let cycleInfo: String       // 更新周期
    let timeRange: String       // 时间范围
    let remainingTime: String    // 剩余时间

    init(provider: APIProvider, balance: Double? = nil, usagePercent: Double? = nil, rawJSON: [String: Any]? = nil, extraInfo: String? = nil, cycleInfo: String = "", timeRange: String = "", remainingTime: String = "") {
        self.provider = provider
        self.balance = balance
        self.usagePercent = usagePercent
        self.rawJSON = rawJSON
        self.fetchedAt = Date()
        self.extraInfo = extraInfo
        self.cycleInfo = cycleInfo
        self.timeRange = timeRange
        self.remainingTime = remainingTime
    }

    /// 格式化主显示（如 "已用 550/600"）
    var balanceText: String {
        guard let balance = balance else { return "--" }
        switch provider {
        case .minimax:
            return extraInfo ?? "剩余 \(Int(balance)) 次"
        case .zhipuAI, .miMo:
            return "\(Int(balance)) tokens"
        }
    }

    /// 格式化百分比
    var usagePercentText: String {
        guard let percent = usagePercent else { return "" }
        return String(format: "%.1f%%", percent)
    }
}
