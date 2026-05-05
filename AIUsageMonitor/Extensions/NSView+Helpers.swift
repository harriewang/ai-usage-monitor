import AppKit

extension NSView {
    /// 设置 AutoresizingMask 为约束
    func autoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    /// 添加子视图并设置自动布局
    func addSubview(_ view: NSView, autoLayout: Bool) {
        addSubview(view)
        if autoLayout {
            view.autoLayout()
        }
    }
}
