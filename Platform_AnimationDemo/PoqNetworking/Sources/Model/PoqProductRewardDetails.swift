//
//  PoqProductRewardDetails.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 10/01/2017.
//
//

import Foundation
import ObjectMapper

open class PoqProductRewardDetails: Mappable {

    //MARK: - Accessors

    open var title: String?
    open var pricePerUnit: String?
    open var code: String?

    //MARK: - Mappable

    public required init?(map: Map) {
    }
    
    public init() {
    }

    open func mapping(map: Map) {
        
        title <- map["title"]
        pricePerUnit <- map["pricePerUnit"]
        code <- map["code"]
    }
}
