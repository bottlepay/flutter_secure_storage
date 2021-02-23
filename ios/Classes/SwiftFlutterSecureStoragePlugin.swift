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
        case "migrate": migrate(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func write(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String:Any?],
            let key = arguments["key"] as? String,
            let value = arguments["value"] as? String
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(arguments["options"] as? [String:String])
        try? valet.setString(value, forKey: key)
        result(nil)
    }
    
    // Delete a key from the valet
    private func delete(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String:Any?],
            let key = arguments["key"] as? String
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(arguments["options"] as? [String:String])
        try? valet.removeObject(forKey: key)
        result(nil)
    }
    
    // Read a value from the valet
    private func read(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String:Any?],
            let key = arguments["key"] as? String
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(arguments["options"] as? [String:String])
        let value = try? valet.string(forKey: key)
        result(value)
    }
    
    private func readAll(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard
            let arguments = call.arguments as? [String:Any?]
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(arguments["options"] as? [String:String])
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
            let arguments = call.arguments as? [String:Any?]
        else {
            result(FlutterError(code: "InvalidArgument",
                                message: "Must provide arguments",
                                details: nil))
            return
        }
        
        let valet = getValetInstance(arguments["options"] as? [String:String])
        try? valet.removeAllObjects()
        result(nil)
    }
    
    // This will migrate data from keychain to valet. You should call this for each of your
    // groupIds and accessibility options used to make sure you migrate everything.
    private func migrate(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any?]
        let options = arguments?["options"] as? [String:String]
        
        // kSecAttr* options we will migrate using
        var optionsDict = [String:AnyHashable]()
        
        // Base options from flutter_secure_storage
        optionsDict[kSecClass as String] = kSecClassGenericPassword
        optionsDict[kSecAttrService as String] = "flutter_secure_storage_service"
        optionsDict[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        // Add options if specified
        if (options != nil) {
            if (options?["groupId"] != nil) {
                optionsDict[kSecAttrAccessGroup as String] = options?["groupId"]!
            }
            
            if (options?["accessibility"] != nil) {
                optionsDict[kSecAttrAccessible as String] = accessibilityStringToIosEnum(val: options?["accessibility"])
                
            }
        }
        
        let valet = getValetInstance(options)
        try? valet.migrateObjects(matching: optionsDict, removeOnCompletion: true)
        result(nil)
    }
    
    private func getValetInstance(_ options: [String:String?]?) -> Valet {
        // Accessibility setting
        let accessibility = accessibilityStringToValetEnum(val: options?["accessibility"] ?? nil)
        
        // Valet instance
        return Valet.valet(with: Identifier(nonEmpty: options?["groupId"] ?? defaultIdentifier)!, accessibility: accessibility)
    }
    
    
    // Convert accessibility setting string to vault enum
    private func accessibilityStringToValetEnum(val: String?) -> Accessibility {
        switch val {
        case "passcode":
            return .whenPasscodeSetThisDeviceOnly
            
        case "unlocked_this_device":
            return .whenUnlockedThisDeviceOnly
            
        case "first_unlock":
            return .afterFirstUnlock
            
        case "first_unlock_this_device":
            return .afterFirstUnlockThisDeviceOnly
            
        case "unlocked":
            fallthrough
        default:
            return .whenUnlocked
        }
    }
    
    // Convert accessibility setting string to iOS enum
    private func accessibilityStringToIosEnum(val: String?) -> CFString {
        switch val {
        case "passcode":
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            
        case "unlocked_this_device":
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            
        case "first_unlock":
            return kSecAttrAccessibleAfterFirstUnlock
            
        case "first_unlock_this_device":
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            
        case "unlocked":
            fallthrough
        default:
            return kSecAttrAccessibleWhenUnlocked
        }
    }
}



