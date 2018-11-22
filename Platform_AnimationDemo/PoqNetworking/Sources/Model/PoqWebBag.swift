//
//  PoqWebBag.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 07/03/2017.
//
//

import Foundation
import ObjectMapper

open class PoqWebBag: Mappable {
    
    open var basketItemsUri: String?
    open var cookies: [PoqAccountCookie]?
    
    public required init?(map: Map) {
        
    }
    
    public init() {
        
    }
    
    // Mappable
    
    open func mapping(map: Map) {
        
        basketItemsUri <- map["basketItemsUri"]
        cookies <- map["cookies"]
    }
}
