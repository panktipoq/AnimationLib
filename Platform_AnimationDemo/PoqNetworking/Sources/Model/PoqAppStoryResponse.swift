//
//  PoqAppStoryResponse.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 27/07/2017.
//
//

import Foundation
import ObjectMapper

public struct PoqAppStoryResponse: Mappable {
    public var title: String?
    public var stories = [PoqAppStory]()
    
    public init?(map: Map) {
    }
    
    public mutating func mapping(map: Map) {
        stories <- map["stories"]
    }
}



