//
//  NetworkSettings.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 7/17/17.
//
//

import Foundation
import PoqModuling

public enum AuthenticationType: Double {
    
    case password = 1
    case oAuth = 2
}

public enum ProductListFiltersType: Double {
    
    case `static` = 1 // - api/Products/Filter implementation
    case dynamic = 2 // - api/Products/FilterV2 implementation
}

public class NetworkSettings: NSObject, AppConfiguration {
    
    public static let shared = NetworkSettings()
    
    public let configurationType: PoqSettingsType = .config
    
    // Authentication Type
    // 1: Password authentication for DW, Magento
    // 2: OAuth for Poq Core Shopping
    @objc public var authenticationType = AuthenticationType.password.rawValue
    
    @objc public var productListFilterType = ProductListFiltersType.static.rawValue
    
    @objc public var userAgent = "" // Cloud
    
    @objc public var editMyProfileDefaultYear = "1901"
    @objc public var signUpPromotionToggleButtonDefaultValue = true
    @objc public var signUpDataShareToggleButtonDefaultValue = false
    @objc public var isUpdatingBirthdateEnabled = false
}
