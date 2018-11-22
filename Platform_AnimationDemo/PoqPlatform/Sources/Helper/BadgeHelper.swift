//
//  BadgeHelper.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/22/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/// FIXME: Long time ago... to avoid setting bedge on tab bar we used this number to avoid setting badge
/// Now it was ONLY safe way to avoid setting values, even if we generally don't care about it and don't wanna keep it
public let MagicTabBarIndex = 99

/// we will use this names to store counts in UserDefaults
fileprivate let PoqBadgeCountKeys = ["badge0", "badge1", "badge2", "badge3", "badge4"]

open class BadgeHelper: NSObject {

    /// Parse previously saved badge values and set them to badges. Should be called when app initiated
    open class func initBadgesValue() {
        let bagTabIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
        let badgeValue = getBadgeValue(bagTabIndex)
        mergeBadges(badgeValue)
        
        let wishlistTabIndex = Int(AppSettings.sharedInstance.wishListTabIndex)
        let wishListBadgeValue = getBadgeValue(wishlistTabIndex)
        
        if wishListBadgeValue != 0 {
            setBadge(for: wishlistTabIndex, value: wishListBadgeValue)
        }
    }
    
    open class func mergeBadges(_ bagBadgeValue: Int) {
        
        if bagBadgeValue != 0 {
            setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: bagBadgeValue)
        }

    }
    
    open class func getBadgeValue(_ index: Int) -> Int {
        let defaults = UserDefaults.standard
        let badgeName = index == MagicTabBarIndex ? AppSettings.sharedInstance.customBadgeName : PoqBadgeCountKeys[index] as String
        return defaults.integer(forKey: badgeName)
    }
    
    /// Set value for tab item at index and save it to UserDefaults (allow us restore old value after app relunched)
    /// - parameter tabIndex: index of tab bar. Valid values: 0...4 and MagicTabBarIndex. If any other value provided, nothing happens
    /// - patameter value: pass 0 to remove badge from tab bar item
    /// NOTE: if MagicTabBarIndex passed we will only save this to UserDefaults. Tav var won't be effected
    open class func setBadge(for tabIndex: Int, value: Int) {
        
        let keysIndexesRange = ClosedRange<Int>(uncheckedBounds: (0, 4))

        var indexSet = IndexSet(integersIn: keysIndexesRange)
        indexSet = indexSet.union(IndexSet(integer: MagicTabBarIndex))
        
        guard indexSet.contains(tabIndex) else {
            Log.error("Invalid index provided: \(tabIndex)")
            return
        }
        
        //set the value into the user defaults
        let defaults = UserDefaults.standard
        
        let badgeName = tabIndex == MagicTabBarIndex ? AppSettings.sharedInstance.customBadgeName : PoqBadgeCountKeys[tabIndex]
        defaults.set(value, forKey: badgeName)
        defaults.synchronize()
        
        guard tabIndex != MagicTabBarIndex else {
            // we don't set badges for magic number
            return
        }
        
        guard let tabBarController = NavigationHelper.sharedInstance.defaultTabBar else {
            Log.error("Unable to find default TabBarViewController from NavigationHelper.")
            return
        }
        // update the tab bar index
         
        if (value == 0) {
            
            tabBarController.removeBadge(tabIndex)
        } else {
            
            tabBarController.setBadge(tabIndex, badgeValue: value)
        }

    }

    open class func increaseBadgeValue(_ index: Int, increaseValue: Int) {
        
        var badgeValue = getBadgeValue(index)
        badgeValue = badgeValue + increaseValue
        setBadge(for: index, value: badgeValue)
    }
    
    open class func decreaseBadgeValue(_ index:Int, increaseValue:Int){
        
        var badgeValue=getBadgeValue(index)
        badgeValue = badgeValue - increaseValue
        badgeValue = badgeValue >= 0 ? badgeValue : 0
        setBadge(for: index, value: badgeValue)
    }
    
    open class func updateBagBadgeTotal<BagItemType: BagItem>(_ bagItems: [BagItemType]) {
        let total = CheckoutHelper.getNumberOfBagItems(bagItems)
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: total)
    }
    
    open class func updateWishBadgeTotal(_ wishListItems: [PoqProduct]) {
        let total = wishListItems.count
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.wishListTabIndex), value: total)
    }

    // only for the demo
    open class func setNumberOfBagItems<BagItemType: BagItem>(_ bagItemsResult: [BagItemType]) {
        var bagItemsCount = 0
        for el in bagItemsResult {
            bagItemsCount += el.quantity ?? 0
        }
        
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: bagItemsCount)
    }
}
