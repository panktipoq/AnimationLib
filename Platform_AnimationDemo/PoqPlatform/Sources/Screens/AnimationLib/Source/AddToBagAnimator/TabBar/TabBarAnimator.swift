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
        
        PoqAnimator()
            .addKeyFrameAnimation(keyPath: .scale,
                                  values: [1, 1.2, 0.9, 1],
                                  keyTimes: [],
                                  duration: 0.3)
            .startAnimation(for: bagTabbarItemView.layer,
                            type: .parallel,
                            isRemovedOnCompletion: false)
        if !isFirstBagItem(at: tabIndex) {
            PoqAnimator()
                .addKeyFrameAnimation(keyPath: .scale,
                                      values: [1, 1.2, 0.9, 1],
                                      keyTimes: [],
                                      duration: 0.2)
                .startAnimation(for: badgeView.layer,
                                type: .parallel,
                                isRemovedOnCompletion: false,
                                completion: completion)
        } else {
            PoqAnimator()
                .addBasicAnimation(keyPath: .scale,
                                   from: 0,
                                   to: 1 ,
                                   duration: 0.5,
                                   delay: 0,
                                   timingFunction: .easeInSlow)
                .startAnimation(for: badgeView.layer,
                                type: .parallel,
                                isRemovedOnCompletion: false,
                                completion: completion)
        }
    }
}

extension TabBarAnimator {

    // MARK: - Helpers
    func isFirstBagItem(at index: Int) -> Bool {
        
        if let badgeView = bagBadgeView(at: index) {
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
