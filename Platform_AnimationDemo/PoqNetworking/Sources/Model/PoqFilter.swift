//
//  PoqFilter.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqFilter : Mappable {
    
    /// Decide whether the result should come from cache or db.
    open var isFromDB: Bool?
    
    /// Wether or not the response is a fresh one from a cleared cache. TODO: Why do we need this?
    open var isRefreshed: Bool = false
    
    /// Cache key. TODO: Why do we need this?
    open var cacheIdentifier: String? 
    
    /// Keyword(s) for searching in product's title, description.
    open var keyword: String?
    
    /// Category ID viewed currently in the app.
    open var categoryId:String?
    
    /// Distinct product ids for a group of products.
    open var ids:[Int]?
    
    /// Distinct product sizes in selected set.
    open var sizes:[String]?
    
    /// Distinct product size values in selected set.
    open var sizeValues:[String]?
    
    /// Min/Max product prices (0 => min, 1 => max) in selected set.
    open var prices:[Double]?
    
    /// Subcategories in selected set.
    open var categories:[PoqFilterCategory]?
    
    /// Distinct colours in selected set.
    open var colours:[String]?
    
    /// Distinct colour values in selected set.
    open var colourValues:[String]?
    
    /// Distinct brands in selected set.
    open var brands:[String]?
    
    /// Distinct styles in selected set.
    open var styles:[String]?
    
    /// Distinct ratings in selected set.
    open var ratings:[Int]?
    
    /// Selected categories via query params.
    open var selectedCategories:[String]?
    
    /// Selected sizes via query params.
    open var selectedSizes:[String]?
    
    /// Selected size values via query params.
    open var selectedSizeValues:[String]?
    
    /// Selected colors via query params.
    open var selectedColors:[String]?
    
    /// Selected color values via query params.
    open var selectedColorValues:[String]?
    
    /// Selected brands via query params.
    open var selectedBrands:[String]?
    
    /// Selected styles via query params.
    open var selectedStyles:[String]?
    
    /// Selected ratings via query params.
    open var selectedRatings:[Int]?
    
    /// Selected min price.
    open var selectedMinPrice:Int?
    
    /// Selected max price.
    open var selectedMaxPrice:Int?
    
    /// Selected attribute to sort results.
    open var selectedSortField:PoqFilterSortField?
    
    /// Selected sort type for the results.
    open var selectedSortType:PoqFilterSortType?
    
    /// Used to select specific product traits like brand.
    open var refinements:[PoqFilterRefinement]?
    
    /// The selected refinemnets that the user has checked.
    open var selectedRefinements:[PoqFilterRefinement]?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        isFromDB <- map["isFromDB"]
        cacheIdentifier <- map["cacheIdentifier"]
        keyword <- map["keyword"]
        categoryId <- map["categoryId"]
        ids <- map["ids"]
        sizes <- map["sizes"]
        sizeValues <- map["sizeValues"]
        prices <- map["prices"]
        colours <- map["colours"]
        colourValues <- map["colourValues"]
        brands <- map["brands"]
        styles <- map["styles"]
        ratings <- map["ratings"]
        refinements <- map["refinements"]
        
        selectedCategories <- map["selectedCategories"]
        categories <- map["categories"]
        selectedSizes <- map["selectedSizes"]
        selectedSizeValues <- map["selectedSizeValues"]
        selectedColors <- map["selectedColors"]
        selectedColorValues <- map["selectedColorValues"]
        selectedBrands <- map["selectedBrands"]
        selectedStyles <- map["selectedStyles"]
        selectedRatings <- map["selectedRatings"]
        selectedMinPrice <- map["selectedMinPrice"]
        selectedMaxPrice <- map["selectedMaxPrice"]
        selectedSortField <- map["selectedSortField"]
        selectedSortType <- map["selectedSortType"]
        selectedRefinements <- map["selectedRefinements"]
    }
}
