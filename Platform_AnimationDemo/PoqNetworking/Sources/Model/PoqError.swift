//
//  Error.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqError : Mappable {
    
    open var Message:String?
    open var MessageDetail:String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    
    // Mappable
    open func mapping(map: Map) {
        
        Message <- map["Message"]
        MessageDetail <- map["MessageDetail"]
    }

}
