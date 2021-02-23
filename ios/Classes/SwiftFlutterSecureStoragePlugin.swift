import Flutter
import UIKit
import Valet

public class SwiftFlutterSecureStoragePlugin: NSObject, FlutterPlugin {
    // The default identifier (sandbox name) to store. This can be overridden by providing
    // a groupId in each call to read/write data.
    let defaultIdentifier = "secure_storage"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.it_nomads.com/flutter_secure_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSecureStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "write": write(call, result)
        case "read": read(call, result)
        case "readAll": readAll(call, result)
        case "deleteAll": deleteAll(call, result)
        case "delete": delete(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func write(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String : String?],
            let key = arguments["key"] as? String,
            let value = arguments["value"] as? String,
            let options = arguments["options"] as? [String: String?]?
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(options)
        try? valet.setString(value, forKey: key)
        result(nil)
    }
    
    // Delete a key from the valet
    private func delete(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String : String?],
            let key = arguments["key"] as? String,
            let options = arguments["options"] as? [String: String?]?
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        let valet = getValetInstance(options)
        try? valet.removeObject(forKey: key)
        result(nil)
    }
    
    // Read a value from the valet
    private func read(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String : String?],
            let key = arguments["key"] as? String,
            let options = arguments["options"] as? [String: String?]?
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(options)
        let value = try? valet.string(forKey: key)
        result(value)
    }
    
    private func readAll(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String : String?],
            let options = arguments["options"] as? [String: String?]?
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(options)
        let keys = try? valet.allKeys()
        var returnDict = [String:String]()
        
        for key in keys ?? [] {
            let val = try? valet.string(forKey: key)
            if (val != nil) {
                returnDict[key] = val
            }
        }
        
        result(returnDict)
    }
    
    private func deleteAll(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String : String?],
            let options = arguments["options"] as? [String: String?]?
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(options)
        try? valet.removeAllObjects()
        result(nil)
    }
    
    private func getValetInstance(_ options: [String:String?]?) -> Valet {
        // Accessibility setting
        let accessibility = getAccessibilityEnumFromString(val: options?["accessibility"] ?? nil)
        
        // Valet instance
        return Valet.valet(with: Identifier(nonEmpty: options?["groupId"] ?? defaultIdentifier)!, accessibility: accessibility)
    }
    
    
    // Convert accessibility setting to enum
    private func getAccessibilityEnumFromString(val: String?) -> Accessibility {
        switch val {
        case "passcode":
            return .whenPasscodeSetThisDeviceOnly
            
        case "unlocked":
            return .whenUnlocked
            
        case "unlocked_this_device":
            return .whenUnlockedThisDeviceOnly
            
        case "first_unlock":
            return .afterFirstUnlock
            
        case "first_unlock_this_device":
            return .afterFirstUnlockThisDeviceOnly
            
        default:
            return .whenUnlocked
        }
    }
}



