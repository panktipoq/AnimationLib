//
//  SettingsTypeExtension.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities

/**
 * Describe additional functionality, serve to help work with response from API
 */
extension PoqSettingsType {
    
    public var appConfiguration: AppConfiguration? {
        return PoqSettingsType.appConfigurationForType(self)
    }

    /// we will return here only supported settings
    static let allSettingTypes: [PoqSettingsType] = [.localization, .theme, .config]
    
    /**
     We got response from server with Map: [Key: SettingsArray]
     Lets keep in one place all mapping of SettingsType and response
     */
    static public func settingTypeForJsonKey(_ key: String) -> PoqSettingsType? {
        
        var res: PoqSettingsType?
        switch key {
        case "localization":
            res = PoqSettingsType.localization

        case "theme":
            res = PoqSettingsType.theme

        case "config":
            res = PoqSettingsType.config

        default:
            Log.warning("We are trying to pass unknown settings. key = \(key)")
        }
        
        return res
    }
    
    static public func appConfigurationForType(_ settingsType: PoqSettingsType) -> AppConfiguration? {
        
        let res: AppConfiguration
        switch settingsType {
        case .localization:
            res = AppLocalization.sharedInstance
            
        case .theme:
            res = AppTheme.sharedInstance
            
        case .config:
            res = AppSettings.sharedInstance
        }
        
        return res
    }
    
    static public func typeResponseMapFromSplash(_ poqSplash: PoqSplash) -> [PoqSettingsType: [PoqSetting]] {
        return [.localization: poqSplash.localization ?? [],
                .theme: poqSplash.theme ?? [],
                .config: poqSplash.config ?? []]
    }
}

