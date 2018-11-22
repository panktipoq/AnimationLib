//
//  SheetNavigationControllerAnimatedTransition.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/8/17.
//
//

import Foundation
import PoqUtilities
import UIKit

public final class SheetNavigationControllerAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let isPresenting: Bool
    
    /// - parameter presenting: true if presenting, false for dismissing
    public init(presenting: Bool) {
        isPresenting = presenting
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let sheetVCKey: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        let otherVCKey: UITransitionContextViewControllerKey = isPresenting ? .from : .to 
        
        guard let sheetContainerViewController = transitionContext.viewController(forKey: sheetVCKey) as? SheetContainerViewController else {
            Log.error("Unexpected type type of 'to' view controller")
            transitionContext.completeTransition(false)
            return
        }
        
        let otherViewController = transitionContext.viewController(forKey: otherVCKey)

        transitionContext.containerView.addSubview(sheetContainerViewController.view)
        sheetContainerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraintsForView(sheetContainerViewController.view, withInsetsInContainer: UIEdgeInsets.zero)
        NSLayoutConstraint.activate(constraints)
        
        UIView.performWithoutAnimation {
            sheetContainerViewController.view.layoutIfNeeded()
        }
        
        if isPresenting {
            
            NSLayoutConstraint.deactivate(sheetContainerViewController.hiddenStateConstraints)
            sheetContainerViewController.inSheetNavigationControllerTopConstraint?.isActive = true
        } else {
            
            sheetContainerViewController.inSheetNavigationControllerTopConstraint?.isActive = false
            NSLayoutConstraint.activate(sheetContainerViewController.hiddenStateConstraints)
            
        }

        otherViewController?.beginAppearanceTransition(!isPresenting, animated: true)
        sheetContainerViewController.beginAppearanceTransition(isPresenting, animated: true)

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: { 
            let effect = self.isPresenting ? sheetContainerViewController.blurEffect : nil
            sheetContainerViewController.blurEffectView.effect = effect 
            sheetContainerViewController.view.layoutIfNeeded()
        }) { 
            (finished: Bool) in
            
            transitionContext.completeTransition(true)
            
            otherViewController?.endAppearanceTransition()
            sheetContainerViewController.endAppearanceTransition()
        }
    }
}


