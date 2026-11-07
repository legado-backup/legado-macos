import Foundation
import WebKit

/// 订阅网页的导航状态。网页渲染使用 WebKit，不向网页注入书源 JavaScript 兼容接口。
@MainActor
final class SubscriptionWebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    let webView: WKWebView
    private let initialURL: String
    @Published private(set) var progress = 0.0
    @Published private(set) var pageTitle = ""
    @Published private(set) var canGoBack = false
    @Published private(set) var canGoForward = false
    @Published private(set) var isLoading = false
    @Published private(set) var currentURL: URL?
    @Published private(set) var errorMessage: String?
    private var observations: [NSKeyValueObservation] = []

    init(url: String) {
        initialURL = url
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = ReadConfig.shared.userAgent
        observations = [
            webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() },
            webView.observe(\.title, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() },
            webView.observe(\.canGoBack, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() },
            webView.observe(\.canGoForward, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() },
            webView.observe(\.isLoading, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() },
            webView.observe(\.url, options: [.new]) { [weak self] _, _ in self?.scheduleUpdate() }
        ]
    }

    nonisolated private func scheduleUpdate() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            progress = webView.estimatedProgress
            pageTitle = webView.title ?? ""
            canGoBack = webView.canGoBack
            canGoForward = webView.canGoForward
            isLoading = webView.isLoading
            currentURL = webView.url
        }
    }

    static func webpageURL(_ value: String) -> URL? {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
              url.host != nil else { return nil }
        return url
    }

    func load() {
        guard let url = Self.webpageURL(initialURL) else {
            errorMessage = "无法打开此链接，请使用完整的 HTTP 或 HTTPS 网页地址。"
            return
        }
        errorMessage = nil
        currentURL = url
        webView.load(URLRequest(url: url, timeoutInterval: ReadConfig.shared.requestTimeout))
    }

    func reload() {
        errorMessage = nil
        if webView.url == nil { load() } else { webView.reload() }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, Self.webpageURL(url.absoluteString) != nil else {
            decisionHandler(.cancel)
            return
        }
        if navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
            webView.load(navigationAction.request)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard navigationResponse.canShowMIMEType else {
            if navigationResponse.isForMainFrame {
                errorMessage = "此内容无法在应用内展示，请使用浏览器打开。"
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        errorMessage = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        show(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        show(error)
    }

    private func show(_ error: Error) {
        let error = error as NSError
        guard !(error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) else { return }
        errorMessage = "网页加载失败：\(error.localizedDescription)"
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        errorMessage = "网页已停止响应，请刷新重试。"
    }
}
