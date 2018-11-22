//
//  PoqAppStory.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 27/07/2017.
//
//

import Foundation
import PoqModuling
import PoqUtilities
import ObjectMapper

public struct PoqAppStory: Mappable {
    
    public var shouldAutoplay: Bool = false
    public var cards = [PoqAppStoryCard]()
    public var title: String?
    
    public var identifier: String
    public var imageUrl: URL

    public init?(map: Map) {
        
        /// We can't use card without id and image url, so lets validate these 2 fields
        guard let identifier: String = map["identifier"],
            let imageUrlString: String = map["imageUrl"],
            let imageUrl = URL(string: imageUrlString) else {
                Log.error("We didn't able to parse identifier or imageUrl")
                return nil
        }
        
        self.identifier = identifier
        self.imageUrl = imageUrl
    }
    
    // Mappable
    public mutating func mapping(map: Map) {
        
        cards <- map["cards"]
        title <- map["title"]
        shouldAutoplay <- map["autoplay"]
    }
}
