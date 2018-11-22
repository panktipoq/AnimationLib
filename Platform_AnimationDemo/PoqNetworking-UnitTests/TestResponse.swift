//
//  TestResponse.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/4/17.
//
//

import Foundation
import ObjectMapper

@testable import PoqNetworking

enum TestTaskType: PoqNetworkTaskTypeProvider {
    
    case theOnly
    
    public var type: String {
        return "TheOnly"
    }
    
}

struct TestResponse: Mappable {

    var testValue: String?
    
    // MARK: Mappable
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        testValue <- map["testValue"]
    }

}
