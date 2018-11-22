//
//  PoqPromotionBlock.swift
//  Poq.iOS.Missguided
//
//  Created by Konstantin Bakalov on 4/18/17.
//
//

import UIKit
import ObjectMapper

/// The type of promotion that the block points to 
///
/// - deeplink: Deep link to a particular section of the app
/// - promotionCode: displays a promotion code in the block
public enum PoqPromotionBlockType: Int {
    case deeplink = 1
    case promotionCode
}

/// Object containing promotion information and styling
public class PoqPromotionBlock: PoqBlock {
    
    /// The font family of the promotion title
    public var titleFontFamily: String?
    
    /// The font family of the promotion description
    public var descriptionFontFamily: String?
    
    /// The font size of the promotion title
    public var titleFontSize: Int?
    
    /// The font size of the promotion description
    public var descriptionFontSize: Int?
    
    /// The height of the block
    public var height: CGFloat?
    
    /// The promotion code
    public var promotionCode: String?
    
    /// The promotion deep link url
    public var promotionPath: String?
    
    /// The type of block to be rendered
    public var promotionBlockType: PoqPromotionBlockType?
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    override public func mapping(map: Map) {
        super.mapping(map: map)
        description <- map["description"]
        titleFontFamily <- map["titleFontFamily"]
        descriptionFontFamily <- map["descriptionFontFamily"]
        titleFontSize <- map["titleFontSize"]
        descriptionFontSize <- map["descriptionFontSize"]
        height <- map["height"]
        promotionCode <- map["promotionCode"]
        promotionBlockType <- map["promotionBlockType"]
        promotionPath <- map["promotionPath"]
    }
    
}

