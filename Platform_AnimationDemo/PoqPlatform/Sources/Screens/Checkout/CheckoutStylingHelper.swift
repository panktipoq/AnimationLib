//
//  CheckoutStylingHelper.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/4/16.
//
//

import Foundation

enum CheckoutSaveButtonLocation: String {
    case Bottom = "Bottom"
    case TopRight = "TopRight"
    
    static var saveButtonLocation: CheckoutSaveButtonLocation {
        guard let saveButtonLocation = CheckoutSaveButtonLocation(rawValue: AppSettings.sharedInstance.nativeCheckoutSaveButtonLocation) else {
            return .Bottom
        }
        
        return saveButtonLocation
    }
}

