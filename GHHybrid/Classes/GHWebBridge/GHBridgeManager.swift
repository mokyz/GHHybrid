//
//  GHBridgeManager.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

import WebKit
import B_BC_Log

// MARK: - GHBridgeManager

/// An object to manage JavaScript bridge communication
public class GHBridgeManager: NSObject {
    // MARK: - Public Properties
    
    /// You may have the same bridge with WKScriptMessageHandler. Just set your bridge instance here.
    public weak var bridgeDelegate: WKScriptMessageHandler? {
        didSet {
            messageHandler.bridgeDelegate = bridgeDelegate
        }
    }
    
    // MARK: - Private Properties
    
    private weak var webView: WKWebView?
    private var bridgeHandlers: [String] = ["XWebView"]
    private let messageHandler = GHBridgeMessageHandler()
    
    private var nativeCallbackMap: [String: (Any?, Error?) -> Void] = [:]
    private var nativeProgressMap: [String: (Any?) -> Void] = [:]
    private var nativeCallJSQueue: [[String: Any]] = []
    private var callbackId: Int = 0
    private var jsInitialized = false
    
    // MARK: - Initialization
    
    /// Return a manager for the given WebView
    /// - Parameter webView: WKWebView instance only, or will return nil
    /// - Returns: GHBridgeManager instance or nil
    /// Important: GHBridgeManager ----> weak ----> webView, so you must keep it strong in other instance
    public static func bridge(for webView: WKWebView?) -> GHBridgeManager? {
        guard let webView = webView else { return nil }
        return GHBridgeManager(webView: webView)
    }
    
    private init(webView: WKWebView) {
        super.init()
        self.webView = webView
        initializeJSBridge()
    }
    
    deinit {
        removeAllScripts()
        unregisterScriptMessageHandler()
    }
}

// MARK: - Public Methods

public extension GHBridgeManager {
    /// Add custom message handlers
    /// - Parameter messageHandlers: Array of message handler names
    func addScriptMessageHandlers(_ messageHandlers: [String]) {
        for handlerName in messageHandlers {
            if !bridgeHandlers.contains(handlerName) {
                bridgeHandlers.append(handlerName)
            }
        }
        registerMessageHandlers()
    }
    
    /// Remove all message handlers (not required, called automatically on deinit)
    func unregisterScriptMessageHandler() {
        for moduleName in bridgeHandlers {
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: moduleName)
        }
    }
    
    /// Add user script
    /// - Parameters:
    ///   - userScript: JavaScript code to inject
    ///   - injectTime: When to inject the script
    ///   - forMainFrameOnly: Whether to inject only in main frame
    func addUserScript(_ userScript: String,
                       injectTime: WKUserScriptInjectionTime,
                       forMainFrameOnly: Bool) {
        let script = WKUserScript(source: userScript,
                                  injectionTime: injectTime,
                                  forMainFrameOnly: forMainFrameOnly)
        webView?.configuration.userContentController.addUserScript(script)
    }
}

// MARK: - Private Methods

private extension GHBridgeManager {
    func initializeJSBridge() {
        registerMessageHandlers()
        addUserScript(kInjectJS,
                      injectTime: .atDocumentStart,
                      forMainFrameOnly: false)
    }
    
    func registerMessageHandlers() {
        unregisterScriptMessageHandler()
        
        for moduleName in bridgeHandlers {
            webView?.configuration.userContentController.add(messageHandler, name: moduleName)
        }
    }
    
    func removeAllScripts() {
        webView?.configuration.userContentController.removeAllUserScripts()
    }
}

// MARK: - GHBridgeManager Register Extension

extension GHBridgeManager {
    
    /// Reset JavaScript context (call when page changes)
    public func resetJSContext() {
        jsInitialized = false
        nativeCallbackMap.removeAll()
        nativeProgressMap.removeAll()
    }
    
    /// Register default JavaScript plugin
    /// - Parameter defaultPlugin: Default plugin instance
    public func registerDefaultPlugin(_ defaultPlugin: GHBridgeBasePluginProtocol) {
        messageHandler.defaultPlugin = defaultPlugin
    }
    
    /// Register JavaScript plugin
    /// - Parameter plugin: Default plugin instance
    public func registerPlugin(_ plugin: GHBridgeBasePluginProtocol) {
        let pluginNames = messageHandler.bridgePlugins.map {
            $0.pluginName()
        }
        
        guard !pluginNames.contains(plugin.pluginName()) else { return }
        
        messageHandler.bridgePlugins.append(plugin)
    }
}

// MARK: - GHBridgeManager Event Extension

extension GHBridgeManager {
    /// Dispatch app or webview event to H5 with parameters
    /// - Parameters:
    ///   - eventName: Event name
    ///   - params: Event parameters
    ///   - completionHandler: completion block (Any?, Error?)
    public func dispatchNotifyEvent(_ eventName: String, params: [String: Any]? = nil, completionHandler: (@MainActor (Any?, (any Error)?) -> Void)? = nil) {
        
        let notifyParams: [String : Any] = [
            kGHBridgeEventName: eventName,
            kGHBridgeData: params ?? [:]
        ]
        
        guard let serializedMessage = GHBridgePluginUtils.serializeMessage(notifyParams) else { return }
        
        let eventJS = "\(kGHBridgeMethodNotify)(\(serializedMessage))"
        dispatchEvent(eventJS, completionHandler: completionHandler)
    }
    
    /// Dispatch app or webview event to H5 with JavaScriptString
    /// - Parameters:
    ///   - eventName: Event name
    ///   - javaScriptString: javaScriptString contains eventName and parameters
    ///   - completionHandler: completion block (Any?, Error?)
    public func dispatchEvent(_ javaScriptString: String, completionHandler: (@MainActor (Any?, (any Error)?) -> Void)? = nil) {
        webView?.evaluateJavaScript(javaScriptString) { results, error in
            completionHandler?(results, error)
            if let error = error {
                Logger.debug("【Web】Notify JS executed failed! \nError: \(error.localizedDescription) \n\(javaScriptString)")
            } else {
                Logger.debug("【Web】Notify JS executed successfully! \n\(javaScriptString)")
            }
        }
    }
}
