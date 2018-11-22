//
//  UIApplication.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/07/2016.
//
//

import Foundation
import PoqUtilities
import UIKit

extension UIApplication {
    @nonobjc
    var bundleIdentifier: String {

        guard let appDelegate: NSObjectProtocol =  UIApplication.shared.delegate,
            let bundleId: String = Bundle(for: type(of: appDelegate)).bundleIdentifier else {
                Log.error("We were unable to get bundle id form running app!!!")
                return ""
        }
        
        return bundleId
    }
    
}

