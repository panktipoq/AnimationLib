//
//  PoqBlock.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

public enum PoqBlockType: Int {
    
    case title = 1
    case link = 2
    case actionButton = 3
    case seperator = 4
    case landing = 5
    case welcome = 6
    case banner = 7
    case brandHeader = 8
    case card = 9
    case promotionBanner = 10
    case favouriteStore = 11
    case description = 12
}

public enum PoqBlockCategory: Int {
    
    case myProfile = 1
    case home = 2
    case productList = 3
    case shop = 4
    case story = 5
}

open class PoqBlock : Mappable {

    open var type: PoqBlockType?
    open var category: PoqBlockCategory?

    open var title: String?
    open var link: String?
    open var pictureURL: String?
    
    open var description: String?

    open var isAvailableForLoggedIn: Bool?
    open var isAvailableForLoggedOut: Bool?

    open var pictureWidth: Int = 0
    open var pictureHeight: Int = 0
    
    // used with BrandHeader
    open var headerHeight: Int?
    
    open var backgroundColor: UIColor = UIColor.black

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        title <- map["title"]
        link <- map["link"]
        type <- map["type"]
        pictureURL <- map["pictureURL"]
        isAvailableForLoggedIn <- map["isAvailableForLoggedIn"]
        isAvailableForLoggedOut <- map["isAvailableForLoggedOut"]
        category <- map["category"]
        pictureWidth <- map["width"]
        pictureHeight <- map["height"]
        
        description <- map["description"]
        
        var hexColorString: String?
        hexColorString <- map["backgroundColour"]
        
        if let validHexColor = hexColorString {
            backgroundColor = UIColor.hexColor(validHexColor)
            
        }
        
        headerHeight <- map["headerHeight"]
    }
}

