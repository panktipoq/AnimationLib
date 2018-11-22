//
//  PoqOnboarding.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 12/15/16.
//
//

import Foundation
import ObjectMapper

open class PoqOnboarding: Mappable {
    
    open var id: Int?
    open var title: String?
    open var sortIndex: Int?
    open var backgroundColorHex: String?
    open var contentBlocks: [PoqBlock]?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        sortIndex <- map["sortIndex"]
        backgroundColorHex <- map["backgroundColor"]
        contentBlocks <- map["contentBlocks"]
    }

}

