//
//  StoreDistanceKilometerFormatter.swift
//  PoqPlatform
//
//  Created by Joshua White on 02/11/2018.
//

import Foundation

public struct StoreDistanceKilometerFormatter: StoreDistanceFormatter {
    
    public var sourceUnit: UnitLength
    
    public init(sourceUnit: UnitLength) {
        self.sourceUnit = sourceUnit
    }
    
    public func formattedDistance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: sourceUnit)
        let distanceInKilometers = distanceMeasurement.converted(to: .kilometers).value
        
        if distanceInKilometers < 1 {
            let distanceInMeters = distanceMeasurement.converted(to: .meters).value.rounded()
            return String(format: "%.0f", distanceInMeters)
        } else {
            return String(format: "%.2f", distanceInKilometers)
        }
    }
    
    public func formattedUnit(forDistance distance: Double) -> String {
        let distanceInKilometers = Measurement(value: distance, unit: sourceUnit).converted(to: .kilometers).value
        let distanceUnit: UnitLength = distanceInKilometers < 1 ? .meters : .kilometers
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        return formatter.string(from: distanceUnit)
    }
    
}
