//
//  WebViewDelegate.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

import WebKit

/// Delegate protocol for GHWebViewContainer
public protocol GHWebViewDelegate: NSObjectProtocol {
    // MARK: - Decide Policy
    
    func webView(_ webView: GHWebViewContainer,
                 beforeDecidePolicyFor navigationAction: WKNavigationAction)
    
    func webView(_ webView: GHWebViewContainer,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    
    func webView(_ webView: GHWebViewContainer,
                 afterDecidePolicyFor navigationAction: WKNavigationAction)
    
    func webView(_ webView: GHWebViewContainer,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
    
    // MARK: - Navigation
    
    func webView(_ webView: GHWebViewContainer,
                 didStartProvisionalNavigation navigation: WKNavigation)
    
    func webView(_ webView: GHWebViewContainer,
                 didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation)
    
    func webView(_ webView: GHWebViewContainer,
                 didFailProvisionalNavigation navigation: WKNavigation,
                 withError error: Error)
    
    func webView(_ webView: GHWebViewContainer,
                 didCommit navigation: WKNavigation)
    
    func webView(_ webView: GHWebViewContainer,
                 didFinish navigation: WKNavigation)
    
    func webView(_ webView: GHWebViewContainer,
                 didFail navigation: WKNavigation, withError error: Error)
    
    // MARK: - Other
    
    func webView(_ GHWebViewContainer: GHWebViewContainer,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    
    func webViewWebContentProcessDidTerminate(_ webView: GHWebViewContainer)
    
    /// JS window.close
    func webViewDidClose(_ webView: GHWebViewContainer)
    
    func webView(_ webView: GHWebViewContainer, didChange estimatedProgress: Float)
    func webView(_ webView: GHWebViewContainer, didChange title: String)
    func webView(_ webView: GHWebViewContainer, didChange url: URL)
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
}

// 将所有方法设置为可选实现
public extension GHWebViewDelegate {
    func webView(_ webView: GHWebViewContainer,
                 beforeDecidePolicyFor navigationAction: WKNavigationAction) {
        // 导航前处理
    }
    
    func webView(_ webView: GHWebViewContainer,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: GHWebViewContainer,
                 afterDecidePolicyFor navigationAction: WKNavigationAction) {
        // 导航后处理
    }
    
    func webView(_ webView: GHWebViewContainer,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: GHWebViewContainer,
                 didStartProvisionalNavigation navigation: WKNavigation) { }
    
    func webView(_ webView: GHWebViewContainer,
                 didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) { }
    
    func webView(_ webView: GHWebViewContainer,
                 didFailProvisionalNavigation navigation: WKNavigation,
                 withError error: Error) { }
    
    func webView(_ webView: GHWebViewContainer,
                 didCommit navigation: WKNavigation) { }
    
    func webView(_ webView: GHWebViewContainer,
                 didFinish navigation: WKNavigation) { }
    
    func webView(_ webView: GHWebViewContainer,
                 didFail navigation: WKNavigation, withError error: Error) { }
    
    func webView(_ GHWebViewContainer: GHWebViewContainer,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: GHWebViewContainer) { }
    
    func webViewDidClose(_ webView: GHHybrid.GHWebViewContainer) { }
    
    func webView(_ webView: GHHybrid.GHWebViewContainer, didChange title: String) { }
    
    func webView(_ webView: GHHybrid.GHWebViewContainer, didChange url: URL) { }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
}
