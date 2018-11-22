//
//  PoqSetting.swift
//  PoqiOSNetworking
//
//  Created by Erinç Erol on 16/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

public struct PoqSetting: Mappable {
    
    public var id: Int?
    public var key: String?
    public var value: String?
    public var settingTypeId: Int?
    public var appId: Int?
    
    public init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    public mutating func mapping(map: Map) {
        
        id <- map["id"]
        key <- map["key"]
        value <- map["value"]
        settingTypeId <- map["settingTypeId"]
        appId <- map["appId"]
    }
}
