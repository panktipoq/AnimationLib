//
//  PoqPage.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper

/// The type of page that needs to be opened. TODO: This page system seems convoluted as why do we require it ?

public enum PoqPageType: String {
    case None           = ""
    case Subpages       = "subpages"
    case Page           = "page"
    case pageDetail     = "pagedetail"
    case Category       = "category"
    case BrandedCategory = "brandedCategory"
    case Subcategory    = "subcategories"
    case Link           = "link"
    case Shop           = "shop"
    case StoreFinder    = "storefinder"
    case Separator      = "separator"
    case MyStore        = "mystore"
    case Lookbook       = "lookbook"
    case Wishlist       = "wishlist"
    case CategoryHub    = "categoryhub"
    case RecentProducts = "recentlyviewed"
    case MyProfile      = "myprofile"
    case Header         = "header"
    case Scan           = "scan"
    case MySizes        = "mysizes"
    case SelectMySizes  = "selectmysizes"
    case SelectMyStore  = "selectmystore"
    case Brands         = "brands"
    case Layar          = "layar"
    case SignUp         = "signup"
}

open class PoqPage : Mappable {
    
    open var id: Int?
    open var title: String?
    open var brandId: String?
    open var brandName: String?
    open var body: String?
    open var url: String?
    open var width: Int?
    open var height: Int?
    open var sortIndex: Int?
    open var parentID: Int?
    open var thumbnailUrl: String?
    open var thumbnailWidth: Int?
    open var thumbnailHeight: Int?
    open var publishedDate: String?
    open var actionType: String?
    open var actionParameter: String?
    open var actionTitle: String?
    open var categoryType: String?
    open var pageType: PoqPageType?
    open var pageParameter: String?
    open var subPages: [PoqPage]?
    open var iconUrl: String?
    open var iconWidth: Int?
    open var iconHeight: Int?
    open var iconThumbnailUrl: String?
    open var iconThumbnailWidth: Int?
    open var iconThumbnailHeight: Int?

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
        parentID <- map["parentID"]
        thumbnailUrl <- map["thumbnailUrl"]
        thumbnailWidth <- map["thumbnailWidth"]
        thumbnailHeight <- map["thumbnailHeight"]
        brandId <- map["brandId"]
        publishedDate <- map["publishedDate"]
        actionType <- map["actionType"]
        actionParameter <- map["actionParameter"]
        actionTitle <- map["actionTitle"]
        categoryType <- map["categoryType"]
        pageType <- map["pageType"]
        pageParameter <- map["pageParameter"]
        subPages <- map["subPages"]
        
        iconUrl <- map["iconUrl"]
        iconWidth <- map["iconWidth"]
        iconHeight <- map["iconHeight"]
        iconThumbnailUrl <- map["iconThumbnailUrl"]
        iconThumbnailWidth <- map["iconThumbnailWidth"]
        iconThumbnailHeight <- map["iconThumbnailHeight"]

    }
}
