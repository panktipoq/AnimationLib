//
//  Order.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 12/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper


public class PoqOrder<OrderItemType: OrderItem>: Mappable {

    public var orderItems: [OrderItemType]?
    
    public var id: Int?
    public var checkoutType: BagCheckoutType = .Delivery
    public var isCompleted: Bool?
    public var isCheckoutCompleted: Bool = false
    public var isTotalCostUpdated: Bool = false
    public var isOrderNumberUpdated: Bool = false
    public var isOrderInfoParsingFailed: Bool = false
    public var isTrackingSent: Bool = false
    public var platform: String?
    public var email: String?
    public var firstName:String?
    public var lastName: String?
    public var phone: String?
    public var orderKey: String?
    public var address: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var postCode: String?
    public var country: String?
    public var countryCode: String?
    public var deliveryFirstName: String?
    public var deliveryLastName: String?
    public var deliveryPhone: String?
    public var deliveryAddress: String?
    public var deliveryAddress2: String?
    public var deliveryCity: String?
    public var deliveryState: String?
    public var deliveryPostCode: String?
    public var deliveryCountry: String?
    public var deliveryCountryCode: String?

    public var totalPrice: Double?
    public var totalQuantity: Int?
    public var totalPriceString: String?
    public var subtotalPrice: Double?
    public var subtotalPriceString: String?
    public var totalVAT: Double?
    public var deliveryCost: Double?
    public var deliveryCostString: String?
    public var voucherAmount: Double?
    public var voucherAmountString: String?
    public var voucherCode: String?
    public var voucherTitle: String?
    public var currency: String?
    public var customerID: Int?
    public var orderStatusID: Int?
    public var paymentStatusID: Int?
    public var deliverToSameAddress: Bool?
    public var paymentType: Int?
    public var message: String?
    public var orderStatus: String?
    public var orderDate: String?
    public var paymentMethod: String?
    public var fullAddress: String?
    public var deliveryOption: String?
    public var statusCode: Int?
    public var giftMessage: String?
    public var externalOrderId: String?
    public var fullShippingAddress: String?
    public var fullBillingAddress: String?
    public var latitude: Double?
    public var longitude: Double?
    public var nearestStoreName: String?
    public var trackingUrl: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    public func mapping(map: Map) {
        
        id <- map["id"]
        isCompleted <- map["isCompleted"]
        platform <- map["platform"]
        email <- map["email"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        phone <- map["phone"]
        orderKey <- map["orderKey"]
        address <- map["address"]
        address2 <- map["address2"]
        city <- map["city"]
        state <- map["state"]
        postCode <- map["postCode"]
        country <- map["country"]
        countryCode <- map["countryCode"]
        totalPriceString <- map["totalPriceString"]
        deliveryFirstName <- map["deliveryFirstName"]
        deliveryLastName <- map["deliveryLastName"]
        deliveryPhone <- map["deliveryPhone"]
        deliveryAddress <- map["deliveryAddress"]
        deliveryAddress2 <- map["deliveryAddress2"]
        deliveryCity <- map["deliveryCity"]
        deliveryState <- map["deliveryState"]
        deliveryPostCode <- map["deliveryPostCode"]
        deliveryCountry <- map["deliveryCountry"]
        deliveryCountryCode <- map["deliveryCountryCode"]
        
        voucherAmountString <- map["voucherAmountString"]
        subtotalPriceString <- map["subtotalPriceString"]
        deliveryCostString <- map["deliveryCostString"]
        
        if map.JSON["shippingAddress"] != nil {
            
            var poqAddress: PoqAddress?
            poqAddress <- map["shippingAddress"]
            if let poqAddress = poqAddress {
                deliveryFirstName = poqAddress.firstName
                deliveryLastName = poqAddress.lastName
                deliveryPhone = poqAddress.phone
                deliveryAddress = poqAddress.address1
                deliveryAddress2 = poqAddress.address2
                deliveryCity = poqAddress.city
                deliveryPostCode = poqAddress.postCode
                deliveryCountry = poqAddress.country
            
                deliveryState = poqAddress.county
                deliveryCountryCode = poqAddress.countryId
            }
        }

        if map.JSON["billingAddress"] != nil {
            
            var poqAddress: PoqAddress?
            poqAddress <- map["billingAddress"]
            if let poqAddress = poqAddress {
                firstName = poqAddress.firstName
                lastName = poqAddress.lastName
                phone = poqAddress.phone
                address = poqAddress.address1
                address2 = poqAddress.address2
                city = poqAddress.city
                postCode = poqAddress.postCode
                country = poqAddress.country
                countryCode = poqAddress.countryId
                email = poqAddress.email
                
            }
        }
        
        orderItems <- map["orderItems"]
        totalPrice <- map["totalPrice"]
        totalQuantity <- map["totalQuantity"]
        subtotalPrice <- map["subtotalPrice"]
        totalVAT <- map["vatTotal"]
        deliveryCost <- map["deliveryCost"]
        voucherAmount <- map["voucherAmount"]
        voucherCode <- map["voucherCode"]
        voucherTitle <- map["voucherTitle"]
        currency <- map["currency"]
        customerID <- map["customerID"]
        orderStatusID <- map["orderStatusID"]
        paymentStatusID <- map["paymentStatusID"]
        deliverToSameAddress <- map["deliverToSameAddress"]
        paymentType <- map["paymentType"]
        message <- map["message"]
        orderStatus <- map["dwOrderStatus"]
        orderDate <- map["dwOrderDate"]
        paymentMethod <- map["dwPaymentMethod"]
        fullAddress <- map["dwAddress"]
        deliveryOption <- map["dwDeliveryOption"]
        statusCode <- map["statusCode"]
        giftMessage <- map["dwGiftMessage"]
        externalOrderId <- map["externalOrderId"]
        fullShippingAddress <- map["fullShippingAddress"]
        fullBillingAddress <- map["fullBillingAddress"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        nearestStoreName <- map["nearestStoreName"]
        trackingUrl <- map["trackingUrl"]
        checkoutType <- map["checkoutType"]
    }

}
