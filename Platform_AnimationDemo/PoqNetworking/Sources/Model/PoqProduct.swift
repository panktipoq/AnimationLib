//
//  PoqProduct.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqModuling

/// Protocol to which the products need to conform
public protocol Product {
    
    var title: String? { get }
    var thumbnailUrl: String? { get }
    
    var productSizes: [PoqProductSize]? { get }
    
    var price: Double? { get }
    var specialPrice: Double? { get }
}

/// The main product object in the Poqplatform
open class PoqProduct: Mappable, PoqTrackingProduct, Product {
    
    /// The id of the product
    public final var id: Int?
    
    /// The title of the product
    public final var title: String?
    
    /// The body of the product TODO: What do we use the body for?
    public final var body: String?
    
    /// The description of the product
    public final var description: String?
    
    /// The price of the product
    public final var price: Double?
    
    /// The promotion or special price of the product
    public final var specialPrice: Double?
    
    /// The video url of the product
    public final var videoURL: String?
    
    /// The product's picture url
    public final var pictureURL: String?
    
    /// The order index, used for sorting
    public final var sortIndex: String?
    
    /// The product's picture width
    public final var pictureWidth: Int?
    
    /// The product's picture height
    public final var pictureHeight: Int?
    
    /// The product's thumbnail url
    public final var thumbnailUrl: String?
    
    /// The product's thumbnail width
    public final var thumbnailWidth: Int?
    
    /// The product's thumbnail height
    public final var thumbnailHeight: Int?
    
    /// Check to see if the product is favorited or not
    public final var isFavorite: Bool?
    
    /// The number of likes the product has received
    public final var numberofLikes: Int?
    
    /// The number of reviews the product has received
    public final var numberOfReviews: Int?
    
    /// The related product ids. We use this to render a grouped list
    public final var relatedProductIDs: [Int]?
    
    /// The bundle id of the product in case the product is actually a multi product
    public final var bundleId: String?
    
    /// The product's sizes
    public final var productSizes: [PoqProductSize]?
    
    /// The pictures of the product
    public final var productPictures: [PoqProductPicture]?
    
    /// The colors available for the product
    public final var productColors: [PoqProductColor]?
    
    /// In case there's a reward system in place, 
    public final var productRewardDetails: PoqProductRewardDetails?
    
    /// The product's external. TODO: I rememeber a recomandation about this being needed in all product requests
    public final var externalID: String?
    
    /// The product's web url
    public final var productURL: String?
    
    /// The selected color of the product
    public final var color: String?
    
    /// TODO: We are not using this anywhere in the platform
    public final var colorGroupId: String?
    
    /// Check to see if the product has more color
    public final var hasMoreColors: Bool?
    
    /// The url of the color swatch
    public final var colorSwatchUrl: String?
    
    /// The product's brand
    public final var brand: String?
    
    /// The product's promotion text
    public final var promotion: String?
    
    /// The product's size guide
    public final var sizeGuide: String?
    
    /// TODO: This is not used anywhere in the platform
    public final var returns: String?
    
    /// TODO: Not used in the platform
    public final var delivery: String?
    
    /// TODO: Not used in the platform
    public final var style: String?
    
    /// TODO: Not used in the platform
    public final var rating: Double?
    
    /// Text displayed in the bag if international delivery is available
    public final var internationalDelivery: Bool?
    
    /// Text displayed in the bag if home delivery is available
    public final var homeDelivery: Bool?
    
    /// Text displayed in the bag if buy and collect is available
    public final var buyAndCollect: Bool?
    
    /// Displayed in the product availablity cell if the product is available in store or not
    public final var isAvailableInStore: Bool?
    
    /// The product's selected size id
    public final var selectedSizeID: Int?
    
    /// The product's selected size name
    public final var selectedSizeName: String?
    
    /// Block object if the product needs to have a header displayed (ex. a block showing the brand)
    public final var headerImage: PoqBlock?
    
