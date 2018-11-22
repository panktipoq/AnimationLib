//
//  PoqMySizeCategory.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

/// TODO: Where do we use this it's not present in the platform
open class PoqMySizeCategory : Mappable {
    
    
    /// The id of the my size category
    open var id:Int?
    
    /// The title of the my size category
    open var title:String?
    
    /// The code of the my size category
    open var code:String?
    
    /// The type id of the my size category
    open var mySizesTypeId:Int?
    
    /// The user's sizes for this category
    open var mySizes:[PoqSize]?

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
        code <- map["code"]
        mySizesTypeId <- map["mySizesTypeId"]
        mySizes <- map["mySizes"]
    }
    
}
