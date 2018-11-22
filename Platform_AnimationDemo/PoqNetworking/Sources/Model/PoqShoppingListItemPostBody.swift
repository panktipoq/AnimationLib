//
//  PoqShoppingListItemPostBody.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 12/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqShoppingListItemPostBody : Mappable {
    
    open var productId:String?
    open var productSizeId:String?
    open var externalId:String?

   
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        productId <- map["productId"]
        productSizeId <- map["productSizeId"]
        externalId <- map["externalId"]

    }
}
