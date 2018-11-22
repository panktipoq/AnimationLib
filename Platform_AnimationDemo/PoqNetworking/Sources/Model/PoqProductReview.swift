//
//  PoqProductReview.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object containing a review item
open class PoqProductReview : Mappable {
    
    /// The id of the review
    open var id:Int?
    
    /// The app id of the review
    open var appID:Int?
    
    /// The product id to which the review was added
    open var productID:Int?
    
    /// The title of the product review
    open var title:String?
    
    /// The review text body
    open var reviewText:String?
    
    /// The rating given with the review
    open var rating:Double?
    
    /// The username that gave the review
    open var username:String?
    
    /// The date the review was added
    open var reviewDate:String?
    
    /// The external id of the review object
    open var externalID:String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        appID <- map["appID"]
        productID <- map["productID"]
        title <- map["title"]
        reviewText <- map["reviewText"]
        rating <- map["rating"]
        username <- map["username"]
        reviewDate <- map["reviewDate"]
        externalID <- map["externalID"]
    }
    
}
