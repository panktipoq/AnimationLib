//
//  PoqPlatformModule.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 11/3/16.
//
//

import Braintree
import FBSDKCoreKit
import Foundation
import iAd
import PoqModuling
import PoqNetworking
import PoqUtilities
import UserNotifications

/// List of view contollers supperted by platfocme
public enum TabBarItems: String {
    case home = "home"
    case categories = "categories"
    case stores = "stores"
    case shop = "shop"
    case bag = "bag"
    case wishlist = "wishlist"
    case myProfile = "my_profile"
    case more = "more"
    case tinder = "tinder"
}

// list of view controllers, which can't be reached via deeplink, since they are app enter level
public enum InitialControllers: String {
    // Non tab bar controllers
    case splash = "splash"
    case countrySelection = "countrySelection"
    case currencySwitcher = "currencySwitcher"
}

public enum ShortcutItemType: String {
    case search = "search"
    case wishlist = "wishlist"
}

public class PoqPlatformModule: PoqModule {
    
    /// Whether or not the application has been setup after having loaded AppConfigurations.
    private var isApplicationSetup = false
    
    /// Temporary variable for any deeplink URL to handle upon application setup.
    /// If the application is already setup this is consumed as soon as possible.
    private var deeplinkUrl: URL?
    
    public init() {
    }
    
    // MARK: - PoqModule

    public func didAddToPlatform() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        PoqUserNotificationCenter.shared.addHandler(self)
        
