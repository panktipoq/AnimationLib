//
//  PoqImageHotspot.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/03/2016.
//
//

import Foundation
import ObjectMapper

open class PoqImageHotspot: Mappable {

    open var productId: Int?
    open var externalId: String?
    open var x: Int?
    open var y: Int?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        productId <- map["productId"]
        externalId <- map["externalId"]
        x <- map["x"]
        y <- map["y"]
    }
}
