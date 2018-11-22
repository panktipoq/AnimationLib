//
//  PoqAccountRegister.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 26/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object used to register a user account
open class PoqAccountRegister : Mappable {
    
    /// The user's credentials
    open var credentials: PoqAccountPost?
    
    /// The user account information
    open var profile: PoqAccount?
    
    /// Set if the user has a master card loyalty available
    open var isMasterCard: Bool?
    
    /// TODO: What do we use this flag for?
    open var isPromotion: Bool?
    
    /// TODO: What do we use this flag for?
    open var allowDataSharing: Bool?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        credentials <- map["credentials"]
        profile <- map["profile"]
        isMasterCard <- map["isMasterCard"]
        isPromotion <- map["isPromotion"]
        allowDataSharing <- map["allowDataSharing"]
    }
    
}
