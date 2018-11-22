//
//  PoqSearchResponse.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/27/17.
//
//

import Foundation
import ObjectMapper

/// Object containing backend response for a given search
public final class PoqSearchResponse: Mappable {
    
    /// An array of search results
    public final var results: [PoqSearchResult]?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    public final func mapping(map: Map) {
        results <- map["value"]
    }
    
}


