//
//  StoresViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/17/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import DBPrivacyHelper
import Foundation
import MapKit
import PoqNetworking
import PoqUtilities
import UIKit

public enum StoresViewControllerType: Int {
    
    case findStore = 0
    case setFavoriteStore = 1
}

open class StoresViewController: PoqBaseViewController, StoreListDelegate, StoresMapViewDelegate {
    
    @IBOutlet open weak var menuContainer: UIView?
    
    open var pageMenu: CAPSPageMenu?
    open var storeLocationList: StoreLocationListViewController?
    open var storeList: StoreListViewController?
    open var storeMaps: StoreMapViewController?
    
    // If true then store detail will not be shown
    // Instead, the delegate will be called back
    open var isStoreSelection = false
    open var storeSelectionDelegate: StoreListDelegate?
    open var checkLocationLoaded: Bool = false
    open var controllerType: StoresViewControllerType = .findStore

    class open func initAs(_ type: StoresViewControllerType = .findStore) -> StoresViewController {
        let storesViewController = StoresViewController(nibName: "StoresView", bundle: nil)
        storesViewController.controllerType = type
        return storesViewController
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the controller is a tab item else show back button
        NavigationBarHelper.checkAvailability(self, tabbarItem: TabbarItem.Stores)
        
        if isStoreSelection {
            
            // Hide burger menu when in selection mode
            self.navigationItem.rightBarButtonItem = nil
            
            // Set title
            self.navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.selectStoreNavigationTitle, titleFont: AppTheme.sharedInstance.productAvailabilityNavigationTitleFont)
            
            self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
        
        if PermissionHelper.checkLocationAccess() == false {
            self.showPrivacyHelper(for: DBPrivacyType.location, controller: { (vc) -> Void in
                // customize the view controller
                }, didPresent: { () -> Void in
                }, didDismiss: { () -> Void in
                }, useDefaultSettingPane:false)
        }
        
        //show hide right navigation menu
        if AppSettings.sharedInstance.hideRightNavigationMenuOnStore {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if pageMenu == nil {
            
            setupPageMenu()
        }
    }
    
    open func setupPageMenu() {
        
        // controllers to be used in page menu
        var controllerArray: [UIViewController] = []
        
        // set up three controllers to dispay in page menu
        storeLocationList = StoreLocationListViewController(nibName: "StoreLocationListViewController", bundle: nil)
        storeLocationList?.title = AppLocalization.sharedInstance.storeSortNearbyText
        storeLocationList?.delegate = self
        if let storeLocationListUnwrapped = storeLocationList {
            controllerArray.append(storeLocationListUnwrapped)
        }
        
        if AppSettings.sharedInstance.storesScreenShouldDisplayCityTab {
            storeList = StoreListViewController(nibName: "StoreListViewController", bundle: nil)
            storeList?.delegate = self
            storeList?.title = AppLocalization.sharedInstance.storeSortAToZText
            if let storeListUnwrapped = storeList {
                controllerArray.append(storeListUnwrapped)
            }
        }
        storeMaps = StoreMapViewController(nibName: "StoreMapViewController", bundle: nil)
        storeMaps?.delegate = self
        storeMaps?.title = AppLocalization.sharedInstance.storeSortMapText
        //storeMaps!.mapDelegate = self
        if let storeMapsUnwrapped = storeMaps {
            controllerArray.append(storeMapsUnwrapped)
        }
        
        // Initialize scroll menu
        let pageMenuParameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(AppTheme.sharedInstance.scrollMenuBackgroundColor),
            .viewBackgroundColor(AppTheme.sharedInstance.viewBackgroundColor),
            .selectionIndicatorColor(AppTheme.sharedInstance.selectionIndicatorColor),
            .addBottomMenuHairline(true),
            .bottomMenuHairlineColor(AppTheme.sharedInstance.bottomMenuHairlineColor),
            .unselectedMenuItemLabelColor(AppTheme.sharedInstance.unselectedMenuItemLabelColor),
            .selectedMenuItemLabelColor(AppTheme.sharedInstance.selectedMenuItemLabelColor),
            .selectedMenuItemFont(AppTheme.sharedInstance.selectedMenuItemLabelFont),
            .unselectedMenuItemFont(AppTheme.sharedInstance.unselectedMenuItemLabelFont),
            .menuHeight(CGFloat(AppTheme.sharedInstance.menuHeight)),
            .menuItemWidth(CGFloat(AppTheme.sharedInstance.menuItemWidth)),
            .centerMenuItems(AppTheme.sharedInstance.centerMenuItems)
        ]
        
        guard let frame = menuContainer?.bounds else {
            Log.warning("Couldnt create CAPSPageMenu as there is no menu container")
            return
        }
        
        let pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: frame, pageMenuOptions: pageMenuParameters)
        self.pageMenu = pageMenu
        
        menuContainer?.addSubview(pageMenu.view)
    }
   
    open func storeSelected(_ store: PoqStore) {
        
        switch controllerType {
        case .findStore:
            if isStoreSelection {
                
                if let delegate = storeSelectionDelegate {
                    
                    // Call back delegate and remove itself
                    delegate.storeSelected(store)
                    _ = self.navigationController?.popViewController(animated: true)
                    storeSelectionDelegate = nil
                } else {
                    
                    Log.verbose("Store selection enabled but calling view is not conforming StoreListDelegate")
                    Log.verbose("Store detail will be shown")
                    if let storeId = store.id, let storeName = store.name {
                        
                        NavigationHelper.sharedInstance.loadStoreDetail(storeId, storeTitle: storeName)
                    }
                    
                }
            } else {
                
                Log.verbose("Store selection is not enabled")
                Log.verbose("Store detail will be shown")
                if let storeId = store.id, let storeName = store.name {
                    
                    NavigationHelper.sharedInstance.loadStoreDetail(storeId, storeTitle: storeName)
                }
            }

        case .setFavoriteStore:
            // Set store to user defaults and navigate back
            if let storeId = store.id {
                StoreHelper.addFavorite(storeId: storeId)
            }
            backButtonClicked()
        }
        
    }
    
    open override func backButtonClicked() {

        if let map = storeMaps?.mapView {
            
            MapKitHelper.releaseMap(map)
            storeMaps?.mapView = nil
        }
        
        storeLocationList?.delegate = nil
        storeList?.delegate = nil
        storeMaps?.delegate = nil
        storeMaps?.mapDelegate = nil

        storeLocationList = nil
        storeList = nil
        storeMaps = nil
        
        super.backButtonClicked()
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
        if index == 0 {
        
            if (PermissionHelper.checkLocationAccess() == false) && !checkLocationLoaded {
                self.showPrivacyHelper(for: DBPrivacyType.location, controller: { (vc) -> Void in
                    // customize the view controller
                    }, didPresent: { () -> Void in
                    }, didDismiss: { () -> Void in
                        self.checkLocationLoaded = true
                    }, useDefaultSettingPane:false)
            }
        }
    }
    
    func mapSwipeRight() {
        self.pageMenu?.moveToPage(1)
    }
    
}
