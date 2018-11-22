//
//  MapExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 27/07/2017.
//
//

import Foundation
import ObjectMapper

extension Map {
    
    /// This is convenience API, which allow just get string value for key
    public final subscript(key: String) -> String? {
        var value: String?
        value <- self[key]
        return value
    }
}

