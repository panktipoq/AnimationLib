//
//  StoreDistanceMileFormatter.swift
//  PoqPlatform
//
//  Created by Joshua White on 02/11/2018.
//

import Foundation

public struct StoreDistanceMileFormatter: StoreDistanceFormatter {
    
    public var sourceUnit: UnitLength
    
    public init(sourceUnit: UnitLength) {
        self.sourceUnit = sourceUnit
    }
    
    public func formattedDistance(_ distance: Double) -> String {
        let distanceInMiles = Measurement(value: distance, unit: sourceUnit).converted(to: .miles).value
        return String(format: "%.2f", distanceInMiles)
    }
    
    public func formattedUnit(forDistance distance: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        return formatter.string(from: UnitLength.miles).capitalized
    }
    
}
