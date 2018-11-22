//
//  UIStatusBarStyle.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 05/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public enum PoqStatusBarStyle: Double {
    case dark = 0
    case light = 1
}

extension UIStatusBarStyle {

    public static func statusBarStyle(_ styleOrNil: PoqStatusBarStyle?) -> UIStatusBarStyle {
        guard let style = styleOrNil else {
            return UIStatusBarStyle.default
        }

        let intValue: Int = Int(style.rawValue)
        
        guard let statusBarStyle: UIStatusBarStyle = UIStatusBarStyle(rawValue: intValue) else {
            return UIStatusBarStyle.default
        }
        
        return statusBarStyle
    }
}
