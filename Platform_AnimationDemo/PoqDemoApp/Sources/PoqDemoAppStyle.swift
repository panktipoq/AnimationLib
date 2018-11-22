//
//  PoqDemoAppStyle.swift
//  Poq.iOS.Platform
//
//  Created by Rachel McGreevy on 28/07/2017.
//
//

import UIKit
import PoqPlatform

public class PoqDemoAppStyle: ClientStyleProvider {
    
    public func getLogoView (forFrame frame: CGRect) -> UIView? {
        let logoImageView = UIImageView(frame: frame)
        logoImageView.image = UIImage(named: "navigationBarLogo")
        logoImageView.contentMode = .scaleAspectFit
        
        return logoImageView
    }
}
