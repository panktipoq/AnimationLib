//
//  StoreDistanceLegacyFormatter.swift
//  PoqPlatform
//
//  Created by Joshua White on 02/11/2018.
//

import Foundation

public struct StoreDistanceLegacyFormatter: StoreDistanceFormatter {
    
    public init() {
    }
    
    public func formattedDistance(_ distance: Double) -> String {
        return String(format: "%.2f", distance)
    }
    
    public func formattedUnit(forDistance distance: Double) -> String {
        return AppLocalization.sharedInstance.lengthUnit
    }
    
}
