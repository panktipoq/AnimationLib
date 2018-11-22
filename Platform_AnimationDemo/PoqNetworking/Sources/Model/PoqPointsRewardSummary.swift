//
//  PoqPointsRewardSummary.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 12/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//
//"currency": "GBP",
//"balance": "200",
//"points": 38,
//"expiringBalance": 200,
//"expiringBalanceDate": "08/07/2015",
//"displayConversion": "*500 points = £5",
//"pointsToGo": 462,
//"pointsForReward": 500

import Foundation
import ObjectMapper

open class PoqPointsRewardSummary : Mappable {
    
    open var currency: String?
    open var balance: String?
    open var points: Double?
    open var expiringBalance: Double?
    open var expiringBalanceDate: String?
    open var displayConversion: String?
    open var pointsToGo: Double?
    open var pointsForReward: Double?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        currency <- map["currency"]
        balance <- map["balance"]
        points <- map["points"]
        expiringBalance <- map["expiringBalance"]
        expiringBalanceDate <- map["expiringBalanceDate"]
        displayConversion <- map["displayConversion"]
        pointsToGo <- map["pointsToGo"]
        pointsForReward <- map["pointsForReward"]
    }
    
}
