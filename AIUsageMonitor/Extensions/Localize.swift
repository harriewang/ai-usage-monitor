import Foundation

/// 本地化字符串获取
func L(_ key: String, _ args: CVarArg...) -> String {
    let template = NSLocalizedString(key, comment: "")
    if args.isEmpty {
        return template
    }
    return String(format: template, arguments: args)
}