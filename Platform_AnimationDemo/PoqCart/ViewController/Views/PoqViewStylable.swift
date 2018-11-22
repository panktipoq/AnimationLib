//
//  PoqViewStylable.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/07/2018.
//

import UIKit

/// This protocol represents a concrete type that can be styled as a PoqView
public protocol PoqViewStylable {
    
    func styleNavigationBar()
}

extension PoqViewStylable where Self: UIViewController {
    
    /// This method styles the navigation bar of the conforming UIViewController subclass to the default Poq style
    public func styleNavigationBar() {
        
        let titleView = UIImageView(image: UIImage.logo)
        titleView.contentMode = .scaleAspectFit

        navigationItem.titleView = titleView
    }
}
