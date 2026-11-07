import SwiftUI

/// 应用界面动效；系统减少动态效果设置优先于主题。
enum InterfaceMotion: String, CaseIterable, Identifiable {
    case lively, gentle, still
    var id: String { rawValue }
    var title: String {
        switch self {
        case .lively: return "灵动"
        case .gentle: return "轻盈"
        case .still: return "静止"
        }
    }
    func animation(reduce: Bool) -> Animation? {
        guard !reduce, self != .still else { return nil }
        return .easeOut(duration: self == .lively ? 0.24 : 0.16)
    }
    func transition(reduce: Bool) -> AnyTransition {
        guard !reduce, self != .still else { return .identity }
        return self == .lively ? .opacity.combined(with: .offset(y: 10)) : .opacity
    }
}

/// 保留系统按钮的键盘操作，用统一样式提供悬停、按压和禁用反馈。
struct MotionButtonStyle: ButtonStyle {
    var prominent = false
    func makeBody(configuration: Configuration) -> some View {
        MotionButtonBody(configuration: configuration, prominent: prominent)
    }
}

private struct MotionButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let prominent: Bool
    @AppStorage("interfaceMotion") private var motion = InterfaceMotion.lively.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var enabled
    @Environment(\.isFocused) private var focused
    @State private var hovered = false
    private var theme: InterfaceMotion { InterfaceMotion(rawValue: motion) ?? .lively }
    private var moves: Bool { !reduceMotion && theme != .still && enabled }

    var body: some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .foregroundColor(prominent ? Color.white : Color.primary)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(prominent ? Color.accentColor : Color.primary.opacity(hovered && enabled ? 0.10 : 0.045))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(focused ? Color.accentColor : Color.primary.opacity(0.10), lineWidth: focused ? 2 : 1)
            }
            .opacity(enabled ? (configuration.isPressed ? 0.82 : 1) : 0.4)
            .scaleEffect(moves && configuration.isPressed ? (theme == .lively ? 0.94 : 0.98) : 1)
            .offset(y: moves && hovered && !configuration.isPressed && theme == .lively ? -1 : 0)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .onHover { hovered = $0 }
            .animation(theme.animation(reduce: reduceMotion), value: hovered)
            .animation(theme.animation(reduce: reduceMotion), value: configuration.isPressed)
    }
}

struct MotionHover: ViewModifier {
    @AppStorage("interfaceMotion") private var motion = InterfaceMotion.lively.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hovered = false
    func body(content: Content) -> some View {
        let theme = InterfaceMotion(rawValue: motion) ?? .lively
        content
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(hovered ? 0.075 : 0)))
            .onHover { hovered = $0 }
            .animation(theme.animation(reduce: reduceMotion), value: hovered)
    }
}
