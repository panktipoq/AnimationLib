//
//  PoqRecentlyViewedPostBody.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/5/17.
//
//

import Foundation
import ObjectMapper


/// Mappable data model that maps out products that need to be excluded from the recently viewed fetched request.
public struct PoqRecentlyViewedPostBodyProduct: Mappable {
    
    /// The product id of the product in discsussion.
    public var productId: Int?
    
    /// The last date at which the product has been viewed. The string is in format yyyy-MM-ddTHH:mm:ssZ.
    public var lastViewed: String?
    
    public init?(map: Map) {
    }
    
    init() {
    }
    
    
    /// Used to map the product properties from the json response.
    ///
    /// - Parameter map: The map that holds the json values.
    public mutating func mapping(map: Map) {
        productId <- map["productId"]
        lastViewed <- map["lastViewed"]
    }
}

/// Used to make the getRecentlyViewedProducts request to fetch the recently viewed products.
public struct PoqRecentlyViewedPostBody: Mappable {
    
    /// The products that need not be retrieved in the request.
    public var recentlyViewedProducts: [PoqRecentlyViewedPostBodyProduct]?
    
    
    public init?(map: Map) {
    }
    
    public init() {
    }
    /// Used to map the json response for the recently viewed products.
    ///
    /// - Parameter map: The map that contains the json object.
    public mutating func mapping(map: Map) {
        recentlyViewedProducts <- map["recentlyViewedProducts"]
    }
}
