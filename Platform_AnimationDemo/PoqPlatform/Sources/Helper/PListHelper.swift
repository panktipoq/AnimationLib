//
//  PListHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 27/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

open class PListHelper: BasePListHelper {
    
    public static let sharedInstance: PListHelper = PListHelper()

    fileprivate let appIdKey = "Poq_App_ID"
    fileprivate let apiUrlKey = "Poq_Api_URL"
    fileprivate let appIsPreviewKey = "Poq_Is_Preview"
    fileprivate let appApiVersion = "Poq_Api_Version"
    fileprivate let appURLSchemeKey = "Poq_App_URL_Scheme"
    fileprivate let versionNumber = "CFBundleShortVersionString"
    fileprivate let apiKey = "Poq_Api_Key"
    fileprivate let paymentProvidersMapKey = "Poq_Payment_Providers"

    /** Read plist dictionary */
    override open func read() -> Dictionary<String, AnyObject> {
        
        var plistContent: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            
            if let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                
                if let appIdString: String = dictionary[appIdKey] as? String{
                    plistContent[appIdKey] = appIdString as AnyObject?
                }

                plistContent[apiUrlKey] = dictionary[apiUrlKey]
                plistContent[appIsPreviewKey] = dictionary[appIsPreviewKey]
                plistContent[appURLSchemeKey] = dictionary[appURLSchemeKey]
                plistContent[versionNumber] = dictionary[versionNumber]
                plistContent[appApiVersion] = dictionary[appApiVersion]
                
                plistContent[apiKey] = dictionary[apiKey]
                plistContent[paymentProvidersMapKey] = dictionary[paymentProvidersMapKey]
            }
        }

        return plistContent
    }
    
    
    /** Expose app id from plist */
    open func getAppID() -> String? {
        return plistDictionary[appIdKey] as? String
    }
    
    /** Expose api url from plist */
    open func getApiURL() -> String {
        return plistDictionary[apiUrlKey] as! String
    }
    
    /** Expose if app is a preview version from plist */
    open func getIsPreview() -> Bool {
        return plistDictionary[appIsPreviewKey] as! Bool
    }
    /** Expose if app is a preview version from plist */
    open func getURLScheme() -> String {
        return plistDictionary[appURLSchemeKey] as! String
    }

    open func getAppVersionNumber() -> String {
        
        return plistDictionary[versionNumber] as! String
    }

    open func getAppKey() -> String? {
        return plistDictionary[apiKey] as? String
    }

    /// If some payment method doesn't presented in map - unavailable for current app
    /// If map is nil - no available payment options, probably app should be used with cart transfer screen
    open func paymentProviderMap() -> [String: String]? {
        return plistDictionary[paymentProvidersMapKey] as? [String: String]
    }
    
    open func getApiVersion() -> String? {
        return plistDictionary[appApiVersion] as? String

    }
    
}
