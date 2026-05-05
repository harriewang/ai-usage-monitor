import Foundation

/// API Key 存储服务（本地文件，避免 Keychain 反复弹窗）
enum KeychainService {
    private static let fileName = "api_keys.json"

    private static var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("AIUsageMonitor", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    /// 所有 Key
    private static var allKeys: [String: String] {
        get {
            guard let data = try? Data(contentsOf: fileURL),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }

    /// 保存 API Key
    static func save(key: String, for provider: APIProvider) -> Bool {
        var keys = allKeys
        keys[provider.keychainAccount] = key
        allKeys = keys
        return true
    }

    /// 读取 API Key
    static func load(for provider: APIProvider) -> String? {
        return allKeys[provider.keychainAccount]
    }

    /// 删除 API Key
    @discardableResult
    static func delete(for provider: APIProvider) -> Bool {
        var keys = allKeys
        keys.removeValue(forKey: provider.keychainAccount)
        allKeys = keys
        return true
    }

    /// 检查是否已存储 Key
    static func hasKey(for provider: APIProvider) -> Bool {
        return load(for: provider) != nil
    }

    // MARK: - MiMo Cookie

    private static let miMoCookieKey = "mimo_cookie"

    /// 保存 MiMo Cookie
    static func saveMiMoCookie(_ cookie: String) -> Bool {
        var keys = allKeys
        keys[miMoCookieKey] = cookie
        allKeys = keys
        return true
    }

    /// 读取 MiMo Cookie
    static func loadMiMoCookie() -> String? {
        return allKeys[miMoCookieKey]
    }

    /// 删除 MiMo Cookie
    @discardableResult
    static func deleteMiMoCookie() -> Bool {
        var keys = allKeys
        keys.removeValue(forKey: miMoCookieKey)
        allKeys = keys
        return true
    }
}
