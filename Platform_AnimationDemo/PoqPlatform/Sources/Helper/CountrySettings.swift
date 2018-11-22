//
//  CountrySettings.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 17/08/2017.
//
//

import Foundation

public class CountrySettings: NSObject, NSCoding {
    
    public var isoCode: String
    public var appId: String
    public var apiUrl: String?
    public var facebookAppId: String?
    public var facebookAppDisplayName: String?
    
    init(isoCode: String, appId: String, apiUrl: String? = nil, facebookAppId: String? = nil, facebookAppDisplayName: String? = nil) {
        self.isoCode = isoCode
        self.appId = appId
        self.apiUrl = apiUrl
        self.facebookAppId = facebookAppId
        self.facebookAppDisplayName = facebookAppDisplayName
    }
    
    required convenience public init?(coder decoder: NSCoder) {
        guard let isoCode = decoder.decodeObject(forKey: "isoCode") as? String,
            let appId = decoder.decodeObject(forKey: "appId") as? String
            else {
                return nil
        }
        let apiUrl = decoder.decodeObject(forKey: "apiUrl") as? String
        let facebookAppId = decoder.decodeObject(forKey: "facebookAppID") as? String
        let facebookAppDisplayName = decoder.decodeObject(forKey: "facebookAppDisplayName") as? String
        
        self.init(isoCode: isoCode, appId: appId, apiUrl: apiUrl, facebookAppId: facebookAppId, facebookAppDisplayName: facebookAppDisplayName)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.isoCode, forKey: "isoCode")
        aCoder.encode(self.appId, forKey: "appId")
        aCoder.encode(self.apiUrl, forKey: "apiUrl")
        aCoder.encode(self.facebookAppId, forKey: "facebookAppID")
        aCoder.encode(self.facebookAppDisplayName, forKey: "facebookAppDisplayName")
    }
}
