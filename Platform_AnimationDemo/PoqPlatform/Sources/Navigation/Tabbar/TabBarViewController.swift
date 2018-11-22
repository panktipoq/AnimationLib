//
//  TabBarViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

open class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    var middleTabBarItem: UIView?
    var middleBtn: UIButton?
    var middleImage: UIImageView?
    var middleTextLabel = UILabel()
    var badges: [TabBarBadgeView] = [TabBarBadgeView(), TabBarBadgeView(), TabBarBadgeView(), TabBarBadgeView(), TabBarBadgeView()]

    var tabBarVisible: Bool = true
    
    // Cloud settings
    var tabTitles: [String] = [AppLocalization.sharedInstance.tabTitle1, AppLocalization.sharedInstance.tabTitle2, AppLocalization.sharedInstance.tabTitle3, AppLocalization.sharedInstance.tabTitle4, AppLocalization.sharedInstance.tabTitle5]
    var tabs: [String] = [AppSettings.sharedInstance.tab1, AppSettings.sharedInstance.tab2, AppSettings.sharedInstance.tab3, AppSettings.sharedInstance.tab4, AppSettings.sharedInstance.tab5]
    var tabIcons: [String] = [AppSettings.sharedInstance.tabIcon1, AppSettings.sharedInstance.tabIcon2, AppSettings.sharedInstance.tabIcon3, AppSettings.sharedInstance.tabIcon4, AppSettings.sharedInstance.tabIcon5]
    var selectedTabIcons: [String] = [AppSettings.sharedInstance.selectedTabIcon1, AppSettings.sharedInstance.selectedTabIcon2, AppSettings.sharedInstance.selectedTabIcon3, AppSettings.sharedInstance.selectedTabIcon4, AppSettings.sharedInstance.selectedTabIcon5]
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTabs()
        self.delegate = self
        if AppSettings.sharedInstance.showMiddleButton {
            self.showMiddleButton()
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers?[selectedIndex].preferredStatusBarStyle ?? UIStatusBarStyle.default
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        middleTabBarItem?.center = CGPoint(x: self.tabBar.center.x, y: self.tabBar.frame.height/2)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - set up tabs
    func setUpTabs() {
        
        var navControllers = [PoqNavigationViewController]()
        
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: AppTheme.sharedInstance.tabBarFont,
            NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.tabBarTintColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: AppTheme.sharedInstance.tabBarSelectedFont ?? AppTheme.sharedInstance.tabBarFont,
            NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.tabBarSelectedTintColor], for: .selected)
        
        UITabBar.appearance().backgroundImage = UIImage.getImageWithColor(AppTheme.sharedInstance.tabBarBackgroundColour, size: tabBar.frame.size)
        
        // Convert the main color into a shadow image on the tab bar
        let tabShadowImage = UIImage.getImageWithColor(AppTheme.sharedInstance.tabBarShadowColor, size: CGSize(width: 1, height: 1))
        UITabBar.appearance().shadowImage = tabShadowImage

        // Create all the view controllers
        // If the tab is not defined in MightyBot, then this tab is not displayed in the application
        for index in 0 ..< tabs.count where !tabs[index].isEmpty {
            
            guard let viewController = PoqPlatform.shared.resolveViewController(byName: tabs[index]) else {
                Log.error("We didn't find view controller for \(tabs[index]) at index ")
                continue
            }

            let navigationViewController: PoqNavigationViewController 
            if let navController = viewController as? PoqNavigationViewController {
                navigationViewController = navController
            } else {
                navigationViewController = PoqNavigationViewController(rootViewController: viewController)
            }

            navigationViewController.tabBarItem = initTabBarItem(index)
            navControllers.append(navigationViewController)
        }
        
        // Add them to the tabbar
        self.setViewControllers(navControllers, animated: false)
        
        if AppSettings.sharedInstance.showMiddleButton {
            // Set up custom middle button
            self.setCustomMiddleBtn()
        }
        
        self.tabBar.tintColor = AppTheme.sharedInstance.tabBarTintColor
    }
    
    // MARK: - custom tab methods
    
    // Creates the custom middle button that extends beyond the bounds of the tabbar
    func setCustomMiddleBtn() {
        
        if !AppSettings.sharedInstance.showMiddleButton {
            return
        }
        
        let widthHeight: CGFloat = self.tabBar.frame.height + 10
        let itemFrame = CGRect(x: 0, y: 0, width: widthHeight, height: widthHeight)
        middleTabBarItem = UIView(frame: itemFrame)
        middleTabBarItem?.center = CGPoint(x: self.tabBar.center.x, y: self.tabBar.frame.height/2)
        middleTabBarItem?.backgroundColor = UIColor.clear

        // Get the button width andheight based on the tabbar height
        let buttonFrame: CGRect = itemFrame
        
        // Create the button and center it on the tabbar
        middleBtn = UIButton(frame: buttonFrame)
        if let middleTabBarItem = middleTabBarItem {
            middleBtn?.center = CGPoint(x: middleTabBarItem.bounds.midX, y: middleTabBarItem.bounds.midY)
        }
        // Style the button
        if let middleBtn = middleBtn {
            middleBtn.layer.cornerRadius = middleBtn.frame.height/2
        }
        middleBtn?.clipsToBounds = true
        middleBtn?.backgroundColor = UIColor.white
        middleBtn?.layer.borderWidth = 1
        middleBtn?.layer.borderColor = UIColor.lightGray.cgColor
        middleBtn?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        middleBtn?.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        middleBtn?.layer.backgroundColor = UIColor.white.cgColor
        
        // Add target to update the tabbar when the button is clicked
        middleBtn?.addTarget(self, action: #selector(TabBarViewController.middleButtonTapped), for: UIControlEvents.touchUpInside)
        
        if let middleBtn = middleBtn {
            middleTabBarItem?.addSubview(middleBtn)
        }
        
        // Create the button icon and put it inside the button
        middleImage = UIImageView(image: UIImage(named: self.tabIcons[2])?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        middleImage?.tintColor = AppTheme.sharedInstance.tabBarTintColor
        middleImage?.center = CGPoint(x: widthHeight/2, y: widthHeight/2 - 6)
        if let middleImage = middleImage {
            middleTabBarItem?.addSubview(middleImage)
        }
        
        // Create the button label and put it inside the button
        middleTextLabel.font = AppTheme.sharedInstance.tabBarFont
        middleTextLabel.text = self.tabTitles[2]
        middleTextLabel.sizeToFit()
        if let middleImage = middleImage {
            middleTextLabel.center = CGPoint(x: widthHeight/2, y: middleImage.frame.origin.y + middleImage.frame.size.height + 11)
        }

        let tapTwice = UITapGestureRecognizer(target: self, action: #selector(TabBarViewController.tapTwice))
        tapTwice.numberOfTapsRequired = 2
        middleBtn?.addGestureRecognizer(tapTwice)
        
        middleTabBarItem?.addSubview(middleTextLabel)
        
        // Remove tabbar shadow and add it as a uiview otherwise, there is no way to show middle button above tabbar's shadow image
        self.tabBar.shadowImage = UIImage()
        let tabShadowImageView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        tabShadowImageView.backgroundColor = AppTheme.sharedInstance.tabBarShadowColor
        self.tabBar.addSubview(tabShadowImageView)
        
        if let middleTabBarItem = middleTabBarItem {
            self.tabBar.addSubview(middleTabBarItem)
            tabBar.bringSubview(toFront: middleTabBarItem)
        }
    }
    
    // Method used when the middle button is tapped
    @objc func middleButtonTapped() {
        // Update the tabbar and set the button to selected state
        self.selectedIndex = 2
        self.setMiddleButtonSelected()
        if let selectedController = self.selectedViewController as? UINavigationController {
            selectedController.popToRootViewController(animated: true)
        }
    }
    
    @objc func tapTwice() {
        self.selectedIndex = 2
        self.setMiddleButtonSelected()
        if let selectedController = self.selectedViewController as? UINavigationController {
            selectedController.popToRootViewController(animated: true)
        }
    }
    
    func showMiddleButton() {
        
        if AppSettings.sharedInstance.showMiddleButton {
            if self.middleTabBarItem == nil {
                self.setCustomMiddleBtn()
            }
        }
    }
    
    // Update button tint to selected color
    public func setMiddleButtonSelected() {
        if !AppSettings.sharedInstance.showMiddleButton {
            return
        }
        middleImage?.tintColor = AppTheme.sharedInstance.tabBarSelectedTintColor
        middleTextLabel.font = AppTheme.sharedInstance.tabBarSelectedFont ?? AppTheme.sharedInstance.tabBarFont
        middleTextLabel.textColor = AppTheme.sharedInstance.tabBarSelectedTintColor
    }
    
    // Update button tint to unselected color
    open func setMiddleButtonUnselected() {
        
        if !AppSettings.sharedInstance.showMiddleButton {
            return
        }
        
        middleImage?.tintColor = AppTheme.sharedInstance.tabBarTintColor
        middleTextLabel.font = AppTheme.sharedInstance.tabBarFont
        middleTextLabel.textColor = AppTheme.sharedInstance.tabBarTintColor
    }
    
    // Listen when the tabbar selects a new item
    override open func tabBar( _ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        // If the item tag is 2 then its the middle button and needs to be selected
        if item.tag == Int(AppSettings.sharedInstance.shoppingBagTabIndex) {
            self.setMiddleButtonSelected()
        } else {
            self.setMiddleButtonUnselected()
        }
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let className = NSStringFromClass(viewController.classForCoder)
        let bagName = NSStringFromClass(BagViewController.classForCoder())
        
        // Fix for broken looking header caused by image changes to its navigation bar being skipped.
        if let navigationController = viewController as? UINavigationController {
            navigationController.navigationBar.resetImages()
        }
        
        if className == bagName {
            self.setMiddleButtonSelected()
        } else {
            self.setMiddleButtonUnselected()
        }
        
        return true
    }
    
    // MARK: - badge functionality
    
    /// Find proper TabBarBadgeView and set value to it
    /// NOTE: even if 0 passes here: we will put 0 as text 
    open func setBadge( _ index: Int, badgeValue: Int) {

        guard index >= 0 && index < badges.count else {
            Log.error("Invalid badge index provided: \(index)")
            return
        }

        // Get the label based on index
        let badge: TabBarBadgeView = badges[index]

        // Get the view of the tabbaritem
        // Make sure it isn't outside the bounds of the tabbar items
        guard let tabItemView: UIView = viewForTabBarItemAtIndex(index) else {
            return
        }

        let badgeText = String(badgeValue)

        badge.badgeText = badgeText
        badge.tag = index
        badge.setNeedsDisplay()
        
        // Get the badge position based on the tab's location
        badge.isHidden = false
        
        // If the index is 2 its the middle button, and needs to handle positioning based on the middle button not tabbar
        var badgeSuperview: UIView = tabItemView
        
        if let existedMiddleItemView = middleTabBarItem, index == 2 {
            badgeSuperview = existedMiddleItemView
        }

        badge.attachTo(badgeSuperview, tabBarController: self)
    }
    
    func removeBadge(_ index: Int) {
        guard index >= 0 && index < badges.count else {
            Log.error("Invalid badge index provided: \(index)")
            return
        }

        let badge: TabBarBadgeView = badges[index]

        if  badge.superview != nil {
            badge.removeFromSuperview()
        }
    }
    
    func getBadge( _ index: Int ) -> String? {
        // Get the label based on index
        let badge: TabBarBadgeView = self.badges[index]
        return badge.badgeText
    }
    
    // Method retuns a view with the demensions of the tab at a specific index used to position the badges
    
    // https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UITabBar_Class/index.html#//apple_ref/occ/instp/UITabBar/itemSpacing
    // For the iPad user interface item, tab bar items are positioned closely adjacent to each other with a default width and inter-item spacing (customizable with the itemWidth and itemSpacing properties), potentially leaving space in the tab bar at its left and right edges
    
    func viewForTabBarItemAtIndex(_ index: Int) -> UIView? {
        
        // PLAN A
        // Find all UIControl on tab bar(must be equal to tabs count)
        // Sort by x
        
        var controls = [UIControl]()
        for subview in self.tabBar.subviews {
            if let control: UIControl = subview as? UIControl {
                controls.append(control)
            }
        }
        
        controls.sort { (control1: UIControl, control2: UIControl) -> Bool in
            return control1.frame.origin.x < control2.frame.origin.x
        }
        
        if controls.count != self.viewControllers?.count {
            // PLAN B
            Log.error("controls.count != self.viewControllers!.count")
            return nil
        }
        return controls[index]
    }
    
    func initTabBarItem(_ index: Int) -> UITabBarItem {

        let tabTitle = self.tabTitles[index]
        let imageName = self.tabIcons[index]
        let selectedImageName = self.selectedTabIcons[index]
        
        var tabImage: UIImage?
        if let existedTabImage = UIImage(named: imageName) {
            tabImage = existedTabImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        
        var tabSelectedImage: UIImage?
        if let existedTabSelectedImage = UIImage(named: selectedImageName) {
            tabSelectedImage = existedTabSelectedImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }

        let tabBarItem = UITabBarItem(title: tabTitle, image: tabImage, selectedImage: tabSelectedImage)
        
        /// Styling
        let tabBarFontDict = [
            NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.tabBarFontColor,
            NSAttributedStringKey.font: AppTheme.sharedInstance.tabBarFont
        ] 
        tabBarItem.setTitleTextAttributes(tabBarFontDict, for: UIControlState())

        tabBarItem.tag = index
        
        return tabBarItem
    }
    
    // MARK: - SelectTabBar
    
    override open var selectedIndex: Int {
        didSet {
            updateTabBarFontText()
        }
    }
    
    override open var selectedViewController: UIViewController? {
        didSet {
            updateTabBarFontText()
        }
    }
    
    // MARK: - TabBarFontText

    /**
     The function updates the Font and color of the text Tab button depending if it is the selected view controller or not.
     In case there is no font for the selected state, we will use the normal one.
     The method will also regenerate the Badge because otherwise it is removed with the update.
     */
    fileprivate func updateTabBarFontText() {
        
        guard let viewControllers = viewControllers else {
            return
        }
        
        // This is the only way to update a selected TabBar item.
        // https://stackoverflow.com/questions/25234671/changing-selected-tabbaritem-font-ios
        // Because .selected does not work for UIBarButtonItems.
        for index in 0..<viewControllers.count {
            var tabBarFont =  AppTheme.sharedInstance.tabBarFont
            var tabBarTintColor =  AppTheme.sharedInstance.tabBarTintColor
            
            if viewControllers[index] == selectedViewController {
                tabBarFont = AppTheme.sharedInstance.tabBarSelectedFont ?? AppTheme.sharedInstance.tabBarFont
                tabBarTintColor = AppTheme.sharedInstance.tabBarSelectedTintColor
            }
            
            viewControllers[index].tabBarItem.setTitleTextAttributes(
                [NSAttributedStringKey.font: tabBarFont,
                 NSAttributedStringKey.foregroundColor: tabBarTintColor],
                for: UIControlState()
            )
            
            let badgeValue = BadgeHelper.getBadgeValue(index)
            BadgeHelper.setBadge(for: index, value: badgeValue)
        }
    }
}
