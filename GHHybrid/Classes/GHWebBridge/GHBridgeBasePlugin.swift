//
//  GHBridgeBasePlugin.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

public protocol GHBridgeBasePluginProtocol: NSObjectProtocol {
    
    func pluginName() -> String
    
    @discardableResult func execute(keyName: String, optParams: [String: Any], callback: GHBridgeCallback) -> Bool
}

public extension GHBridgeBasePluginProtocol {
    func pluginName() -> String {
        NSStringFromClass(type(of: self))
    }
}
