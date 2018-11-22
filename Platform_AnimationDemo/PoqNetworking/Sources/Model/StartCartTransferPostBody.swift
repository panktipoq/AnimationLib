//
//  StartCartTransferPostBody.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/15/17.
//
//

import Foundation
import ObjectMapper

public class StartCartTransferPostBody: Mappable {

    /// If feature flag for neares store is true: we will send this parame
    public final var sendNearestStore: Bool = false
    public final var latitude: Double?
    public final var longitude: Double?
    
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public final func mapping(map: Map) {
        
        sendNearestStore <- map["sendNearestStore"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}
