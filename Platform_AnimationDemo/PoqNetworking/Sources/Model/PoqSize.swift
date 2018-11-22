//
//  PoqSize.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object used to select a user's preffered size TODO: This is only used in one of our clients and if rememebered correctly this features has been deprecated with them might be slated for removal
open class PoqSize : Mappable {
    
    /// The identifier of the size object
    open var id:Int?
    
    /// The size label as displayed in the app
    open var size:String?
    
    /// If the size is selected or not
    open var isSelected:Bool?
    
    /// The category id to which the size object belongs to
    open var mySizesCategoryId:Int?

    public required init?(map: Map) {
    }
    
    public init() {
    }

    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        size <- map["size"]
        isSelected <- map["isSelected"]
        mySizesCategoryId <- map["mySizesCategoryId"]
    }
    
}
