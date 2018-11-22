//
//  PoqFacebookAccountPost.swift
//  Poq.iOS
//
//  Created by Andrei Mirzac on 20/10/2016.
//
//

import Foundation
import ObjectMapper

public final  class PoqFacebookAccountPost : Mappable {
    
    public final var token: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public final func mapping(map: Map) {
        token <- map["token"]
    }
}

