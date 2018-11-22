//
//  AutomationTestsHelper.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 08/08/2016.
//
//

import Foundation
import Locksmith
//import PoqNetworking
//import PoqUtilities


// while we parsinf, we checking next keys
// if value should be removed - put KeychainItemToBeremovedValue
public let UsernameKey = "username" /// reming user name do not lead to removing password
public let PasswordKey = "password"

public let KeychainItemToBeremovedValue: String = "{__TO__BE__REMOVED__}"

private let BaseURLEnvironmentKey: String = "BASE_URL"
private let KeyChainEnvironmentKey: String = "KEY_CHAIN_INFO" // key will be a username, value or [String: AnyObject] or KeychainItemToBeremovedValue
private let UserDefaultsEnvironmentKey: String = "USER_DEFAULTS_INFO"

private let isRunningTestEnvironmentKey: String = "IS_TESTING"
private let isRunningUITestEnvironmentKey: String = "IS_UI_TESTING"

/// Collection of methods, which should be used across the app for stub specific functionalities
public final class AutomationTestsUtilities {
    
    /// Return true if the environment has the IS_TESTING variable set meaning that we are testing.
    public static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment[isRunningTestEnvironmentKey] != nil
    }
    
    /// Return true if the environment has the IS_UI_TESTING variable set.
    /// The only case when we really need to open the whole app, since we can't mock anything.
    /// - important: This should be set when the app is launched by tests and is not part of the tests.
    public static var isRunningUITests: Bool {
        return ProcessInfo.processInfo.environment[isRunningUITestEnvironmentKey] != nil
    }

    /// We have quit limited chanels to communicate
    /// From UI test we set key-value info to NSProcessInfo.processInfo().environment
    /// Here we will parse all known info, for example base api url, keychain info
    public static func decodeProcessInfo() {
        
        var environment: [String : String] = ProcessInfo.processInfo.environment
        
        // keychain values
        if let keyValueJson: String = environment[KeyChainEnvironmentKey], let validJSonData: Data = keyValueJson.data(using: String.Encoding.utf8) {
            var keyValues: [String: AnyObject]?
            do {
                let jsonObject: Any = try JSONSerialization.jsonObject(with: validJSonData, options: [])
                keyValues = jsonObject as? [String: AnyObject]
            } catch {
                
            }

            if let validKeyValues: [String: AnyObject] = keyValues {
                for (key, value): (String, AnyObject) in validKeyValues {
                    print("Keychain:: set \"\(value)\" for \(key)")
                    guard let existedValue: [String: AnyObject] = value as? [String: AnyObject] else {
                        Log.error("we parsing keychain info and object for key - \(key) is not kind of [String: AnyObject]")
                        continue
                    }
                    do {
                        try Locksmith.saveData(data: existedValue, forUserAccount: key)
                    } catch {
                        
                    }
                }
                
            } else {
                Log.error("We found string for key KeyChainEnvironmentKey(\(KeyChainEnvironmentKey)), but it can't be pased as json")
            }
        }
        
        // user defaults
        if let keyValueJson: String = environment[UserDefaultsEnvironmentKey], let validJSonData: Data = keyValueJson.data(using: String.Encoding.utf8) {
            var keyValues: [String: AnyObject]?
            do {
                let jsonObject: Any = try JSONSerialization.jsonObject(with: validJSonData, options: [])
                keyValues = jsonObject as? [String: AnyObject]
            } catch {
                
            }
            
            if let validKeyValues: [String: AnyObject] = keyValues {
                for (key, value): (String, AnyObject) in validKeyValues {
                    print("NSUserDefaults:: set \"\(value)\" for \(key)")
                    UserDefaults.standard.set(value, forKey: key)
                }
            }
            
            UserDefaults.standard.synchronize()
        }
        
    }
    
    /// Parse process and environment search for url varaible
    public static func parseEndpointUrlStirng() -> String? {
        var environment: [String : String] = ProcessInfo.processInfo.environment
        
        // base url
        if let baseUrl: String = environment[BaseURLEnvironmentKey], !baseUrl.isEmpty {
            return baseUrl 
        }
        
        return nil
    }
    
}

