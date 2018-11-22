//
//  Banner.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 06/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqHomeBanner: Mappable {
    
    open var id: Int?
    open var title: String?
    open var body: String?
    open var url: String?
    open var width: Int?
    open var height: Int?
    open var sortIndex: Int?
    open var publishedDate: String?
    open var actionType: PoqPageType?
    open var actionParameter: String?
    open var isFeatured: Bool?
    open var categoryType: String?
    open var showOnFirstLaunchOnly: Bool?
    open var paddingLeft: Int?
    open var paddingRight: Int?
    open var paddingTop: Int?
    open var paddingBottom: Int?    
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        body <- map["body"]
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
        sortIndex <- map["sortIndex"]
        publishedDate <- map["publishedDate"]
        actionType <- map["actionType"]
        actionParameter <- map["actionParameter"]
        isFeatured <- map["isFeatured"]
        categoryType <- map["categoryType"]
        showOnFirstLaunchOnly <- map["showOnFirstLaunchOnly"]
        paddingLeft <- map["paddingLeft"]
        paddingRight <- map["paddingRight"]
        paddingTop <- map["paddingTop"]
        paddingBottom <- map["paddingBottom"]
    }
}
