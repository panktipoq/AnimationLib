//
//  PoqAccount.swift
//  Poq.iOS
//
//  Created by Erinç Erol on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper


/// The object containing the logged in user account
open class PoqAccount : Mappable {
    
    /// The email of the user
    open var email: String?
    
    /// The customer number of the user
    open var customerNo: String?
    
    /// The user's loyalty card number
    open var loyaltyCardNumber: String?
    
    /// User's first name
    open var firstName: String?
    
    /// User's last name
    open var lastName: String?
    
    /// User's gender
    open var gender: String?
    
    /// User's title
    open var title: String?
    
    /// User's phone
    open var phone: String?
    
    /// User's encrypted password
    open var encryptedPassword: String?
    
    /// User's username
    open var username: String?
    
    /// Request response status code
    open var statusCode: Int?
    
    /// Check if the user's loyalty account is closed
    open var isLoyaltAccountClosed:Bool?
    
    /// Check if the user's loyalty card is on a mastercard
    open var isMasterCard:Bool?
    
    /// The message coming back from the server
    open var message:String?
    
    /// The summary of loyalty points the user has
    open var pointsRewardSummary:PoqPointsRewardSummary?
    
    /// User's birthday
    open var birthday:String?
    
    /// Check if the guest state bag is merged with the logged in cart
    open var isBagMerged:Bool?
    
    /// User's cookies required for authentication - TODO: we don't seem to use this anywhere
    open var cookies:[PoqAccountCookie]?
    
    /// TODO: what are we using this for?
    open var headers:[PoqAccountCookie]?
    
    /// TODO: what are we using this for?
    open var isPromotion: Bool?
    
    /// TODO: what are we using this for?
    open var allowDataSharing: Bool?
    
    /// The refresh token kept when authentication needs to be refreshed
    open var refreshToken: String?
    
    /// The access token used to sign requests
    open var accessToken: String?
    
    /// Checks if the user is guest or not
    open var isGuest: Bool?
    
    /// TODO: What are we using this for?
    open var accountRef: String?

    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
       
        email <- map["email"]
//        customerNo <- map["customerNo"]
        loyaltyCardNumber <- map["loyaltyCardNumber"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        gender <- map["gender"]
        title <- map["title"]
        phone <- map["phone"]
        encryptedPassword <- map["encryptedPassword"]
        username <- map["username"]
        statusCode <- map["statusCode"]
        pointsRewardSummary <- map["pointsRewardSummary"]
        message <- map["message"]
        birthday <- map["birthday"]
        isMasterCard <- map["isMasterCard"]
        isLoyaltAccountClosed <- map["isLoyaltAccountClosed"]
        isBagMerged <- map["isBagMerged"]
        cookies <- map["cookies"]
        headers <- map["headers"]
        isPromotion <- map["isPromotion"]
        allowDataSharing <- map["allowDataSharing"]
        isGuest <- map["IsGuest"]
        
        refreshToken <- map["refreshToken"]
        accessToken <- map["accessToken"]
        accountRef <- map["accountReference"]
    }
}
