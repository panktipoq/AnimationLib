//
//  ModalyPresentedCheckout.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/16/17.
//
//

import Foundation
import StoreKit

/// Describe common API for checout view controller, which were presentd in modal way
/// We ssume that we presented inside of UINavigationController
public protocol ModalyPresentedCheckout {
    
    /// Present alert with question to user: Leave or not
    /// If 'Leave' pressed, closeNonCompletedCheckout() will be called 
    func promtUserAboutLeaveCheckout()
    
    /// Dismiss view controller, plus addition actions, specific for checkout
    /// Should be called, if user decide leave, before complete it 
    func closeNonCompletedCheckout()
    
    /// Dismiss view controller, plus addition actions, specific for checkout
    /// Calls `closeOnContinueCheckout()` to dismiss the view
    /// Should be called, if if we dismis, after user complete checkout
    func closeCompletedCheckout()
    
    /// Dismiss view controller, plus addition actions, specific for checkout
    /// Should be called, if user decide to continue checkout, before complete it
    func closeOnContinueCheckout()
}

extension ModalyPresentedCheckout where Self: PoqBaseViewController {
    
    public func promtUserAboutLeaveCheckout() {
        // Ask user for final confirmation
        let alertController = UIAlertController(title: "", message: "DO_YOU_WANT_TO_EXIT_CHEKOUT".localizedPoqString, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "DO_YOU_WANT_TO_EXIT_CHEKOUT_NO".localizedPoqString, style: UIAlertActionStyle.cancel, handler: { (alertaction: UIAlertAction) in
        }))

        alertController.addAction(UIAlertAction(title: "DO_YOU_WANT_TO_EXIT_CHEKOUT_YES".localizedPoqString, style: UIAlertActionStyle.destructive, handler: { [weak self] (alertaction: UIAlertAction) in
            self?.closeNonCompletedCheckout()
        }))

        present(alertController, animated: true)
    }

    public func closeCompletedCheckout() {
        
        // Once order is completed ask for a rating from the user
        SKStoreReviewController.requestReview()
        
        // Happy ending, just close the checkout
        closeOnContinueCheckout()
        
        // Reset Badge on BagScreen
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: 0)
    }
    
    public func closeNonCompletedCheckout() {
        
        navigationController?.dismiss(animated: true)
        NavigationHelper.sharedInstance.clearTopMostViewController()
        
        PoqTrackerHelper.trackCheckoutExit()
    }
    
    public func closeOnContinueCheckout() {
        
        navigationController?.dismiss(animated: true)
        NavigationHelper.sharedInstance.clearTopMostViewController()
        NavigationHelper.sharedInstance.loadHome()
    }
}
