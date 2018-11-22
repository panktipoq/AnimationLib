//
//  PoqWebBagItems.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 08/03/2017.
//
//

import UIKit
import ObjectMapper

open class PoqWebBagItems: Mappable {
    
    open var bagItems: [PoqWebBagItem]?
    
    public required init?(map: Map) {
        
    }
    
    public init() {
        
    }
    
    // Mappable
    
    open func mapping(map: Map) {
        
        bagItems <- map["bagItems"]
    }
}
