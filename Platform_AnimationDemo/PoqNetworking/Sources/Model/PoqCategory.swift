//
//  Category.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Object containing information about a category item in a list
open class PoqCategory : Mappable {
    
    /// The category id
    open var id: Int?
    
    /// The brand id of the category
    open var brandId: String?
    
    /// The brand name of the category TODO: Wouldn't this be more suited in a PoqBrand object ?
    open var brandName: String?
    
    /// The parent id of the category
    open var parentCategoryId: Int?
    
    /// The title of the category
    open var title: String?
    
    /// TODO: Why do we have categoryId and id ?
    open var categoryId: Int?
    
    /// The order index of the category in the list
    open var sortIndex: Int?
    
    /// The category's thumbnail url
    open var thumbnailUrl: String?
    
    /// The category's thumbnail width
    open var thumbnailWidth: Int?
    
    /// The category's thumbnail height
    open var thumbnailHeight: Int?
    
    /// The type of category as set by backend TODO: We don't use this
    open var categoryType: String?
    
    /// Checks if this category has a subcategory
    open var hasSubCategory: Bool?
    
    /// The deeplink url of the category
    open var deeplinkUrl: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        brandId <- map["brandId"]
        parentCategoryId <- map["parentCategoryId"]
        title <- map["title"]
        categoryId <- map["categoryId"]
        sortIndex <- map["sortIndex"]
        thumbnailUrl <- map["thumbnailUrl"]
        thumbnailWidth <- map["thumbnailWidth"]
        thumbnailHeight <- map["thumbnailHeight"]
        categoryType <- map["categoryType"]
        hasSubCategory <- map["hasSubCategory"]
        deeplinkUrl <- map["deeplinkUrl"]
    }
}
