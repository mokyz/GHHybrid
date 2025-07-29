//
//  GHBridgePluginUtils.swift
//  GHHybrid
//
//  Created by zzh on 2025/5/23.
//

// MARK: - GHBridgePluginUtils

/// Utility class for GHBridge plugin operations
public class GHBridgePluginUtils: NSObject {
    
    
}

// MARK: - Validation Methods

extension GHBridgePluginUtils {
    /// Validate if string is valid
    /// - Parameter str: String to validate
    /// - Returns: true if string is valid
    public static func validateString(_ str: String?) -> Bool {
        guard let str = str, !str.isEmpty else { return false }
        return true
    }
    
    /// Validate if dictionary is valid
    /// - Parameter dict: Dictionary to validate
    /// - Returns: true if dictionary is valid
    public static func validateDictionary(_ dict: [AnyHashable: Any]?) -> Bool {
        guard let dict = dict, !dict.isEmpty else { return false }
        return true
    }
    
    /// Validate if array is valid
    /// - Parameter array: Array to validate
    /// - Returns: true if array is valid
    public static func validateArray(_ array: [Any]?) -> Bool {
        guard let array = array, !array.isEmpty else { return false }
        return true
    }
}

// MARK: - JSON Conversion Methods

extension GHBridgePluginUtils {
    /// Convert JSON string to dictionary
    /// - Parameter jsonString: JSON string to convert
    /// - Returns: Dictionary representation or nil if conversion fails
    public static func jsonStringToDictionary(_ jsonString: String?) -> [String: Any]? {
        guard validateString(jsonString),
              let jsonString = jsonString,
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return dictionary as? [String: Any]
        } catch {
            return nil
        }
    }
    
    /// Serialize message to JSON string with proper escaping
    /// - Parameter message: Message object to serialize
    /// - Returns: Serialized and escaped JSON string or nil if serialization fails
    public static func serializeMessage(_ message: Any?, prettyPrint: Bool = true) -> String? {
        guard let message = message,
              JSONSerialization.isValidJSONObject(message) else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: prettyPrint ? [.prettyPrinted] : [])
            guard let messageJSON = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            // Escape special characters for JavaScript
//            messageJSON = messageJSON.replacingOccurrences(of: "\\", with: "\\\\")
//            messageJSON = messageJSON.replacingOccurrences(of: "\"", with: "\\\"")
//            messageJSON = messageJSON.replacingOccurrences(of: "'", with: "\\'")
//            messageJSON = messageJSON.replacingOccurrences(of: "\n", with: "\\n")
//            messageJSON = messageJSON.replacingOccurrences(of: "\r", with: "\\r")
//            messageJSON = messageJSON.replacingOccurrences(of: "\u{000C}", with: "\\f") // \f
//            messageJSON = messageJSON.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
//            messageJSON = messageJSON.replacingOccurrences(of: "\u{2029}", with: "\\u2029")
            
            return messageJSON
        } catch {
            return nil
        }
    }
}
