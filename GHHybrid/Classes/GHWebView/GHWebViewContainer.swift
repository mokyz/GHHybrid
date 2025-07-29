//
//  GHWebViewContainer.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

@preconcurrency import WebKit


// MARK: - GHWebViewContainer

/// WebView Container with enhanced functionality
public class GHWebViewContainer: UIView {
    
    // MARK: - Public Properties
    
    /// Real WKWebView instance
    public private(set) var realWebView: WKWebView!
    
    /// Delegate for WebView events
    public weak var delegate: GHWebViewDelegate?
    
    /// JavaScript bridge manager
    public private(set) var jsBridgeManager: GHBridgeManager!
    
    /// Custom user agent
    public var customUserAgent: String? {
        didSet {
            realWebView.customUserAgent = customUserAgent
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            realWebView.backgroundColor = backgroundColor
        }
    }
    
    /// KVO: Loading progress
    @objc public private(set) dynamic var estimatedProgress: Float = 0.0
    
    /// KVO: Document title
    @objc public private(set) dynamic var title: String = ""
    
    /// KVO: Loading URL
    @objc public private(set) dynamic var url: URL?
    
    
    // MARK: - Private Properties
    
    private var configuration: WKWebViewConfiguration!
    
    
    // MARK: - Static Properties
    
    /// Shared process pool for all WebViews
    private static let processPool: WKProcessPool = {
        return WKProcessPool()
    }()
    
    
    // MARK: - Initialization
    
    /// Default WebView configuration
    /// - Returns: Configured WKWebViewConfiguration
    public static func defaultConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = processPool
        configuration.allowsInlineMediaPlayback = true
        return configuration
    }
    
    /// Initialize with frame using default configuration
    /// - Parameter frame: Frame for the WebView
    public convenience override init(frame: CGRect) {
        self.init(frame: frame, configuration: Self.defaultConfiguration())
    }
    
    /// Initialize with frame and custom configuration
    /// - Parameters:
    ///   - frame: Frame for the WebView
    ///   - configuration: Custom WebView configuration
    public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame)
        self.configuration = configuration
        setupViews()
        setupConstraints()
        setupBridgeManager()
        setupKVO()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Remove KVO observers
        realWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        realWebView.removeObserver(self, forKeyPath: "title")
        realWebView.removeObserver(self, forKeyPath: "URL")
        
        // Clean up delegates
        realWebView.uiDelegate = nil
        realWebView.navigationDelegate = nil
        realWebView.scrollView.delegate = nil
        realWebView.configuration.userContentController.removeAllUserScripts()
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods

private extension GHWebViewContainer {
    
    /// Setup views
    func setupViews() {
        realWebView = WKWebView(frame: bounds, configuration: configuration)
        realWebView.uiDelegate = self
        realWebView.navigationDelegate = self
        realWebView.scrollView.delegate = self
        addSubview(realWebView)
    }
    
    /// Setup Layout Constraints
    func setupConstraints() {
        realWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            realWebView.topAnchor.constraint(equalTo: topAnchor),
            realWebView.leadingAnchor.constraint(equalTo: leadingAnchor),
            realWebView.trailingAnchor.constraint(equalTo: trailingAnchor),
            realWebView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// Setup jsBridgeManager
    func setupBridgeManager() {
        jsBridgeManager = GHBridgeManager.bridge(for: realWebView)
    }
    
    /// Setup KVO
    func setupKVO() {
        realWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        realWebView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        realWebView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    /// Setup notifications
    func setupNotifications() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(_ghWebViewDidEnterBackground),
//            name: UIApplication.didEnterBackgroundNotification,
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(_ghWebViewWillEnterForeground),
//            name: UIApplication.willEnterForegroundNotification,
//            object: nil
//        )
    }
}

// MARK: - Public Methods

public extension GHWebViewContainer {
    /// Add JavaScript to WebView
    /// - Parameters:
    ///   - javaScript: JavaScript code to inject
    ///   - injectTime: When to inject the script
    ///   - onlyForMainFrame: Whether to inject only in main frame
    func addUserScript(_ javaScript: String,
                       injectionTime injectTime: WKUserScriptInjectionTime,
                       forMainFrameOnly onlyForMainFrame: Bool) {
        let userScript = WKUserScript(source: javaScript,
                                      injectionTime: injectTime,
                                      forMainFrameOnly: onlyForMainFrame)
        realWebView.configuration.userContentController.addUserScript(userScript)
    }
    
    /// Check if WebView had history
    /// - Returns: true if can go back
    func canGoBack() -> Bool {
        realWebView.canGoBack
    }
    
    /// Go to previous page
    func goBack() {
        realWebView.goBack()
    }
    
    /// Check if WebView had next page
    /// - Returns: true if can go forward
    func canGoForward() -> Bool {
        realWebView.canGoForward
    }
    
    /// Go to next page
    func goForward() {
        realWebView.goForward()
    }
    
    /// Stop loading current page
    func stopLoading() {
        realWebView.stopLoading()
    }
    
