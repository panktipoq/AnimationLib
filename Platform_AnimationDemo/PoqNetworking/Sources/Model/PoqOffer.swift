//
//  PoqOffer.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation
import ObjectMapper

open class PoqOffer: Mappable {
    
    open var id: Int?
    open var name: String?
    open var details: String?
    open var captionTitle: String?

    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
        details <- map["details"]
        captionTitle <- map["captionTitle"]
    }
}
