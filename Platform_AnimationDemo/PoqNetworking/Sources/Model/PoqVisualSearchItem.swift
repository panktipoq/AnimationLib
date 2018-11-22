//
//  PoqVisualSearchItem.swift
//  PoqNetworking
//
//  Created by Manuel Marcos Regalado on 04/04/2018.
//

import Foundation
import ObjectMapper

open class PoqVisualSearchItem: Mappable {
    
    open var categoryTitle: String?
    open var products: [PoqProduct]?
    
    public required init?(map: Map) {
        
    }
    
    public init() {
        
    }
    
    // Mappable
    
    open func mapping(map: Map) {
        categoryTitle <- map["categoryTitle"]
        products <- map["products"]
    }
}
