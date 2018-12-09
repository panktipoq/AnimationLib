//
//  TabBarAnimator.swift
//  PoqDemoApp
//
//  Created by Pankti Patel on 21/11/2018.
//

import UIKit
import Foundation

open class TabBarAnimator {
    
    open func startAnimation(using tabIndex: Int,
                                       completion: @escaping AnimClosure) {
        
        guard let bagTabbarItemView = tabBagItem(at: tabIndex),
            let badgeView = bagBadgeView(at: tabIndex) else {
                fatalError("bag tab item not found")
        }
        bagTabbarItemView.layer.runAnimation(CAAnimation.TabItemSpringAnimation())
        if !isBadgeCountEmpty(for: tabIndex) {
            badgeView.layer.runAnimation(CAAnimation.TabItemSpringAnimation(),completion: completion)
        }
        else{
            badgeView.layer.runAnimation(CAAnimation.BadgeCountScaleAnimation(),completion: completion)
        }
    }
}

extension TabBarAnimator {

    // MARK: - Helpers
    func isBadgeCountEmpty(for tabIndex: Int) -> Bool {
        
        if let badgeView = bagBadgeView(at: tabIndex) {
            return Int(badgeView.badgeText) ?? 0 == 0
        }
        return false
    }
    
    func tabBagItem(at index: Int) -> UIView? {
        guard let tabbarController = NavigationHelper.sharedInstance.rootTabBarViewController as? TabBarViewController,
            let tabbarItem = tabbarController.viewForTabBarItemAtIndex(index) else {
            return nil
        }
        
        return tabbarItem
    }
    func bagBadgeView(at index: Int) -> TabBarBadgeView? {
        guard let tabbarController = NavigationHelper.sharedInstance.rootTabBarViewController as? TabBarViewController,
            tabbarController.badges.indices.contains(index) else {
            return nil
        }
        return tabbarController.badges[index]
    }
}
