//
//  GHBridgeMessageHandler.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

import WebKit
import B_BC_Log

/// Internal protocol for bridge communication
protocol GHBridgeInnerProtocol: AnyObject {
    func jsbridgeInit()
    func jsbridgeResponse(callbackId: String, params: [String: Any], error: Error?)
}


// MARK: - GHBridgeMessageHandler

/// Internal message handler for processing JavaScript messages
class GHBridgeMessageHandler: NSObject {
    
    var bridgePlugins: [GHBridgeBasePluginProtocol] = []
    var defaultPlugin: GHBridgeBasePluginProtocol?
    
    weak var bridgeDelegate: WKScriptMessageHandler?
    weak var bridgeInnerDelegate: GHBridgeInnerProtocol?
    
    private weak var userContentController: WKUserContentController?
}

// MARK: - Private Methods

private extension GHBridgeMessageHandler {
    func invokeJSMethod(with message: WKScriptMessage) {
        var body: [String: Any]
        
        // Verify body
        if let bodyDict = message.body as? [String: Any] {
            body = bodyDict
        } else if let bodyString = message.body as? String,
                  let parsedBody = GHBridgePluginUtils.jsonStringToDictionary(bodyString) {
            body = parsedBody
        } else {
            // Fallback to delegate if body format is not recognized
            if let delegate = bridgeDelegate {
                delegate.userContentController(userContentController!, didReceive: message)
            }
            return
        }
        
        // Verify keyName
        guard let keyName = body[kGHBridgeKeyName] as? String,
              GHBridgePluginUtils.validateString(keyName) else {
            // Fallback to delegate if no valid keyName
            if let delegate = bridgeDelegate {
                delegate.userContentController(userContentController!, didReceive: message)
            }
            return
        }
        
        Logger.debug("【Web】didReceive js message: \(keyName), body: \(body)")
        invokeJSMethod(with: body, message: message)
    }
    
    private func invokeJSMethod(with body: [String: Any], message: WKScriptMessage) {
        let keyName = body[kGHBridgeKeyName] as? String ?? ""
        
        var params: [String: Any] = [:]
        if let paramsDict = body[kGHBridgeOptParams] as? [String: Any] {
            params = paramsDict
        } else if let paramsString = body[kGHBridgeOptParams] as? String,
                  let parsedParams = GHBridgePluginUtils.jsonStringToDictionary(paramsString) {
            params = parsedParams
        }
        
        let callback = GHBridgeCallback.callback()
        callback.message = message
        
        var isInvoked = false
        for plugin in bridgePlugins {
            isInvoked = plugin.execute(keyName: keyName, optParams: params, callback: callback)
            if isInvoked {
                break
            }
        }
        
        if !isInvoked {
            defaultPlugin?.execute(keyName: keyName, optParams: params, callback: callback)
        }
    }
}

// MARK: - WKScriptMessageHandler

extension GHBridgeMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.userContentController = userContentController
        
        if Thread.isMainThread {
            invokeJSMethod(with: message)
        } else {
            DispatchQueue.main.async {
                self.invokeJSMethod(with: message)
            }
        }
    }
}
