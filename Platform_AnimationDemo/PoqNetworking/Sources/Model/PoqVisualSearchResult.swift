//
//  PoqVisualSearchResult.swift
//  PoqNetworking
//
//  Created by Manuel Marcos Regalado on 04/04/2018.
//

import Foundation
import ObjectMapper

open class PoqVisualSearchResult: Mappable {
    
    open var count: Int?
    open var categoryTitles: [String]?
    open var items: [PoqVisualSearchItem]?

    public required init?(map: Map) {
        
    }
    
    public init() {
        
    }
    
    // Mappable
    
    open func mapping(map: Map) {
        count <- map["count"]
        categoryTitles <- map["categoryTitles"]
        items <- map["items"]
    }
}