        NavigationHelper.sharedInstance.setupRoutes()
    }
    
    public func willRemoveFromPlatform() {
        NotificationCenter.default.removeObserver(self)
        PoqUserNotificationCenter.shared.removeHandler(self)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        application.statusBarStyle = statusBarStyle
        
        var rootViewController: UIViewController?
        var hideNavigationBar = true
        
        PoqDataStore.store = RealmStore()

        // If we are just running unit tests then we can skip this setup.
        // TODO: Link unit tests to frameworks rather than application and refactor this.
        if AutomationTestsUtilities.isRunningTests {
            setupNetworking()
            AutomationTestsUtilities.decodeProcessInfo()
            
            if let baseUrlString = AutomationTestsUtilities.parseEndpointUrlStirng() {
                PoqNetworkTaskConfig.poqApi = baseUrlString
            }
            
            if AutomationTestsUtilities.isRunningUITests {
                rootViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.splash.rawValue)
            } else {
                // We don't need the whole app for non-UITests because they have access to the code and should set it up their way.
                // So other types of test should inject their own view controllers into the rootViewController.
                UIApplication.shared.keyWindow?.rootViewController = UINavigationController()
                return
            }
        } else if CurrencySwitcherViewModel.isCurrencySwitcherNeeded {
            rootViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.currencySwitcher.rawValue)
            hideNavigationBar = false
        } else if CountrySelectionViewModel.isCountrySelectionNeeded() {
            rootViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.countrySelection.rawValue)
            hideNavigationBar = false
        } else {
            setupNetworking()
            rootViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.splash.rawValue)
        }
        
        if let rootViewController = rootViewController {
            let navigationController = rootViewController as? UINavigationController ?? UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = hideNavigationBar
            UIApplication.shared.keyWindow?.rootViewController = navigationController
        }
        
        updateApplicationShortcutItems()
        updateSearchAdsAttribution()
        
        CrashlyticsHelper.start()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // TODO: I think this function should be removed - its applied to early, not taking into account current country.
    private var statusBarStyle: UIStatusBarStyle {
        let setting = SettingsCoreDataHelper.fetchSetting(nil, key: "statusBarStyle", settingTypeId: PoqSettingsType.config.rawValue)
        
        if let value = setting?.value, !value.isEmpty, let intValue = Int(value), let statusBarStyle = UIStatusBarStyle(rawValue: intValue) {
            return statusBarStyle
        } else {
            let poqStatusBarStyle = PoqStatusBarStyle(rawValue: AppSettings.sharedInstance.statusBarStyle)
            return UIStatusBarStyle.statusBarStyle(poqStatusBarStyle)
        }
    }
    
    private func setupNetworking() {
        if let country = CountrySelectionViewModel.selectedCountrySettings() {
            PoqNetworkTaskConfig.appId = country.appId
            PoqNetworkTaskConfig.poqApi = country.apiUrl ?? ""
        } else {
            PoqNetworkTaskConfig.appId = PListHelper.sharedInstance.getAppID() ?? ""
            PoqNetworkTaskConfig.poqApi = PListHelper.sharedInstance.getApiURL()
        }
        
        PoqNetworkTaskConfig.currencyCode = CurrencyProvider.shared.currency.code

        if PoqNetworkTaskConfig.poqApi.isEmpty {
            PoqNetworkTaskConfig.poqApi = PListHelper.sharedInstance.getApiURL()
        }
        
        assert(!PoqNetworkTaskConfig.poqApi.isEmpty, "After `setupNetworking()` we must have api endpoint")
        assert(!PoqNetworkTaskConfig.appId.isEmpty, "After `setupNetworking()` we must have app id")
        
        if let apiVersion = PListHelper.sharedInstance.getApiVersion(), !apiVersion.isEmpty {
            PoqNetworkTaskConfig.settingsVersion = apiVersion
        }
    }
    
    /// Updates the dynamic UIApplicationShortcutItems for the application.
    private func updateApplicationShortcutItems() {
        var shortcutItems = [UIApplicationShortcutItem]()
        
        let searchIcon = UIApplicationShortcutIcon(type: .search)
        let search = UIApplicationShortcutItem(type: ShortcutItemType.search.rawValue, localizedTitle: "Search".localizedPoqString, localizedSubtitle: "", icon: searchIcon)
        shortcutItems.append(search)
        
        let wishlistIcon = UIApplicationShortcutIcon(templateImageName: "LikeButtonImageDefault")
        let wishlist = UIApplicationShortcutItem(type: ShortcutItemType.wishlist.rawValue, localizedTitle: "Wishlist".localizedPoqString, localizedSubtitle: "", icon: wishlistIcon)
        shortcutItems.append(wishlist)
        
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
    /// Updates the Search Ads AppStore attribution details.
    /// More on AppStore attribution: https://searchads.apple.com/help/measure-results/#attribution-api
    /// The attribution only applies to users who have tapped on a Search Ads campaign, and have downloaded the app within 30 days.
    private func updateSearchAdsAttribution() {
        ADClient.shared().requestAttributionDetails { (_, _) in }
        ADClient.shared().add(toSegments: ["installed"], replaceExisting: true)
    }
    
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        BadgeHelper.initBadgesValue()
        PoqTrackerHelper.trackAppForeground()
    }
    
    @objc private func applicationDidEnterBackground(_ notification: Notification) {
        PoqTrackerHelper.trackAppBackground()
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        
        // Allow attribution URL to be sent to GA. Why? Providers are setup after the splash screen
        // So we need to delay the process by saving the endpoint
        let userDefault = UserDefaults.standard
        userDefault.set(url, forKey: PoqTracker.attributionUrlUserDefaultKey)
        userDefault.synchronize()
        
        if let scheme = url.scheme, scheme.localizedCaseInsensitiveCompare(BraintreeHelper.paymentsURlScheme) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        
        if url.absoluteString.contains(NavigationHelper.sharedInstance.appURLSchema) {
            handleDeeplink(url)
            return true
        } else {
            let annotation = options[.annotation]
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let shortcutItemType = ShortcutItemType(rawValue: shortcutItem.type) else {
            Log.error("Unable to identify shortcut item: \(shortcutItem.type).")
            completionHandler(false)
            return
        }
        
        var deeplink = NavigationHelper.sharedInstance.appURLSchema
        switch shortcutItemType {
        case .search:
            deeplink += NavigationHelper.sharedInstance.searchOnHomeURL
        case .wishlist:
            deeplink += NavigationHelper.sharedInstance.wishlistURL
        }
        
        guard let deeplinkUrl = URL(string: deeplink) else {
            Log.error("Unable to create deeplink URL for shortcut deeplink: \(deeplink).")
            completionHandler(false)
            return
        }
        
        handleDeeplink(deeplinkUrl)
        completionHandler(true)
    }
    
    public func apply(settings: [PoqSettingsType: [PoqSetting]]) {
        settings.forEach({ $0.key.appConfiguration?.update(with: $0.value) })
    }
    
    public func setupApplication() {
        NavigationHelper.sharedInstance.setupTabBarNavigation(TabBarViewController())
        isApplicationSetup = true
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let rootViewController = NavigationHelper.sharedInstance.rootTabBarViewController
        
        window.rootViewController = rootViewController
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.handleDeeplink()
        }, completion: { _ in
            if OnboardingViewController.shouldShowOnboarding {
                NavigationHelper.sharedInstance.loadOnboarding()
            }
        })
    }
    
    public func handleDeeplink(_ url: URL? = nil) {
        guard let deeplinkUrl = url ?? self.deeplinkUrl else {
            return
        }
        
        guard isApplicationSetup else {
            self.deeplinkUrl = deeplinkUrl
            return
        }
        
        Turnpike.resolve(deeplinkUrl)
    }
    
    public func resetApplication() {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Application expected to have a key window for `resetApplication`.")
        }
        
        isApplicationSetup = false
        
        UIView.transition(with: window, duration: 1, options: .transitionFlipFromLeft, animations: {
            self.setupNetworking()
            CurrencyProvider.resetInstance()
            
            let rootViewController = PoqPlatform.shared.resolveViewController(byName: InitialControllers.splash.rawValue) ?? SplashViewController(nibName: "SplashViewController", bundle: nil)
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = true
            
            window.rootViewController = navigationController
        })
    }
    
    public func createViewController(forName name: String) -> UIViewController? {
        
        // First check for enter level controllers
        if let initialController = InitialControllers(rawValue: name) {
            switch initialController {

            case .splash:
                return SplashViewController(nibName: "SplashViewController", bundle: nil)

            case .countrySelection:
                let countrySelectionViewController = CountrySelectionViewController(nibName: "CountrySelectionView", bundle: nil)
                countrySelectionViewController.firstTimeLoad = true
                return countrySelectionViewController
                
            case .currencySwitcher:
                return CurrencySwitcherViewController(nibName: CurrencySwitcherViewController.XibName, bundle: nil)
            }
        }
        
        guard let tabBarItem = TabBarItems(rawValue: name) else {
            Log.error("Usually this is last module in chaiin and we unable to identify controller for name \(name)")
            return nil
        }
        
        switch tabBarItem {
            
        case .home:
            return HomeViewController(nibName: "HomeView", bundle: nil)
            
        case .categories:
            return CategoryListViewController()
            
        case .stores:
            return StoresViewController(nibName: "StoresView", bundle: nil)
            
        case .shop:
            switch AppSettings.sharedInstance.shopType {
                
            case ShopPageType.native.rawValue:
                return CategoryListViewController()
                
            default:
                return ShopViewController(nibName: "ShopView", bundle: nil)
            }
            
        case .bag:
            switch AppSettings.sharedInstance.checkoutBagType {
                
            case BagType.transfer.rawValue:
                return BagViewController(nibName: "BagView", bundle: nil)
                
            case BagType.native.rawValue:
                return CheckoutBagViewController(nibName: CheckoutBagViewController.XibName, bundle: nil)
                
            default:
                return CheckoutBagViewController(nibName: CheckoutBagViewController.XibName, bundle: nil)
            }
            
        case .wishlist:
            switch AppSettings.sharedInstance.wishListViewType {
                
            case WishListViewType.grid.rawValue:
                return WishListGridViewController(nibName: "WishListGridView", bundle: nil)
                
            default:
                return WishlistViewController(nibName: "WishlistView", bundle: nil)
            }
            
        case .myProfile:
            return MyProfileViewController(nibName: "MyProfileView", bundle: nil)
            
        case .more:
            return PageListViewController(nibName: "PageListView", bundle: nil)
            
        case .tinder:
            return TinderViewController(nibName: "TinderViewController", bundle: nil)
        }
        
    }
    
    public func createTrackers() -> [PoqTrackingProtocol] {
        var trackingProviders = [PoqTrackingProtocol]()
        
        // Init Google Analytics
        if !AppSettings.sharedInstance.googleAnalyticsID.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            trackingProviders.append(PoqGoogleTrackingProvider(trackingID: AppSettings.sharedInstance.googleAnalyticsID))
        }
        
        // Init Facebook
        if AppSettings.sharedInstance.facebookAppID != "" {
            trackingProviders.append(PoqFacebookTrackingProvider())
        }
        
        return trackingProviders
    }
    
}

extension PoqPlatformModule: PoqUserNotificationHandler {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PoqTrackerHelper.trackPushNotification()
        completionHandler()
    }
    
}
