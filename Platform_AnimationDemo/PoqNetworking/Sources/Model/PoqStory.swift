//
//  PoqStory.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 28/06/2016.
//
//

import Foundation
import ObjectMapper

open class PoqStory: Mappable {
    
    open var id: Int?
    open var title: String?
    open var brandName: String?
    open var contentBlocks: [PoqBlock]?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        
        title <- map["title"]
        brandName <- map["brandName"]
        contentBlocks <- map["contentBlocks"]
    }
}
