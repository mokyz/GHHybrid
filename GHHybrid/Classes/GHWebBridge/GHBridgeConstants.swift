//
//  GHBridgeConstants.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

/// Bridge callback name key
let kGHBridgeCallbackName = "callBack"

/// Bridge keyName key
let kGHBridgeKeyName = "keyName"

/// Bridge optParams key
let kGHBridgeOptParams = "optParams"

/// Bridge result key
let kGHBridgeResult = "result"

/// Bridge data key
let kGHBridgeData = "data"

/// Bridge event name
let kGHBridgeEventName = "eventName"

/// Callback Method name
let kGHBridgeMethodCallback = "onCallBack"

/// Notify Method name
let kGHBridgeMethodNotify = "notifyFromApp"

/// Bridge plugin key
let kGHBridgePlugin = "plugin"

/// Default Bridge plugin key
let kGHBridgeDefaultPlugin = "GHBridgeDefaultPlugin"






/// XWebView Message Inject
let kInjectJS = ";(function(){if(window.XWebView===undefined){window.XWebView={};window.XWebView.callNative=function(module,method,params,callbackName,callbackId){window.webkit.messageHandlers.XWebView.postMessage({'plugin':module,'method':method,'params':params,'callbackName':callbackName,'callbackId':callbackId})};window.XWebView._callNative=function(jsonstring){window.webkit.messageHandlers.XWebView.postMessage(jsonstring)}}})();"

/// Bridge Inner Method
let kGHBridgeInnerMethod_HandleRequest = "window.GHBridge && window.GHBridge._handleRequestFromNative && window.GHBridge._handleRequestFromNative"

let kGHBridgeInnerMethod_HandleResponse = "window.GHBridge && window.GHBridge._handleResponseFromNative && window.GHBridge._handleResponseFromNative"
