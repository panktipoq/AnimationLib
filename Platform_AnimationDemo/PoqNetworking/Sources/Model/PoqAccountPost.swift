//
//  PoqAccountPost.swift
//  Poq.iOS
//
//  Created by Erinç Erol on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Wrapper object to execute a post request to backend for authentication
open class PoqAccountPost : Mappable {
    
    /// User's username
    open var username: String?
    
    /// User's password
    open var password: String?
    
    /// The user's encrypted password
    open var encryptedPassword: String?
    
    // If false then show mastercard dashboard on my profile
    open var isMasterCard:Bool?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        username <- map["username"]
        password <- map["password"]
        encryptedPassword <- map["encryptedPassword"]
        isMasterCard <- map["isMasterCard"]
        
    }
    
}
