//
//  PoqStoreStock.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqStoreStock : Mappable {
    
    open var id:Int?
    open var name:String?
    open var address:String?
    open var quantity:Int?
    open var isInStock:Bool?
    open var selectedSizeName:String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
        address <- map["address"]
        quantity <- map["quantity"]
        isInStock <- map["isInStock"]
        selectedSizeName <- map["selectedSizeName"]
    }
    
}
