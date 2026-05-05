import Foundation

/// 网络错误
enum APIError: LocalizedError {
    case noAPIKey
    case httpError(statusCode: Int)
    case decodingError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "未设置 API Key"
        case .httpError(let code):
            return "请求失败 (HTTP \(code))"
        case .decodingError(let detail):
            return "解析失败: \(detail)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

/// 网络服务
enum APIService {

    /// 查询指定平台的余额
    static func fetchUsage(for provider: APIProvider) async throws -> UsageData {
        switch provider {
        case .miMo:
            return try await fetchMiMoUsage()
        default:
            return try await fetchStandardUsage(for: provider)
        }
    }

    /// MiMo 网页接口（Cookie 认证）
    private static func fetchMiMoUsage() async throws -> UsageData {
        guard let apiKey = KeychainService.load(for: .miMo) else {
            throw APIError.noAPIKey
        }

        guard let cookie = KeychainService.loadMiMoCookie() else {
            throw APIError.noAPIKey
        }

        var request = URLRequest(url: APIProvider.miMo.balanceURL)
        request.httpMethod = "GET"
        request.setValue("https://platform.xiaomimimo.com/console/plan-manage", forHTTPHeaderField: "referer")
        request.setValue("Asia/Shanghai", forHTTPHeaderField: "x-timezone")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let rawJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let rawJSON = rawJSON {
            print("[MiMo] 响应: \(rawJSON)")
        }

        return parseMiMoResponse(rawJSON)
    }

