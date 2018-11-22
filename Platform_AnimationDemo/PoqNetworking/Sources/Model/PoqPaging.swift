//
//  PoqPaging.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

/// Paging object received from backend
open class PoqPaging : Mappable {
    
    // Total number of paginated results
    open var totalPages:Double?
    
    // Current page of paginated results
    open var currentPage:Int?
    
    // Selected page size count for results (default is 48)
    open var pageSize:Int?
    
    // Number of results found
    open var totalResults:Int?
    
    // Number of products after filtering
    open var filteredResults:Int?
    
    // Number of products after paging
    open var currentPageResults:Int?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        totalPages <- map["totalPages"]
        currentPage <- map["currentPage"]
        pageSize <- map["pageSize"]
        totalResults <- map["totalResults"]
        filteredResults <- map["filteredResults"]
        currentPageResults <- map["currentPageResults"]
    }
    
}
