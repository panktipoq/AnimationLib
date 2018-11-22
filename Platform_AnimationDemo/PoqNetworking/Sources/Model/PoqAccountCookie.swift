//
//  PoqAccountCookie.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 30/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object containing user's authentication cookies. TODO: Should we keep these in the app?
open class PoqAccountCookie : Mappable {
 
    /// The name of the cookie
    open var name: String?
    
    /// The value of the cookie
    open var value: String?
    
    /// Additional comment on the cookie
    open var comment: String?
    
    /// The url of the comment 
    open var commentUrl: String?
    
    /// The domain of the cookie
    open var domain: String?
    
    /// The expire date of the cookie
    open var expireDate: String?
    
    /// Checks if the cookie is available on http only or not
    open var httpOnly: Bool?
    
    /// Checks if the cookie is secure or not
    open var secure: Bool?
    
    /// The path of the cooke
    open var path: String?
    
    /// The port added to the path 
    open var port: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        name <- map["name"]
        value <- map["value"]
        comment <- map["comment"]
        commentUrl <- map["commentUrl"]
        domain <- map["domain"]
        expireDate <- map["expireDate"]
        httpOnly <- map["isHttpOnly"]
        secure <- map["isSecure"]
        path <- map["path"]
        port <- map["port"]
    }
}
