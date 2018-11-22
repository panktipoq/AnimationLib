//
//  PoqStripeAddressBody.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 17/03/2018.
//

import UIKit
import ObjectMapper

public class PoqStripeZipCodeBody: Mappable {
    
    public var addressZip: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    open func mapping(map: Map) {
        addressZip <- map["zipCode"]
    }
    
}
