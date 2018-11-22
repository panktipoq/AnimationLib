//
//  PoqBaseViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

// Used in a tableView content array to decide
// which custom cell implementation to use via dequeueReusableCellWithIdentifier method
public struct TableViewContent {
    
    public var identifier: String
    public var height: CGFloat
    
    public init(identifier: String, height: CGFloat) {
        self.identifier = identifier
        self.height = height
    }

}

open class BaseViewModel : BaseViewModelProtocol, PoqNetworkTaskDelegate {
    
    // The view controller that is using this view model
    open weak var viewControllerDelegate: PoqBaseViewController?
    
    // Activity indicator to be shown during network operation
    // material desing loading indicator
    public final var spinnerView: PoqSpinner? {
        didSet {
            spinnerView?.tintColor = AppTheme.sharedInstance.mainColor
        }
    }
    
    /**
    Alternative init for removing dependency on viewControllerDelegate
    This enables initializing viewModel in class definition to avoid optinals
    and less boilerplate code in test classes
    */
    public init() {
    }
    
    /**
    Create a new view model
    
    - parameter viewControllerDelegate: ViewController that is using this view model
    */
    public init(viewControllerDelegate: PoqBaseViewController) {
        self.viewControllerDelegate = viewControllerDelegate
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        startSpinnerViewAnimation()
    }

    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        stopSpinnerViewAnimation()
    }
    
    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        stopSpinnerViewAnimation()
    }

    // MARK: Loading indicator
    
    open func startSpinnerViewAnimation() {
        if spinnerView == nil {
            spinnerView = PoqSpinner(frame: CGRect(x: 0, y: 0, width: CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension), height: CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension)))
        }
        
        // Why we need 'isViewLoaded' check: initially in tab bar we have 5 controllers. Some of them makes API call in init
        // It mean, even if we didn't really select tab with some VC, its view will loaded
        // In case of Bag view it may trigger ask about notification registration, which breaks whole idea of delaying it
        if let spinnerView = spinnerView, let viewControllerDelegate = viewControllerDelegate, viewControllerDelegate.isViewLoaded {
            viewControllerDelegate.view.addSubview(spinnerView)
            
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            spinnerView.applyCenterPositionConstraints()
        }
        
        // Start animating
        spinnerView?.startAnimating()
    }

    open func stopSpinnerViewAnimation() {
        spinnerView?.stopAnimating()
        spinnerView?.removeFromSuperview()
    }
}
