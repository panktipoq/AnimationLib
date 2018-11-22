//
//  PoqSearchResult.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/27/17.
//
//

import Foundation
import ObjectMapper

/// An item in the search results
public final class PoqSearchResult: Mappable {
    
    /// The title of a search result item
    public final var title: String?
    
    /// The category id of a search result item
    public final var categoryId: String?
    
    /// The category id of a search result item
    public final var deeplinkUrl: String?
    
    /// The parent category id of a search result item
    public final var parentCategoryId: Int?
    
    /// The parent category title of a search result item
    public final var parentCategoryTitle: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    public final func mapping(map: Map) {
        title <- map["title"]
        categoryId <- map["categoryId"]
        deeplinkUrl <- map["deeplinkUrl"]

        parentCategoryId <- map["parentCategoryId"]
        parentCategoryTitle <- map["parentCategoryTitle"]
    }
    
}
