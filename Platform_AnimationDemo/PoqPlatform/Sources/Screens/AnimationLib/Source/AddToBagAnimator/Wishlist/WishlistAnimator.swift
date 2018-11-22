//
//  WishlistAnimator.swift
//  Poq.iOS.Platform
//
//  Created by Pankti Patel on 21/11/2018.
//

import Foundation


struct WishlistAnimator {
    
    static func startAddToBagAnimation(with settings: WishlistAddToBagAnimatorViewSettings,
                                       completion:@escaping AnimClosure) {
        
        let addToBagAnimatorView = WishlistAddToBagAnimatorView(frame: UIScreen.main.bounds)
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
