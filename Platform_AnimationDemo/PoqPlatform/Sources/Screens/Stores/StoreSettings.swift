//
//  StoreSettings.swift
//  PoqPlatform
//
//  Created by Joshua White on 02/11/2018.
//

import Foundation

public enum StoreSettings {
    
    /// The distance formatter used by store cells.
    public static var distanceFormatter: StoreDistanceFormatter = {
        if !Locale.current.usesMetricSystem || Locale.current.identifier == "en_GB" {
            // In the UK we prefer miles instead of kilometers regardless of the metric system.
            return StoreDistanceMileFormatter(sourceUnit: .meters)
        }
        
        return StoreDistanceKilometerFormatter(sourceUnit: .meters)
    }()
    
}
