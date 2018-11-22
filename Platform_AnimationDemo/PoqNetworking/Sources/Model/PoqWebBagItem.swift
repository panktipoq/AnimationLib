//
//  PoqWebBagItem.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 08/03/2017.
//
//

import UIKit
import ObjectMapper

open class PoqWebBagItem: Mappable {

    open var sku: String?
    open var quantity: Int?
    
    public required init?(map: Map) {
        
    }
    
    public init() {
        
    }
    
    // Mappable
    
    open func mapping(map: Map) {
        
        sku <- map["sku"]
        quantity <- map["quantity"]
    }
}
