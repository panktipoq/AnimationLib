//
//  PoqBaseViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 07/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import AVFoundation
import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class PoqBaseViewController: UIViewController, RightSideMenuDelegate, ViewOwner {
    
    /// Used for tracking screens which happens on viewWillAppear.
    /// The default implementation uses reflection, replaces "ViewController" with "Screen" and adds spaces.
    open var screenName: String {
        return String(describing: type(of: self)).replacingOccurrences(of: "ViewController", with: "Screen").spaced()
    }
    
    // This var will return the name of the Xib file. The rule here is that the Xib file will be name the 
    // Same as the ViewController without the controller word
    // Therefore, for example, PoqBaseViewController will have a Xib file name PoqBaseView
    open class var XibName: String {
        var viewControllerClassName = String(describing: self)
        if let range = viewControllerClassName.range(of: "Controller") {
            viewControllerClassName.removeSubrange(range)
        }
        return viewControllerClassName
    }
    
    var pageListNavigationController: PoqNavigationViewController!

    open var alertController: UIAlertController?
    open var bagControl: (BadgedControl & BarButtonItemProvider)?
    
    /// Subclasses can change this var to false, if they doen't require navigation bar
    /// By default, in viewWillAppear we force navigation bar be presented
    public var isPresentedNavigationBarRequired: Bool = true
    
    // Size selection animation
    open lazy var bagAnimator: ModalTransitionAnimator? = {
        let bagAnimator = ModalTransitionAnimator(withModalViewController: self)
        bagAnimator.isDragable = false
        bagAnimator.behindViewAlpha = 0.5
        bagAnimator.behindViewScale = 0.9
        bagAnimator.direction = .right
        
        return bagAnimator
    }()

    var isPopupPresenting: Bool = false
   
    open var poqNavigationController: PoqNavigationViewController? {
        return navigationController as? PoqNavigationViewController
    }
    
    // Required due to extending UIViewController
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let nibBundle = nibBundleOrNil ?? NibInjectionResolver.findBundle(nibName: nibNameOrNil)
        super.init(nibName: nibNameOrNil, bundle: nibBundle)
    }
    
    // MARK: - override appearing methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // SET UP RIGHT BURGER MENU
        setUpRightBarMenu()
        
        // SET UP CENTRAL LOGO TITLE VIEW
        let logoViewFrame = CGRect(x: 0, y: 0, width: CGFloat(AppSettings.sharedInstance.navigationBarWidth), height: CGFloat(AppSettings.sharedInstance.navigationBarHeight))
        let logoView = ResourceProvider.sharedInstance.clientStyle?.getLogoView(forFrame: logoViewFrame)
        logoView?.backgroundColor = .clear
        
        navigationItem.titleView = logoView
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateRightButton(animated: false)

        if UIApplication.shared.applicationState != .background {
            let screenName = self.screenName
            
            // Do not send screen view if the app is not active as this creates ghost sessions (with 1 screen and duration of 1s)
            PoqTracker.sharedInstance.trackScreenName(screenName)
            Log.verbose("Tracked Screen: \(screenName)")
            
            CrashlyticsHelper.logNavigation(to: self)
        }
    }
    
    // MARK: - status bar
    override open var preferredStatusBarStyle: UIStatusBarStyle {

        // We may present view madally controller with custom presentation, in this case, lets ask it
        if let existedPresentedViewController = presentedViewController, existedPresentedViewController.definesPresentationContext && !existedPresentedViewController.isBeingDismissed {
            return existedPresentedViewController.preferredStatusBarStyle
        }
        
        // We do modification of status bar only in first view controller in stack in tabbar. Because there is a logo and colored navbar, which can be black/dark
        // The rest of app we assume having .Default status bar for light navbar
        guard let existedNavigationController = navigationController, let _ = existedNavigationController.tabBarController, existedNavigationController.viewControllers.count == 1 else {
            return .default
        }
        let statusBarStyle: PoqStatusBarStyle? = PoqStatusBarStyle(rawValue: AppSettings.sharedInstance.statusBarStyle)
        
        return UIStatusBarStyle.statusBarStyle(statusBarStyle)
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }
    
    // Update badge number each time it loads
    open func updateRightButton(animated: Bool) {
        guard let rightSideBag = self.bagControl else {
            return
        }
        
        let badgeIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
        let badgeValue = BadgeHelper.getBadgeValue(badgeIndex)
        rightSideBag.setBadgeNumber(String(badgeValue), animated: animated)
    }
    
    open func setUpRightBarMenu() {

        if AppSettings.sharedInstance.showNavMenu {
            
            // SET UP LEFT/RIGHT BURGER MENU
            if AppSettings.sharedInstance.sideMenuPosition == "left" {
                let sideMenuView = LeftSideMenu()
                sideMenuView.addTarget(self, action: #selector(leftSideMenuButtonClicked(_:)), for: .touchUpInside)
                let barItem = UIBarButtonItem(customView: sideMenuView)
                navigationItem.leftBarButtonItem = barItem
            } else {
                bagControl = ResourceProvider.sharedInstance.clientStyle?.createBagControl()
                bagControl?.addTarget(self, action: #selector(self.rightSideMenuButtonClicked), for: [.touchUpInside])
                navigationItem.rightBarButtonItem = bagControl?.createBarButtonitem()
            }
        }
    }

    // ______________________________________________________
    // MARK: - Right side menu clicked
    open func rightSideMenuButtonClicked() {

        if AppSettings.sharedInstance.bagViewInNavigation {
            NavigationHelper.sharedInstance.loadBag( topViewController: navigationController )
        } else {

            let pageListController = initPageListView(DeviceType.IS_IPAD)
            
            if pageListNavigationController == nil {
                pageListNavigationController = PoqNavigationViewController(rootViewController: pageListController)
            }
            
            if DeviceType.IS_IPAD {
                // Use pop over for Hof iPad implementation.
                pageListNavigationController.modalPresentationStyle = .popover
                present(pageListNavigationController, animated: true, completion: nil)
                
                pageListNavigationController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
                pageListNavigationController.popoverPresentationController?.permittedArrowDirections = .up
            } else {
                navigationController?.pushViewController(pageListController, animated: true)
            }
        }
    }

    @objc open func leftSideMenuButtonClicked(_ sender: Any?) {
    }
    
    open func initPageListView(_ isPopOver: Bool) -> PageListViewController {
        
        // Normal page list menu for Hof
        let pageList = PageListViewController(nibName: "PageListView", bundle: nil)
        // Enable back button
        pageList.isASubPageInMoreTab = true
        pageList.isPopOver = isPopOver
        return pageList
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: Confirm these calls with PoqNetworkDelegate, or declare new protocol and remove it from here
    /**
     Called from view model when a network operation starts
     */
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
    }
    
    /**
     Called from view model when a network operation ends
     */
    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
    }
    
    /**
     Called from view model when a network operation fails
     */
    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?, actionHandler: (() -> Void)? ) {
        // Display error alert
        
        let errorTitle: String
        let errorMessage: String?
        if let validErrorMessage = error?.localizedDescription {
            errorTitle = validErrorMessage
            errorMessage = nil
        } else {
            errorTitle = "CONNECTION_ERROR".localizedPoqString
            errorMessage = "TRY_AGAIN".localizedPoqString
            if NSClassFromString("XCTestCase") != nil {
                Log.info("Skipping the 'connection error' popup because we are testing.")
                return
            }
        }
        
        let validAlertController = UIAlertController.init(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController = validAlertController
        
        validAlertController.addAction(UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (alertaction: UIAlertAction) in
            actionHandler?()
        }))
        
        self.present(validAlertController, animated: true, completion: nil)
    }
    
    /**
     Called from view model when a network operation fails
     This convenience method has been provided to call the existing method with a nil action handler.
     All existing viewControllers override theis
     */
    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        networkTaskDidFail(networkTaskType, error: error, actionHandler: nil)
    }
    
    func subcategoryIsVisible(_ notification: Notification) {
        pageListNavigationController?.dismiss(animated: true, completion: nil)
    }
}

extension PoqBaseViewController: BackButtonDelegate {
    
    open func backButtonClicked() {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension PoqBaseViewController: CloseButtonDelegate {

    // MARK: - CloseButtonDelegate - CLOSE BUTTON ACTION FOR EVERY MODAL VIEW CONTROLLER
    open func closeButtonClicked() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
