//
//  PoqMessage.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqMessage: Mappable, CustomStringConvertible {
    
    open var id: Int?
    open var key: String?
    open var message: String?
    open var statusCode: Int?
    open var magentoMessage: String?
    open var storeName: String?
    open var cookies: [PoqAccountCookie]?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        key <- map["key"]
        message <- map["message"]
        statusCode <- map["statusCode"]
        magentoMessage <- map["magentoMessage"]
        storeName <- map["storeName"]
        cookies <- map["cookies"]
    }
    
    public var description: String {
        return Mapper().toJSONString(self, prettyPrint: false) ?? ""
    }
}
