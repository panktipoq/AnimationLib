//
//  PoqNavigationControllerDelegate.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/6/17.
//
//

import Foundation
import UIKit

public class PoqNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, 
                                     animationControllerFor operation: UINavigationControllerOperation, 
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        // here we will check does presenting/dismissing vc is adopting UIViewControllerAnimatedTransitioning
        switch operation {
        case .pop:
            return fromVC as? UIViewControllerAnimatedTransitioning

        case .push:
            return toVC as? UIViewControllerAnimatedTransitioning

        default:
            return nil
        }
    }
}
