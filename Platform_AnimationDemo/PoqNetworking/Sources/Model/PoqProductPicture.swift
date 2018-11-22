//
//  PoqProductPicture.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object containing a product's image
open class PoqProductPicture : Mappable {
    
    /// The id of the product image
    open var id:Int?
    
    /// The url of the product image
    open var url:String?
    
    /// The width of the product image
    open var width:Int?
    
    /// The height of the product image
    open var height:Int?
    
    /// The thumbnail url of the image
    open var thumbnailUrl:String?
    

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
        thumbnailUrl <- map["thumbnailUrl"]
    }
    
}