    /// Wether or not the promotion text receives tap gestures. TODO: The naming is faulty we should rename this to something clearer
    public final var isBadge: Bool?
    
    /// The selected product's color id
    public final var selectedColorProductID: Int?
    
    /// Used to format the price by using createPriceLabelText method in LabelStyleHelper
    public final var priceRange: String?
    
    /// Used to format the special price by using createPriceLabelText method in LabelStyleHelper
    public final var specialPriceRange: String?
    
    /// TODO: This flag seems to be set from appsettings
    public final var isClearance: Bool?
    
    /// TODO: This is not used in the platform
    public final var reviewProductCode: String?
    
    /// The external ids of the related products
    public final var relatedExternalProductIDs: [String]?
    
    /// Check wether the product is in stock. We treat isInStock == nil as isInStock == true. TODO: The nil approach is faulty most devs will think nil is false
    public final var isInStock: Bool?
    
    /// Method returning if the product is in stock or not. Use this for a reliable result instead of isInStock
    ///
    /// - Returns: If the product is in stock or not
    public func isOutOfStock() -> Bool {
        if let existedIsInStock = isInStock, !existedIsInStock {
            return true
        }
        
        return false
    }
    
    // 
    // 
    
    /// Check if the product is available. TODO: remove it eventually. In UAT this variable already moved to BagItem. We treat isAvailable == nil as isAvailable == true
    fileprivate var isAvailable: Bool?
    
    /// Check to see if the product is available or not
    ///
    /// - Returns: Wether the product is available or not
    public func isUnavailable() -> Bool {
        if let existedIsUnavailable = isAvailable, !existedIsUnavailable {
            return true
        }
        
        return false
    }
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        brand <- map["brand"]
        body <- map["body"]
        description <- map["description"]
        sortIndex <- map["sortIndex"]
        delivery <- map["delivery"]
        returns <- map["returns"]
        sizeGuide <- map["sizeGuide"]
        rating <- map["rating"]
        price <- map["price"]
        specialPrice <- map["specialPrice"]
        videoURL <- map["videoUrl"]
        pictureURL <- map["url"]
        pictureWidth <- map["width"]
        pictureHeight <- map["height"]
        thumbnailUrl <- map["thumbnailUrl"]
        thumbnailWidth <- map["thumbnailWidth"]
        thumbnailHeight <- map["thumbnailHeight"]
        isFavorite <- map["isFavorite"]
        numberofLikes <- map["numberofLikes"]
        numberOfReviews <- map["numberOfReviews"]
        isAvailableInStore <- map["isAvailableInStore"]
        selectedSizeID <- map["selectedSizeID"]
        selectedSizeName <- map["selectedSizeName"]
        productSizes <- map["productSizes"]
        productPictures <- map["productPictures"]
        productColors <- map["productColors"]
        productRewardDetails <- map["reward"]
        relatedProductIDs <- map["relatedProductIDs"]
        externalID <- map["externalID"]
        productURL <- map["productURL"]
        color <- map["color"]
        colorGroupId <- map["colorGroupID"]
        hasMoreColors <- map["hasMoreColors"]
        colorSwatchUrl <- map["colorSwatchUrl"]
        style <- map["style"]
        promotion <- map["promotion"]
        internationalDelivery <- map["internationalDelivery"]
        homeDelivery <- map["homeDelivery"]
        buyAndCollect <- map["buyAndCollect"]
        bundleId <- map["bundleID"]
        isInStock <- map["isInStock"]
        headerImage <- map["headerImage"]
        isBadge <- map["isBadge"]
        priceRange <- map["priceRange"]
        specialPriceRange <- map["specialPriceRange"]
        isClearance <- map["isClearance"]
        reviewProductCode <- map["reviewProductCode"]
        relatedExternalProductIDs <- map["relatedExternalProductIDs"]
    }
}
