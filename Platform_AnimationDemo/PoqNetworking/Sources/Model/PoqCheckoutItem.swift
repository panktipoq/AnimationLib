//
//  PoqCheckoutItem.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 15/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

public enum BagCheckoutType: Int {
    case None = -1
    case Delivery = 0
    case ClickAndCollect = 1
    
    public static func getOptionFromInt( index: Int ) -> BagCheckoutType {
        guard let option = BagCheckoutType( rawValue: index ) else {
            return .Delivery
        }
        return option
    }
}

public protocol CheckoutAddressesProvider: AnyObject {
    
    var shippingAddress: PoqAddress? { get set }
    var billingAddress: PoqAddress? { get set }
}

public protocol CheckoutItem: CheckoutAddressesProvider, Mappable {
    
    associatedtype BagItemType: BagItem

    var bagItems: [BagItemType] { get set }
    
    var vouchers: [PoqVoucher]? { get set }
    
    var deliveryOption: PoqDeliveryOption? { get set }
    var paymentOption: PoqPaymentOption? { get set }

    var totalPrice: Double? { get set }
    var subTotalPrice: Double? { get set }
    var shippingTotalPrice: Double? { get set }
    
    var orderKey: String? { get set }
    var poqUserId: String? { get set }
    
    var poqOrderId: Int? { get set }
    
    var cookies: [PoqAccountCookie]? { get set }
    var headers: [PoqAccountCookie]? { get set }
}

public class PoqCheckoutItem<B: BagItem> : Mappable, CheckoutItem {
    
    public typealias BagItemType = B
    
    public var bagItems = [BagItemType]()
    
    public var vouchers: [PoqVoucher]?
    
    public var shippingAddress: PoqAddress?
    public var billingAddress: PoqAddress?
    
    public var deliveryOption: PoqDeliveryOption?
    public var paymentOption: PoqPaymentOption?
    
    public var statusCode: Int?
    public var message: String?
    
    public var totalPrice: Double?
    public var subTotalPrice: Double?
    public var shippingTotalPrice: Double?
    
    public var orderKey: String?
    public var poqUserId: String?
    
    public var poqOrderId: Int?
    
    public var cookies: [PoqAccountCookie]?
    public var headers: [PoqAccountCookie]?
    
    public var checkoutType: BagCheckoutType = .Delivery
    public var hasClickAndCollect: Bool?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    public func mapping(map: Map) {
        
        bagItems <- map["bagItems"]
        vouchers <- map["vouchers"]
        
        shippingAddress <- map["shippingAddress"]
        billingAddress <- map["billingAddress"]
        
        deliveryOption <- map["deliveryOption"]
        paymentOption <- map["paymentOption"]
        
        statusCode <- map["statusCode"]
        message <- map["message"]
        
        totalPrice <- map["totalPrice"]
        subTotalPrice <- map["subtotalPrice"]
        shippingTotalPrice <- map["shippingTotalPrice"]
        
        orderKey <- map["orderKey"]
        poqUserId <- map["poqUserId"]
        poqOrderId <- map["poqOrderId"]
        
        cookies <- map["cookies"]
        headers <- map["headers"]
        hasClickAndCollect <- map["clickCollectEnabled"]
        checkoutType <- map["checkoutType"]
    }
}
