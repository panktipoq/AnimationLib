//
//  PoqAccountUpdate.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 24/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Wrapper used to update a user's account information
open class PoqAccountUpdate : Mappable {
    
    /// User's first name
    open var firstName: String?
    
    /// User's last name
    open var lastName: String?
    
    /// User's birthday
    open var birthday: String?
    
    /// User's email
    open var email: String?
    
    /// Set if user has a mastercard loyalty number
    open var isMasterCard: Bool?
    
    /// TODO: What do we use this for ?
    open var allowDataSharing:Bool?
    
    /// TODO: What do we use this for ?
    open var isPromotion:Bool?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        birthday <- map["birthday"]
        email <- map["email"]
        isPromotion <- map["isPromotion"]
        allowDataSharing <- map["allowDataSharing"]
        isMasterCard <- map["isMasterCard"]

    }
    
}