    /// 标准 API（Authorization 认证）
    private static func fetchStandardUsage(for provider: APIProvider) async throws -> UsageData {
        guard let apiKey = KeychainService.load(for: provider) else {
            throw APIError.noAPIKey
        }

        var request = URLRequest(url: provider.balanceURL)
        request.httpMethod = provider.httpMethod
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        if provider.needsRequestBody {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "model": provider.chatModel,
                "messages": [["role": "user", "content": "hi"]],
                "max_tokens": 1
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let rawJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let rawJSON = rawJSON {
            print("[\(provider.rawValue)] 响应: \(rawJSON)")
        }

        return parseResponse(data: data, provider: provider, rawJSON: rawJSON)
    }

    // MARK: - 解析

    private static func parseResponse(data: Data, provider: APIProvider, rawJSON: [String: Any]?) -> UsageData {
        switch provider {
        case .minimax:
            return parseMiniMaxResponse(rawJSON: rawJSON, provider: provider)
        case .zhipuAI, .miMo:
            return parseChatCompletionResponse(rawJSON: rawJSON, provider: provider)
        }
    }

    /// 解析 MiniMax：从 model_remains 数组中找主要模型
    private static func parseMiniMaxResponse(rawJSON: [String: Any]?, provider: APIProvider) -> UsageData {
        guard let json = rawJSON,
              let models = json["model_remains"] as? [[String: Any]] else {
            return UsageData(provider: provider, rawJSON: rawJSON)
        }

        // 优先找用量最大的模型（先看 total 最高的），而非优先 coding-plan
        let target = models.max { a, b in
            let totalA = a["current_interval_total_count"] as? Int ?? 0
            let totalB = b["current_interval_total_count"] as? Int ?? 0
            return totalA < totalB
        } ?? models.first

        guard let model = target else {
            return UsageData(provider: provider, rawJSON: rawJSON)
        }

        let total = model["current_interval_total_count"] as? Int ?? 0
        let remains = model["current_interval_usage_count"] as? Int ?? 0

        // 调试：打印所有可用字段
        print("[MiniMax] model_name=\(model["model_name"] ?? "nil")")
        print("[MiniMax] keys=\(model.keys.map { String(describing: $0) }.sorted())")
        print("[MiniMax] raw total_count fields: interval=\(model["current_interval_total_count"] ?? "nil"), weekly=\(model["current_weekly_total_count"] ?? "nil")")

        let used = total - remains
        print("[MiniMax] total=\(total), remains=\(remains), used=\(used)")
        let usagePercent = total > 0 ? Double(used) / Double(total) * 100.0 : nil

        // 格式：已用 52/600
        let displayText = "已用 \(used)/\(total)"

        // 解析时间信息
        let startTime = model["start_time"] as? Int64 ?? 0
        let endTime = model["end_time"] as? Int64 ?? 0
        let remainsTime = model["remains_time"] as? Int64 ?? 0

        let cycleInfo = ""
        let timeRange = formatTimeRange(start: startTime, end: endTime)
        let remainingTime = formatRemainingTime(milliseconds: remainsTime)

        return UsageData(
            provider: provider,
            balance: Double(total - used),
            usagePercent: usagePercent,
            rawJSON: rawJSON,
            extraInfo: displayText,
            cycleInfo: cycleInfo,
            timeRange: timeRange,
            remainingTime: remainingTime
        )
    }

    /// 解析 chat completions 响应（智谱AI）
    private static func parseChatCompletionResponse(rawJSON: [String: Any]?, provider: APIProvider) -> UsageData {
        guard let json = rawJSON else {
            return UsageData(provider: provider, rawJSON: rawJSON)
        }

        // 优先使用余额字段（来自 /usage 接口）
        if let balance = json["balance"] as? Double,
           let usagePercent = json["usage_percent"] as? Double {
            return UsageData(
                provider: provider,
                balance: balance,
                usagePercent: usagePercent,
                rawJSON: rawJSON,
                extraInfo: nil,
                cycleInfo: "",
                timeRange: "",
                remainingTime: ""
            )
        }

        // chat completions 响应中的 usage（本次 API 调用的 token 消耗）
        if let usage = json["usage"] as? [String: Any] {
            let totalTokens = (usage["total_tokens"] as? Int) ?? 0
            let promptTokens = (usage["prompt_tokens"] as? Int) ?? 0
            let completionTokens = (usage["completion_tokens"] as? Int) ?? 0

            return UsageData(
                provider: provider,
                balance: Double(totalTokens),
                usagePercent: nil,
                rawJSON: rawJSON,
                extraInfo: "prompt: \(promptTokens), completion: \(completionTokens)",
                cycleInfo: "",
                timeRange: "",
                remainingTime: ""
            )
        }

        return UsageData(
            provider: provider,
            balance: nil,
            usagePercent: nil,
            rawJSON: rawJSON,
            cycleInfo: "",
            timeRange: "",
            remainingTime: ""
        )
    }

    /// 解析 MiMo 网页接口响应
    private static func parseMiMoResponse(_ rawJSON: [String: Any]?) -> UsageData {
        guard let json = rawJSON,
              let data = json["data"] as? [String: Any],
              let usage = data["usage"] as? [String: Any],
              let items = usage["items"] as? [[String: Any]],
              let planItem = items.first(where: { ($0["name"] as? String) == "plan_total_token" }) else {
            return UsageData(provider: .miMo, rawJSON: rawJSON)
        }

        let used = planItem["used"] as? Int ?? 0
        let limit = planItem["limit"] as? Int ?? 0
        let percent = planItem["percent"] as? Double ?? 0

        let displayText = "已用 \(formatNumber(used))/\(formatNumber(limit))"
        let usagePercent = percent * 100

        // 尝试获取月度周期信息
        var timeRange = ""
        if let monthUsage = data["monthUsage"] as? [String: Any],
           let monthItems = monthUsage["items"] as? [[String: Any]],
           let monthItem = monthItems.first {
            if let start = monthItem["start_time"] as? Int64, let end = monthItem["end_time"] as? Int64 {
                timeRange = formatTimeRange(start: start, end: end)
            }
        }

        return UsageData(
            provider: .miMo,
            balance: Double(limit - used),
            usagePercent: usagePercent,
            rawJSON: rawJSON,
            extraInfo: displayText,
            cycleInfo: "",
            timeRange: timeRange,
            remainingTime: ""
        )
    }

    /// 格式化数字（添加千分位）
    private static func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }

    // MARK: - 时间格式化

    /// 格式化时间范围（如 "05-01 ~ 05-07"）
    private static func formatTimeRange(start: Int64, end: Int64) -> String {
        guard start > 0, end > 0 else { return "" }
        let startDate = Date(timeIntervalSince1970: Double(start) / 1000)
        let endDate = Date(timeIntervalSince1970: Double(end) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }

    /// 格式化剩余时间（如 "重置时间：3小时25分钟后重置"）
    private static func formatRemainingTime(milliseconds: Int64) -> String {
        let totalSeconds = milliseconds / 1000
        guard totalSeconds > 0 else { return "" }
        if totalSeconds >= 3600 {
            let hours = totalSeconds / 3600
            let mins = (totalSeconds % 3600) / 60
            return "重置时间：\(hours)小时\(mins)分钟后重置"
        } else {
            return "重置时间：\(totalSeconds / 60)分钟后重置"
        }
    }
}
