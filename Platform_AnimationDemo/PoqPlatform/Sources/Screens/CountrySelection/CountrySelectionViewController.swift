//
//  CountrySelectionViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/01/2016.
//
//

import Foundation
import PoqNetworking
import UIKit
import PoqAnalytics
import PoqModuling
import FacebookCore
import FBSDKCoreKit

/**
 `CountrySelectionViewController` is one of the available entry points
 of the Application as defined by `InitialControllers` enum.
 This view controller will be presented as initial before moving on to `SplashViewController`
 when in the Info.plist is defined an array under key `Poq_Countries_List`.
 In it should be listed all available country IDs (which are actually a MightyBot App IDs).
 
 - Note:
 When `Poq_Countries_List` is defined, any usage of
 key `Poq_App_ID` must be removed from the Info.plist
 */
open class CountrySelectionViewController: PoqBaseViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var currentCountryLabel: UILabel? {
        didSet {
            currentCountryLabel?.font = AppTheme.sharedInstance.countrySelectionCurrentCountryLabelFont
            currentCountryLabel?.textColor = AppTheme.sharedInstance.countrySelectionCurrentCountryLabelColor
        }
    }
    
    lazy public var viewModel: CountrySelectionViewModel = {
        return CountrySelectionViewModel(viewControllerDelegate: self)
    }()
    
    public var isModal = false
    public var firstTimeLoad = false

    override open func viewDidLoad() {
        super.viewDidLoad()
      
        tableView?.registerPoqCells(cellClasses: [CountrySelectionCell.self])
        
        setUpNavigation()
        
        if let country = CountrySelectionViewModel.selectedCountrySettings() {
            
            let countryCode: String = viewModel.countryIsoCode(forAppId: country.appId)
            let localeId: String = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
            let locale = Locale(identifier: Locale.autoupdatingCurrent.identifier)
            
            guard let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: localeId) else {
                return
            }
            
            let format: String = AppLocalization.sharedInstance.changeCountrySelectionFormat
            
            let resText: NSString = NSString(format: format as NSString, displayName)
            
            currentCountryLabel?.text = resText as String
            viewModel.removeCurrentCountryFromCountriesList()
        }
        
        // First time load, we can't get cloud settings
        if let fontName: String = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "Poq_Countries_List_Font_Family") as? String {
            if let font = UIFont(name: fontName, size: 14.0) {
                currentCountryLabel?.font = font
            }
        }
        
        // First time load, we can't get cloud settings
        if let fontName: String = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "Poq_Countries_List_Font_Family") as? String {
            if let font = UIFont(name: fontName, size: 14.0) {
                currentCountryLabel?.font = font
            }
        }
    }
    
    func setUpNavigation() {
        if !firstTimeLoad {
        navigationItem.leftBarButtonItem = isModal ? NavigationBarHelper.setupCloseButton(self) : NavigationBarHelper.setupBackButton(self)
        }
        navigationItem.titleView = nil
        navigationItem.title = AppLocalization.sharedInstance.changeCountryViewTitle
    }
    
    /**
     Persists the new selected CountryID (MightyBot App ID) in UserDefaults
     and reloads the app from initial state.
     
     - Note:
     For further details of procedures during initial Application loading,
     please refer to `SplashViewController` and `SplashViewModel` documentation.
     */
    fileprivate func replaceCountry(_ selectedCountryIndex: Int) {

        self.viewModel.saveSelectedCountrySettings(atIndex: selectedCountryIndex)
        
        guard let country = CountrySelectionViewModel.selectedCountrySettings() else {
            return
        }
        
        PoqTracker.sharedInstance.logAnalyticsEvent("Country Select",
                                                    action: "Change Country",
                                                    label: country.isoCode ,
                                                    extraParams: nil)
        // Track V2 analytics
        PoqTrackerV2.shared.switchCountry(countryCode: country.isoCode)
        
        // Default value is read from the application's Info.plist under `FacebookAppId` key.
        // For international apps, we need to override it from the country selection
        if let facebookAppId = country.facebookAppId {
            SDKSettings.appId = facebookAppId
            SDKSettings.displayName = country.facebookAppDisplayName ?? ""
            AppEventsLogger.activate(UIApplication.shared)
        }

        PoqNetworkTaskConfig.appId = country.appId
        
        if let apiUrl = country.apiUrl {
            PoqNetworkTaskConfig.poqApi = apiUrl
        }
        
        if AppSettings.sharedInstance.logoutUserOnChangeCountry {
            LoginHelper.clear()
        }
        StripeHelper.sharedInstance.clearCustomer() // Remove customer in order to clear invalid card.
        
        let index = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
        BadgeHelper.setBadge(for: index, value: 0)
        BagHelper().saveOrderId(0)

        WishlistController.shared.remove()
        
        // Remove recently viewed products from the store
        PoqDataStore.store?.deleteAll(forObjectType: RecentlyViewedProduct(), completion: nil)
        
        AppSettings.resetSharedInstance()
        PoqPlatform.shared.resetApplication()
    }
    
    // MARK: - UITableViewDataSource
    
   open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfAvailableCounties()
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.getCell(forIndexPath: indexPath, tableView: tableView)
    }
}

// MARK: - UITableViewDelegate
extension CountrySelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        guard let country = CountrySelectionViewModel.selectedCountrySettings() else {
            replaceCountry(indexPath.row)
            return
        }
        
        if viewModel.appIdForCountryAtIndex(indexPath.row) == country.appId {
            return
        }
        
        let alertController = UIAlertController(title: AppLocalization.sharedInstance.changeCountryMessageTitle, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "CANCEL".localizedPoqString, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            self.replaceCountry(indexPath.row)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}
