//
//  PoqStore.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqStore : Mappable {
    
    open var id:Int?
    open var name:String?
    open var address:String?
    open var address2:String?
    open var city:String?
    open var county:String?
    open var country:String?
    open var postCode:String?
    open var phone:String?
    open var latitude:String?
    open var longitude:String?
    open var distance:Double?
    open var mondayOpenTime:String?
    open var mondayCloseTime:String?
    open var tuesdayOpenTime:String?
    open var tuesdayCloseTime:String?
    open var wednesdayOpenTime:String?
    open var wednesdayCloseTime:String?
    open var thursdayOpenTime:String?
    open var thursdayCloseTime:String?
    open var fridayOpenTime:String?
    open var fridayCloseTime:String?
    open var saturdayOpenTime:String?
    open var saturdayCloseTime:String?
    open var sundayOpenTime:String?
    open var sundayCloseTime:String?
    open var notes:String?
    open var appId:Int?
    open var numberInStock: Int?
    open var isLowStock: Bool?

    open var collectDate: String?
    open var metaPackRequestId: String?
    open var metaPackBookingCode: String?
    open var metaPackCarrierServiceCode: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
        address <- map["address"]
        address2 <- map["address2"]
        city <- map["city"]
        county <- map["county"]
        country <- map["country"]
        postCode <- map["postCode"]
        phone <- map["phone"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        distance <- map["distance"]
        mondayOpenTime <- map["mondayOpenTime"]
        mondayCloseTime <- map["mondayCloseTime"]
        tuesdayOpenTime <- map["tuesdayOpenTime"]
        tuesdayCloseTime <- map["tuesdayCloseTime"]
        wednesdayOpenTime <- map["wednesdayOpenTime"]
        wednesdayCloseTime <- map["wednesdayCloseTime"]
        thursdayOpenTime <- map["thursdayOpenTime"]
        thursdayCloseTime <- map["thursdayCloseTime"]
        fridayOpenTime <- map["fridayOpenTime"]
        fridayCloseTime <- map["fridayCloseTime"]
        saturdayOpenTime <- map["saturdayOpenTime"]
        saturdayCloseTime <- map["saturdayCloseTime"]
        sundayOpenTime <- map["sundayOpenTime"]
        sundayCloseTime <- map["sundayCloseTime"]
        notes <- map["notes"]
        appId <- map["appId"]
        numberInStock <- map["numberInStock"]
        isLowStock <- map["isLowStock"]
        
        collectDate <- map["storeDeliveryTo"]
        metaPackRequestId <- map["storeRequestId"]
        metaPackBookingCode <- map["bookingCode"]
        metaPackCarrierServiceCode <- map["storeCarrierServiceCode"]
        
    }
    
}
