//
//  UIImageExtension.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/07/2018.
//

import UIKit
import PoqPlatform

extension UIImage {
    
    /// The variable returns a UIImage instance with logo image named "navigationBarLogo" found in the bundle of the last module added to PoqModule
    public static var logo: UIImage? {
        return ImageInjectionResolver.loadImage(named: "navigationBarLogo")
    }
}
