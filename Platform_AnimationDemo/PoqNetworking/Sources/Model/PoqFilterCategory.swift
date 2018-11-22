//
//  PoqFilterCategory.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object pointing to a category based on the FilterType
open class PoqFilterCategory : Mappable {
    
    /// The id of the fiter category
    open var id: String?
    
    /// The title of the filter category
    open var title: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
    }
    
}
