//
//  UIViewControllerContextTransitioningSearchExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/6/17.
//
//

import Foundation

extension UIViewControllerContextTransitioning {
    
    @nonobjc
    var isSearchPresentingTransition: Bool {
        let toViewController = viewController(forKey: .to) as? SearchController
        return toViewController != nil 
    }
    
}
