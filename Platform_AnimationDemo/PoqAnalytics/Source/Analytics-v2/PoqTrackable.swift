//
//  PoqTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

/// Tracking protocol for Providers
public protocol PoqTrackable: class {
    
    /// This method will be called once all the keys for providers have been fetched so we can initialised each one of the providers
    func initProvider()
}
