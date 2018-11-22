//
//  PoqNavigationViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class PoqNavigationViewController: UINavigationController {
    
    /**
     we need support branded controllers via one navigation chain
     lets keep here brand block, set it when we start flow fron brand landing, and nill when leave it
     */
    open var brandStory: PoqStory?
    
    /// Put self as deleate not a good idea usually
    var navigationControllerDelegate = PoqNavigationControllerDelegate()

    
    /// Store the first time Navigation Controller WillAppear
    var firstWillAppear: Bool = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Set up the banner
        self.navigationBar.barTintColor = AppTheme.sharedInstance.naviBarTintColor

        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.naviBarTitleColor,
                                                  NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarTitleFont]
        self.interactivePopGestureRecognizer?.delegate = self
        
        delegate = navigationControllerDelegate
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle ?? UIStatusBarStyle.default
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // To avoid setting up the Navigation bar in case the View Will Appear after a modular presented VC is dismissed.
        // Especially if the ViewController got a mechanism to also change the colour of the NavBar.
        // The ViewController viewWillAppear is called before the NavBar one. So will override the result.
        if firstWillAppear == true {
            updateNavigationBarColor()
            firstWillAppear = false
        }
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        updateNavigationBarColor()
    }
    
    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let resArray: [UIViewController]? = super.popToRootViewController(animated: animated)
        updateNavigationBarColor()
        
        return resArray
    }
    
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        let resArray: [UIViewController]? = super.popToViewController(viewController, animated: animated)
        updateNavigationBarColor()
        
        return resArray
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        let resController: UIViewController? = super.popViewController(animated: animated)
        updateNavigationBarColor()
        
        return resController
    }
    
    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        updateNavigationBarColor()
    }
    
    public final func updateNavigationBarColor() {
        
        // Initial navigation Bar colours from  Client Style.
        // This Client Style set up allows any client to change the benaviour that only the first VC in the stack is handled with AppTheme.sharedInstance.naviBarTintColor.
        var navigationBarColor: UIColor = ResourceProvider.sharedInstance.clientStyle?.rootVCNavBarColor ?? .white
        var statusBarStyle: UIStatusBarStyle? = ResourceProvider.sharedInstance.clientStyle?.rootVCStatusBarStyle
        
        // If is the first VC in the NavController stack use AppTheme.sharedInstance.naviBarTintColor.
        // Second and following VCs will be handle through Client Style. White navigationBar is the default one.
        if self.presentingViewController == nil && self.viewControllers.count < 2 {
            
            navigationBarColor = AppTheme.sharedInstance.naviBarTintColor
            statusBarStyle = UIStatusBarStyle.statusBarStyle(PoqStatusBarStyle(rawValue: AppSettings.sharedInstance.statusBarStyle))
        }
        
        UIApplication.shared.statusBarStyle = statusBarStyle ?? .default
        self.navigationBar.barTintColor = navigationBarColor
        self.navigationBar.isTranslucent = ResourceProvider.sharedInstance.clientStyle?.rootVCIsTranslucent ?? true
    }
}

extension PoqNavigationViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.viewControllers.count > 1
    }
}
