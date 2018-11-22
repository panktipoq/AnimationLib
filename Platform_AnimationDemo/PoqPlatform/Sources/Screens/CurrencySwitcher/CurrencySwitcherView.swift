//
//  CurrencySwitcherView.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 30/05/2018.
//

import Foundation

/// Protocol that describes currency switcher cell setup.
/// Client needs to conform to this protocol if want to provide their own cell implementation.
protocol CurrencySwitcherView {
    
    /// Configures view with provided currency object.
    func setup(currency: Currency)
}
