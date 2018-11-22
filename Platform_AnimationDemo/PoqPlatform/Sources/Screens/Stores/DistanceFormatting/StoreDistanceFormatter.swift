//
//  StoreDistanceFormatter.swift
//  PoqPlatform
//
//  Created by Joshua White on 02/11/2018.
//

import Foundation

public protocol StoreDistanceFormatter {
    
    /// The distance string for UILabels to display in a client formatted way.
    func formattedDistance(_ distance: Double) -> String
    
    /// The unit string for UILabels to display in a client formatted way.
    func formattedUnit(forDistance distance: Double) -> String
    
}
