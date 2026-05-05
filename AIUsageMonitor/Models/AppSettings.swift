import Foundation

/// 应用设置（UserDefaults）
class AppSettings {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let selectedProvider = "selectedProvider"
        static let refreshInterval = "refreshInterval"
    }

    /// 当前选中的平台
    var selectedProvider: APIProvider {
        get {
            guard let raw = defaults.string(forKey: Keys.selectedProvider),
                  let provider = APIProvider(rawValue: raw) else {
                return .minimax
            }
            return provider
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.selectedProvider)
        }
    }

    /// 刷新间隔（秒）
    var refreshInterval: TimeInterval {
        get {
            let interval = defaults.double(forKey: Keys.refreshInterval)
            return interval > 0 ? interval : 60 // 默认 60 秒
        }
        set {
            defaults.set(newValue, forKey: Keys.refreshInterval)
        }
    }
}
