//
//  QueryProductListPostBody.swift
//  PoqDemoApp
//
//  Created by Nikolay Dzhulay on 9/13/17.
//

import Foundation
import ObjectMapper
import PoqNetworking

public struct QueryProductListPostBody: BaseMappable {
    
    public let productIds: [PoqProductID]
    
    public init(productIds: [PoqProductID]) {
        self.productIds = productIds
    }
    
    mutating public func mapping(map: Map) {
        guard map.mappingType == .toJSON else {
            return
        }
        
        productIds >>> map["products"]
    }
}

