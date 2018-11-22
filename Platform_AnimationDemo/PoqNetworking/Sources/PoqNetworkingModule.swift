//
//  PoqNetworkingModule.swift
//  Poq.iOS.Platform
//
//  Created by Joshua White on 14/09/2017.
//
//

import Foundation
import PoqModuling

public class PoqNetworkingModule: PoqModule {

    public init() {
    }

    public func apply(settings: [PoqSettingsType: [PoqSetting]]) {
        if let configs = settings[.config] {
            NetworkSettings.shared.update(with: configs)
        }
    }
    
}
