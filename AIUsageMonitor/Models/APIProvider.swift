import Foundation

/// AI 平台枚举
enum APIProvider: String, CaseIterable, Identifiable {
    case minimax = "MiniMax"
    case zhipuAI = "智谱AI"
    case miMo = "MiMo"

    var id: String { rawValue }

    /// 余额查询 URL
    var balanceURL: URL {
        switch self {
        case .minimax:
            return URL(string: "https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains")!
        case .zhipuAI:
            return URL(string: "https://open.bigmodel.cn/api/paas/v4/chat/completions")!
        case .miMo:
            return URL(string: "https://platform.xiaomimimo.com/api/v1/tokenPlan/usage")!
        }
    }

    /// HTTP 方法
    var httpMethod: String {
        switch self {
        case .minimax: return "GET"
        case .zhipuAI: return "POST"
        case .miMo: return "GET"
        }
    }

    /// 是否需要请求体（chat completions 方式）
    var needsRequestBody: Bool {
        switch self {
        case .minimax, .miMo: return false
        case .zhipuAI: return true
        }
    }

    /// MiMo 网页认证 Cookie（从浏览器获取）
    var miMoCookies: String? {
        return nil // 存储在 KeychainService 中
    }

    /// chat model 名称
    var chatModel: String {
        switch self {
        case .minimax: return ""
        case .zhipuAI: return "glm-4-flash"
        case .miMo: return "mimo-v2.5"
        }
    }

    /// Keychain 中的 account 标识
    var keychainAccount: String {
        switch self {
        case .minimax: return "minimax"
        case .zhipuAI: return "zhipu"
        case .miMo: return "mimo"
        }
    }

    /// 菜单栏显示的图标文字
    var icon: String {
        switch self {
        case .minimax: return "M"
        case .zhipuAI: return "Z"
        case .miMo: return "Mi"
        }
    }

    /// 图标图片名称（用于 Assets.xcassets）
    var iconImageName: String? {
        switch self {
        case .minimax: return "minimax"
        case .zhipuAI: return "zhipu"
        case .miMo: return "xiaomimimo"
        }
    }
}
