//
//  PoqSplash.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqModuling

open class PoqSplash : Mappable {

    open var localization: [PoqSetting]?
    open var theme: [PoqSetting]?
    open var config: [PoqSetting]?
    open var plugIn: [PoqSetting]?
    open var network: [PoqSetting]?
    open var gatekeeper: [PoqSetting]?
    open var bagItemCount: Int?
    open var wishlistCount: Int?

    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        localization <- map["localization"]
        theme <- map["theme"]
        config <- map["config"]
        plugIn <- map["plugIn"]
        network <- map["network"]
        gatekeeper <- map["gatekeeper"]
        bagItemCount <- map["bagItemCount"]
        wishlistCount <- map["wishlistCount"]
    }
}
