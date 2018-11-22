//
//  PoqBraintreeNonce.swift
//  PoqPlatform
//
//  Created by Rachel McGreevy on 2/21/18.
//

import Foundation
import ObjectMapper

open class PoqBraintreeNonce: Mappable {
    
    public var nonce: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        nonce <- map["nonce"]
    }
    
}
