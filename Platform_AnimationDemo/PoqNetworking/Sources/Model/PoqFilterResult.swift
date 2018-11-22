//
//  PoqFilterResult.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// The object containing the filter response from the server. This object also contains the content blocks associated with the product page and the products. Most common usage is in PLP where besides the products we need data like page filters.
open class PoqFilterResult : Mappable {
    
    /// Pagination data for selected set.
    open var paging: PoqPaging?
    
    /// Tailored filters for selected set.
    open var filter: PoqFilter?
    
    /// Products from selected set.
    open var products: [PoqProduct]?
    
    /// Attribute for reporting performance/failure messages.
    open var message: String?
    
    /// Selected app (client) id for the results TODO: Why do we need the appId in the request?
    open var appId: Int?
    
    /// Master product for grouped product PLP.
    open var averageRating: Double?
    
    /// TODO: Why do we have a number of reviews for the PLP response ?
    open var numberOfReviews: Int?
    
    /// The content blocks associated with the product listing.
    open var contentBlocks: [PoqPromotionBlock]?
    
    /// TODO: What is the redirect url used for ?
    open var redirectUrl: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    /// The mapped object containing the json response from the server.
    ///
    /// - Parameter map: The map that contains the json data from the server.
    open func mapping(map: Map) {
        
        contentBlocks <- map["contentBlocks"]
        paging <- map["paging"]
        filter <- map["filters"]
        products <- map["products"]
        message <- map["message"]
        appId <- map["appId"]
        averageRating <- map["averageRating"]
        numberOfReviews <- map["numberOfReviews"]
        
        redirectUrl <- map["redirectUrl"]
    }
    
}