    /// Check if WebView is currently loading
    /// - Returns: true if loading
    func isLoading() -> Bool {
        realWebView.isLoading
    }
    
    /// Reload current page
    func reload() {
        realWebView.reload()
    }
    
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch keyPath {
        case "estimatedProgress":
            if let progress = change[.newKey] as? Double {
                estimatedProgress = Float(progress)
                self.delegate?.webView(self, didChange: estimatedProgress)
            }
        case "title":
            if let newTitle = change[.newKey] as? String {
                title = newTitle
                self.delegate?.webView(self, didChange: title)
            }
        case "URL":
            url = change[.newKey] as? URL
            if let url {
                self.delegate?.webView(self, didChange: url)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - GHWebViewContainer+Load

public extension GHWebViewContainer {
    /// Load URL string
    /// - Parameter urlString: URL string to load
    func loadURLString(_ urlString: String) {
        let trimmedString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var url = URL(string: trimmedString)
        
        // Fix for unencoded URLs
        if url == nil {
            if let data = trimmedString.data(using: .utf8) {
                url = URL(dataRepresentation: data, relativeTo: nil)
            }
        }
        
        guard let validURL = url,
              let scheme = validURL.scheme,
              scheme.hasPrefix("http") else {
            return
        }
        
        loadURL(validURL)
    }
    
    /// Load URL
    /// - Parameter url: URL to load
    func loadURL(_ url: URL) {
        loadRequest(URLRequest(url: url))
    }
    
    /// Load URL request
    /// - Parameter request: URL request to load
    func loadRequest(_ request: URLRequest) {
        realWebView.load(request)
    }
    
    /// Load file URL
    /// - Parameters:
    ///   - url: File URL to load
    ///   - readAccessURL: URL for read access security
    func loadFileURL(_ url: URL, allowingReadAccessTo readAccessURL: URL) {
        realWebView.loadFileURL(url, allowingReadAccessTo: readAccessURL)
    }
    
    /// Load HTML string
    /// - Parameters:
    ///   - htmlString: HTML content to load
    ///   - baseURL: Base URL for relative resources
    func loadHTMLString(_ htmlString: String, baseURL: URL?) {
        realWebView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}

// MARK: - GHWebViewContainer+Event

public extension GHWebViewContainer {
    /// Dispatch event to H5 with parameters
    /// - Parameters:
    ///   - eventName: Event name
    ///   - params: Event parameters
    func dispatchNotifyEvent(_ eventName: String, params: [String: Any]?, completionHandler: (@MainActor (Any?, (any Error)?) -> Void)? = nil) {
        jsBridgeManager?.dispatchNotifyEvent(eventName, params: params, completionHandler: completionHandler)
    }
}

// MARK: - GHWebViewContainer+JSBridge

public extension GHWebViewContainer {
    /// Register JavaScript message handlers
    /// - Parameter messageHandlers: Array of message handler names
    func registerMessageHandlers(_ messageHandlers: [String]) {
        jsBridgeManager?.addScriptMessageHandlers(messageHandlers)
    }
    
    /// Register default plugin
    /// - Parameter defaultPlugin: Default plugin instance
    func registerDefaultPlugin(_ defaultPlugin: GHBridgeBasePluginProtocol) {
        jsBridgeManager?.registerDefaultPlugin(defaultPlugin)
    }
    
    /// Register plugin
    /// - Parameter plugin: plugin instance
    func registerPlugin(_ plugin: GHBridgeBasePluginProtocol) {
        jsBridgeManager?.registerPlugin(plugin)
    }
    
    /// Register plugins
    /// - Parameter plugins: plugin instances
    func registerPlugins(_ plugins: [GHBridgeBasePluginProtocol]) {
        plugins.forEach { plugin in
            jsBridgeManager?.registerPlugin(plugin)
        }
    }
}

// MARK: - WKNavigationDelegate

extension GHWebViewContainer: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        delegate?.webView(self, beforeDecidePolicyFor: navigationAction)
        
        if let delegate = delegate {
            delegate.webView(self, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
        
        delegate?.webView(self, afterDecidePolicyFor: navigationAction)
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let delegate = delegate {
            delegate.webView(self, decidePolicyFor: navigationResponse, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        jsBridgeManager?.resetJSContext()
        delegate?.webView(self, didStartProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webView(self, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(self, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        delegate?.webView(self, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webView(self, didFinish: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(self, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if let delegate = delegate {
            delegate.webView(self, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if let delegate = delegate {
            delegate.webViewWebContentProcessDidTerminate(self)
        } else {
            webView.reload()
        }
    }
}

// MARK: - UIDelegate

extension GHWebViewContainer: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor () -> Void) {

    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void) {

    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (String?) -> Void) {
        completionHandler("Client Not handler")
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let delegate = delegate {
            return delegate.webView(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
        } else {
            return nil
        }
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        delegate?.webViewDidClose(self)
    }
}

// MARK: - UIScrollViewDelegate

extension GHWebViewContainer: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        nil
    }
}
