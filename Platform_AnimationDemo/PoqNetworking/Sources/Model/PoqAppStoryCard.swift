//
//  PoqAppStoryCard.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 27/07/2017.
//
//

import Foundation
import ObjectMapper
import PoqModuling
import PoqUtilities

public enum AppStoryCardMediaType {
    case image
    case gif
}

public enum AppStoryCardType {
    case `default`
    case products([PoqProductID])
    case video(URL)
    case weblink(URL)
}

// Stories API returns us too few information, so need only ids form it to fetch later full info
public struct PoqProductID: Mappable {
    
    public let internalProductId: Int
    public let externalProductId: String
    
    public init(internalProductId: Int, externalProductId: String) {
        self.internalProductId = internalProductId
        self.externalProductId = externalProductId
    }
    
    public init?(map: Map) {
        var idOrNil: Int?
        idOrNil <- map["id"]
        
        var externalIdOrNil: String?
        externalIdOrNil <- map["externalID"]
        
        guard let internalProductId = idOrNil, let externalProductId = externalIdOrNil else {
            return nil
        }
        
        self.internalProductId = internalProductId
        self.externalProductId = externalProductId
    }
    
    public func mapping(map: Map) {
        guard map.mappingType == .toJSON else {
            return
        }
        
        internalProductId >>> map["id"]
        externalProductId >>> map["externalID"]
    }
}



public struct PoqAppStoryCard: Mappable {
    
    public let identifier: String
    public let mediaUrl: URL
    
    public let mediaType: AppStoryCardMediaType
    
    public var duration: Double?
    public var title: String?
    public var actionLabelText: String?
    
    public var productIds = [PoqProductID]()
    public var videoUrl: URL?
    public var weblink: URL?
    
    public var type: AppStoryCardType = .default
    
    public init?(map: Map) {
        
        /// We can't use card without id and image url, so lets validate these 2 fields
        guard let identifier: String = map["identifier"],
            let imageUrlString: String = map["imageUrl"],
            let imageUrl = URL(string: imageUrlString) else {
                Log.error("We didn't able to parse identifier or imageUrl")
                return nil
        }

        if imageUrl.absoluteString.contains(".gif") {
            mediaType = .gif
        } else {
            mediaType = .image
        }

        self.identifier = identifier
        self.mediaUrl = imageUrl
    }
    
    // Mappable
    public mutating func mapping(map: Map) {
        duration <- map["duration"]
        title <- map["title"]
        
        productIds <- map["products"]
        
        actionLabelText <- map["actionLabel"]

        videoUrl <- (map["videoUrl"] as Map, URLTransform())
        weblink <- (map["url"] as Map, URLTransform())
        
        guard map.mappingType == .fromJSON else {
            return
        }

        var typeString: String = ""
        typeString <- map["type"]
        
        switch typeString {
        case "Product":
            guard productIds.count > 0 else {
                Log.error("We found product card type without products id")
                break
            }
            type = .products(productIds)

        case "Video":
            guard let videoUrlUnwrapped = videoUrl else {
                Log.error("We found video card, but no video URL")
                break
            }
            type = .video(videoUrlUnwrapped)
            
        case "Weblink":
            guard let weblinkUnwrapped = weblink else {
                Log.error("We found weblink card, but no url in")
                break
            }
            type = .weblink(weblinkUnwrapped)
            
            break
        default:
            type = .default
            break
        }
    }
    
}


