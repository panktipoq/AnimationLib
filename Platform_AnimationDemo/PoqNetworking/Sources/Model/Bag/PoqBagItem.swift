//
//  PoqBagItem.swift
//  PoqiOSNetworking
//
//  Created by Erinç Erol on 10/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol BagItem: Mappable {

    associatedtype ProductType: Product

    var productId: Int? { get }
    var quantity: Int? { get }
    
    var priceOfOneItem: Double? { get }
    var surcharge: Double? { get }
    var subTotal: Double? { get }
    
    var product: ProductType? { get }
    
    var productSizeId: Int? { get }
}


open class PoqBagItem : Mappable, BagItem, NSCopying {
    
    public typealias ProductType = PoqProduct
    
    open var id:Int?
    open var productId: Int?
    open var quantity: Int?
    open var productSizeId: Int?
    open var appId: Int?
    open var poqUserId: String?
    open var product: ProductType?
    open var message: String?
    open var statusCode: Int?
    open var cartId: String? // Native checkout - magento enterprise only
    open var priceOfOneItem: Double?
    open var surcharge: Double?
    open var subTotal: Double?
    open var barcode: String?
    open var isRegistryItem: Bool?
    open var stockMessage: String?
    open var isGiftAvailable: Bool?
    open var vouchersApplied: [PoqVoucherV2]?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    //  we treat isAvailable == nil as isAvailable == true
    open var isAvailable: Bool?
    
    /**
     Products that exists in Magento but are not yet added to our database
     are marked as isExternal to indicate it.
     
     The value of **isExternal** is received from the API and by default is false.
     
     Specific interactions should be allowed for Product(s) that this flag is enabled:
     - Delete (from Basket)
     - Update (e.g. increase/decrease quantity)
     */
    open var isExternal: Bool?

    open func isUnavailable() -> Bool {
        
        if let existedIsUnavailable: Bool = isAvailable, !existedIsUnavailable {
            return true
        }
        
        // check value in product
        if let existedProduct: PoqProduct = product {
            return existedProduct.isUnavailable()
        }
        
        return false
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        poqUserId <- map["poqUserID"]
        productSizeId <- map["productSizeID"]
        productId <- map["productId"]
        appId <- map["appID"]
        quantity <- map["quantity"]
        productSizeId <- map["productSizeID"]
        appId <- map["appID"]
        poqUserId <- map["poqUserID"]
        product <- map["product"]
        message <- map["message"]
        statusCode <- map["statusCode"]
        cartId <- map["cartId"]
        
        isAvailable <- map["isAvailable"]
        isExternal <- map["isExternal"]
        
        priceOfOneItem <- map["priceOfOneItem"]
        
        surcharge <- map["surcharge"]
        subTotal <- map["subTotal"]
        barcode <- map["barcode"]
        isRegistryItem <- map["isRegistryItem"]
        vouchersApplied <- map["vouchersApplied"]
        stockMessage <- map["stockMessage"]
        isGiftAvailable <- map["isGiftAvailable"]
        vouchersApplied <- map["vouchersApplied"]

    }

    @objc open func copy(with zone: NSZone?) -> Any {
        let newBagItem = PoqBagItem()

        newBagItem.id = statusCode
        newBagItem.poqUserId = poqUserId
        newBagItem.productSizeId = productSizeId
        newBagItem.productId = productId
        newBagItem.appId = appId
        newBagItem.quantity = quantity
        newBagItem.productSizeId = productSizeId
        newBagItem.appId = appId
        newBagItem.poqUserId = poqUserId
        newBagItem.product = product
        newBagItem.message = message
        newBagItem.statusCode = statusCode
        
        return newBagItem
    }
}

