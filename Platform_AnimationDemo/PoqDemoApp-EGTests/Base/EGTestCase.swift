//
//  EGTestCase.swift
//  PoqDemoApp-EGTests
//
//  Created by Joshua White on 29/09/2017.
//

import UIKit
import XCTest

@testable import PoqModuling
@testable import PoqPlatform

open class EGTestCase: XCTestCase {
    
    override open class func setUp() {
        MockServer.reset()
        
        // Disable onboarding and notification permission request.
        UserDefaults.standard.set(true, forKey: OnboardingShownStatusDefaultsKey)
    }
    
    override open class func tearDown() {
        MockServer.reset()
    }
    
    override open func setUp() {
        super.setUp()
        
        // Try to guarentee that there are no keyboards open.
        UIApplication.shared.delegate?.window??.endEditing(true)
        
        // Dismiss happens on next run loop, which lead to issues with view controllers hierarchy
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: false)
        
        // So we dismiss and wait a little bit
        wait(forDuration: 0.05)
    }
    
    /// Replaces the current application's rootViewController with the specified viewController for testing.
    /// - parameter viewController: The view controller to test.
    public final func insertViewController(_ viewController: UIViewController) {
        UIApplication.shared.delegate?.window??.endEditing(true)
        UIApplication.shared.delegate?.window??.rootViewController = viewController
    }
    
    /// Replaces the current application's rootViewController with a NavigationController loaded with the specified viewController.
    /// - parameter viewController: The view controller to test.
    public final func insertNavigationController(withViewController viewController: UIViewController) {
        UIApplication.shared.delegate?.window??.endEditing(true)
        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.shared.delegate?.window??.rootViewController = navigationController
        NavigationHelper.sharedInstance.setupNavigation(navigationController)
        NavigationHelper.sharedInstance.setUpTopMostViewController(viewController)
    }
    
    /// Inserts the initial responses into the MockServer.
    /// E.g. a default Splash Response.
    open func insertInitialResponses() {
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "Splash", inBundle: "EGTestCase")
    }
    
    /// Replaces the current application's rootViewController with the initialViewController.
    open func insertInitialViewController() {
        guard let initialViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.splash.rawValue) else {
            GREYFail("Initial View Controller should not be nil.")
            return
        }
        
        if initialViewController is UINavigationController {
            insertViewController(initialViewController)
        } else {
            insertNavigationController(withViewController: initialViewController)
        }
    }
    
}
