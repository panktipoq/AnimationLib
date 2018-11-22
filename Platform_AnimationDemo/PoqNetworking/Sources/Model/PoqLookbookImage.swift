//
//  PoqLookbookImage.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 14/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object used inside the lookbook section. The image is a presentation of a specific set of products (ex. complete evening wardrobe). One of these image objects links to multiple products that can be found in said image.
open class PoqLookbookImage: Mappable {
    
    /// The lookbook id of the picture.
    open var pictureId: Int?
    
    /// The url to the image.
    open var url: String?
    
    /// The number of products that are linked to this image.
    open var numberOfProducts: Int?
    
    /// The hotspots that are linked to this image (Hotspots are touch enabled areas on the image that link to a given product)
    open var hotspots: [PoqImageHotspot]?

    open var productExternalIds: [String]?
    open var productIds: [Int]?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map json server data to the object.
    ///
    /// - Parameter map: The map containing the json data from the server.
    open func mapping(map: Map) {
        
        productExternalIds <- map["productExternalIds"]
        productIds <- map["productIds"]
        
        pictureId <- map["pictureId"]
        url <- map["url"]
        numberOfProducts <- map["numberOfProducts"]
        
        hotspots <- map["hotspots"]
    }
}
