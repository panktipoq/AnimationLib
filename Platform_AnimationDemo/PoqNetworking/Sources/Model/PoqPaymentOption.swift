//
//  PoqPaymentOption.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 15/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqPaymentOption: Mappable {
    
    open var id: Int?
    open var appID: Int?
    
    open var message: String?
    open var statusCode: Int?
    
    open var code: String?
    open var title: String?
    
    open var postName: String?
    open var poqUserId: String?
    
    open var orderId: String?
    open var stripeCustomerId: String?
    open var paymentMethod: String?
    open var paymentMethodToken: String?
    open var paymentVerificationNonce: String?
    open var paymentType: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        appID <- map["appID"]
        
        message <- map["message"]
        statusCode <- map["statusCode"]
        
        code <- map["code"]
        title <- map["title"]
        
        postName <- map["postName"]
        poqUserId <- map["poqUserId"]
        
        orderId <- map["orderId"]
        
        stripeCustomerId <- map["stripeCustomerId"]
        paymentMethodToken <- map["paymentMethodToken"]
        paymentVerificationNonce <- map["paymentVerificationNonce"]
        paymentType <- map["paymentType"]
        
    }
}
