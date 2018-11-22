//
//  ProductDetailAnimator.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit

/*
 ProductDetailAnimator is responsible to start PDP animations
 
 startAddToBagAnimation()
    This will create the instance of PDPAddToBagAnimatorView and will add it on window
    This will pass the settings and completion to the PDPAddToBagAnimatorView and start the animation
 */

struct ProductDetailAnimator {
    
    static func startAddToBagAnimation(with settings: PDPAddToBagAnimatorViewSettings,
                               completion:@escaping AnimClosure) {
        
        let addToBagAnimatorView = PDPAddToBagAnimatorView(frame: UIScreen.main.bounds)
        guard  let window = UIApplication.shared.keyWindow else {
            fatalError("window not found")
        }
        window.addSubview(addToBagAnimatorView)
        addToBagAnimatorView.startAnimation(with: settings,
                                            completion: completion)
        
    }
    static  func stopAddToBagAnimation() {
        PDPAddToBagAnimatorView.stopAnimation()
    }
    
}
