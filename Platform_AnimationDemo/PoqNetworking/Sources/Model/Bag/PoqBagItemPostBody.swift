//
//  PoqBagItem.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqBagItemPostBody: Mappable {
    
    open var items: [PoqBagItemPostBodyItem]?
    
    public required init?(map: Map) {
    }
    
    public init() {
        items = []
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        items <- map["bagItems"]
    }
}
