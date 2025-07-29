//
//  GHBridgeCallback.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

import WebKit
import B_BC_Log

/// Callback with parameters
public typealias Callback = ([String: Any]?) -> Void

// MARK: - GHBridgeCallback

/// Callback context for bridge operations
/// If successful, return results; otherwise return an error
public class GHBridgeCallback: NSObject {
    // MARK: - Public Properties
    
    /// The original script message from WebKit
    public var message: WKScriptMessage? {
        didSet {
            setupCallbacks()
        }
    }
    
    /// Success callback block
    public private(set) var onCallback: Callback = { _ in }
    
    /// Returns the web view controller
    public var webViewController: UIViewController? {
        guard let webView = webView else { return nil }
        
        var responder: UIResponder? = webView
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
    
    // MARK: - Private Properties
    
    private weak var webView: WKWebView?
    
    // MARK: - Initialization
    
    /// Create a new callback instance
    /// - Returns: A new GHBridgeCallback instance
    public static func callback() -> GHBridgeCallback {
        return GHBridgeCallback()
    }
}

// MARK: - Private Methods

private extension GHBridgeCallback {
    /// Setup callback closures when message is set
    private func setupCallbacks() {
        guard let message = message else { return }
        
        webView = message.webView
        
        onCallback = { [weak self] params in
            self?.flushMessage(withParams: params)
        }
    }
    
    /// Flush message with parameters and progress
    /// - Parameters:
    ///   - data: Data to send back
    ///   - progress: Progress value (-1.0 means no progress)
    private func flushMessage(withParams data: [String: Any]?) {
        guard let message = message else { return }
        
        var body: [String: Any]
        
        if let bodyDict = message.body as? [String: Any] {
            body = bodyDict
        } else if let bodyString = message.body as? String,
                  let parsedBody = GHBridgePluginUtils.jsonStringToDictionary(bodyString) {
            body = parsedBody
        } else {
            return
        }
        
        guard let callbackName = body[kGHBridgeCallbackName] as? String else { return }
        
        let callbackParams: [String : Any] = [
            kGHBridgeCallbackName: callbackName,
            kGHBridgeResult: data ?? [:]
        ]
        
        flushData(callbackParams, callbackName: callbackName)
    }
    
    /// Flush data to JavaScript
    /// - Parameters:
    ///   - callbackParams: Parameters to send
    ///   - callbackName: JavaScript callback function name
    private func flushData(_ callbackParams: [String: Any], callbackName: String) {
        guard JSONSerialization.isValidJSONObject(callbackParams) else {
            return
        }
        
        guard let serializedMessage = GHBridgePluginUtils.serializeMessage(callbackParams) else { return }
        
        let callbackString = "\(kGHBridgeMethodCallback)(\(serializedMessage))"
        flushMessage(callbackString)
    }
    
    /// Execute JavaScript in the web view
    /// - Parameter message: JavaScript code to execute
    private func flushMessage(_ message: String) {
        guard let webView = webView else { return }
        
        DispatchQueue.main.async {
            webView.evaluateJavaScript(message) { results, error in
                if let error = error {
                    Logger.debug("【Web】Callback JS executed failed! \nError: \(error.localizedDescription) \n\(message)")
                } else {
                    Logger.debug("【Web】Callback JS executed successfully! \n\(message)")
                }
            }
        }
    }
}
