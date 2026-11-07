import SwiftUI
import WebKit

/// 简洁的应用内网页阅读界面，供单页订阅、分类链接和文章原文复用。
struct SubscriptionWebView: View {
    @StateObject private var model: SubscriptionWebViewModel

    init(url: String) {
        _model = StateObject(wrappedValue: SubscriptionWebViewModel(url: url))
    }

    @AppStorage("interfaceMotion") private var motion = InterfaceMotion.lively.rawValue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var theme: InterfaceMotion { InterfaceMotion(rawValue: motion) ?? .lively }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button { model.webView.goBack() } label: { Image(systemName: "chevron.left") }
                    .disabled(!model.canGoBack).help("返回上一网页").accessibilityLabel("返回上一网页")
                Button { model.webView.goForward() } label: { Image(systemName: "chevron.right") }
                    .disabled(!model.canGoForward).help("前进").accessibilityLabel("前进")
                Button {
                    if model.isLoading { model.webView.stopLoading() } else { model.reload() }
                } label: { Image(systemName: model.isLoading ? "xmark" : "arrow.clockwise") }
                    .help(model.isLoading ? "停止加载" : "刷新网页")
                    .accessibilityLabel(model.isLoading ? "停止加载" : "刷新网页")

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.pageTitle.isEmpty ? "订阅网页" : model.pageTitle)
                        .font(.system(size: 13, weight: .semibold)).lineLimit(1)
                    Text(model.currentURL?.host ?? "等待加载")
                        .font(.caption).foregroundColor(.secondary).lineLimit(1)
                }
                .padding(.leading, 6)
                .help(model.currentURL?.absoluteString ?? "")
                Spacer(minLength: 4)
                if let url = model.currentURL {
                    Link(destination: url) { Image(systemName: "arrow.up.right.square") }
                        .help("在浏览器中打开当前网页").accessibilityLabel("在浏览器中打开当前网页")
                }
            }
            .buttonStyle(MotionButtonStyle())
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            // 固定高度的进度轨道，不因加载状态改变网页可用高度。
            GeometryReader { geometry in
                Color.accentColor
                    .frame(width: geometry.size.width)
                    .scaleEffect(x: max(0, min(model.progress, 1)), y: 1, anchor: .leading)
                    .opacity(model.isLoading ? 1 : 0)
                    .animation(theme.animation(reduce: reduceMotion), value: model.progress)
                    .animation(theme.animation(reduce: reduceMotion), value: model.isLoading)
            }
            .frame(height: 2)
            .background(Color.primary.opacity(0.07))
            .accessibilityLabel("网页加载进度")
            .accessibilityValue("\(Int(model.progress * 100))%")

            ZStack(alignment: .top) {
                SubscriptionWebSurface(model: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let error = model.errorMessage {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("暂时无法显示网页").font(.headline)
                            Text(error).font(.callout).foregroundColor(.secondary).textSelection(.enabled)
                        }
                        Spacer(minLength: 8)
                        Button("重试") { model.reload() }.buttonStyle(MotionButtonStyle(prominent: true))
                    }
                    .padding(16)
                    .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.primary.opacity(0.12)))
                    .padding(16)
                    .transition(theme.transition(reduce: reduceMotion))
                }
            }
            .animation(theme.animation(reduce: reduceMotion), value: model.errorMessage)
        }
        .frame(minWidth: 320, minHeight: 300)
        .task { model.load() }
        .onDisappear { model.webView.stopLoading() }
    }
}

private struct SubscriptionWebSurface: NSViewRepresentable {
    let model: SubscriptionWebViewModel
    func makeNSView(context: Context) -> WKWebView { model.webView }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    static func dismantleNSView(_ nsView: WKWebView, coordinator: ()) { nsView.stopLoading() }
}

struct SubscriptionWebSheet: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("订阅阅读", systemImage: "globe").font(.headline)
                Spacer()
                Button("完成") { dismiss() }
                    .buttonStyle(MotionButtonStyle()).keyboardShortcut(.cancelAction)
            }.padding()
            SubscriptionWebView(url: url)
        }
        .frame(minWidth: 600, idealWidth: 900, minHeight: 450, idealHeight: 700)
    }
}
