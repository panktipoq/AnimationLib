//
//  PoqMySize.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqMySize : Mappable {
    
    
    open var id:Int?
    open var title:String?
    open var mySizesCategories:[PoqMySizeCategory]?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        mySizesCategories <- map["mySizesCategories"]
    }
    
}
