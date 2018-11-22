//
//  PoqPostRefreshToken.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/08/2016.
//
//

import Foundation
import ObjectMapper

/// Wrapper used for the refresh token request
open class PoqPostRefreshToken: Mappable {

   /// The refresh token
   open var refreshToken: String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        refreshToken <- map["refreshToken"]
    }

}

