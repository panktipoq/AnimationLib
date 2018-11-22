//
//  PoqStripeAddressBody.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 17/03/2018.
//

import UIKit
import ObjectMapper

public class PoqStripeTokenBody: Mappable {
    
    public var token: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    open func mapping(map: Map) {
        token <- map["token"]
    }
    
}
