//
//  PoqProductColor.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// The color variant of a product
open class PoqProductColor : Mappable {
    
    /// The product color id
    open var id:Int?
    
    /// The product's id
    open var productID:Int?
    
    /// The title of the color
    open var title:String?
    
    /// Short title of the color
    open var shortTitle:String?
    
    /// The image url to the swatch
    open var imageUrl:String?
    
    /// The external id of the color
    open var externalID:String?
    
    /// The thumbnail url to the color swatch
    open var thumbnailUrl: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        productID <- map["productID"]
        title <- map["title"]
        shortTitle <- map["shortTitle"]
        imageUrl <- map["imageUrl"]
        externalID <- map["externalID"]
        thumbnailUrl <- map["thumbnailUrl"]
    }
}
