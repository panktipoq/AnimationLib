//
//  UIViewControllerExtension.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 20/04/2017.
//
//

import Foundation

public extension UIViewController {
    
    /**
     Checks if the view controlelr was presented modally.
     Returns true if view controller was presented modally, false otherwise.
     */
    @nonobjc
    public var isPresentedModally: Bool {
        
        var isModal = false
        
        if presentingViewController != nil ||
            navigationController?.presentingViewController != nil {
            
            isModal = true
        }
        
        return isModal
    }
}
