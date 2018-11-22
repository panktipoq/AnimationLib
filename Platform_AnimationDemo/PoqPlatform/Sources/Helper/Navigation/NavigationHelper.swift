//
//  NavigationHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import SafariServices

/**
    Handles the routing and deep linking in the app. It uses the Turnpike library to map deep links to a closure that sets up the dependencies and the route for the corresponding ViewController.
 
    It is a singleton that provides methods to setup routes and navigate to them.
 
 
    - ToDo:
    - Check for routes that aren't used and remove them.
    - Assess the feasibility of replacing Turnpike with custom/homegrown implementation.
 */
public final class NavigationHelper {

    /// Singleton instance of `NavigationHelper` that is used to access the instance methods and properties.
    public static let sharedInstance = NavigationHelper()

    private init() {
        Log.verbose("NavigationHelper initialized")
    }

    ///  Private reference to an instance of the root UINavigationController. Can be set by calling `setupNavigation`.
    var rootNavigationViewController: UINavigationController?

    /// Reference to an instance of the tab bar controller. Can be set by calling `setupTabBarNavigation`.
    public var rootTabBarViewController: UITabBarController?
    
    /// The default tabBar provided by the platform unless overriden by a class not subclassing this.
    public var defaultTabBar: TabBarViewController? {
        return rootTabBarViewController as? TabBarViewController
    }

    /// Reference to an intance of the top ViewController in the navigation stack.
    var topMostViewController: UIViewController?

    /// The deep link URL Schema
    public lazy var appURLSchema = { return PListHelper.sharedInstance.getURLScheme() }()

    /// The URL path for the Onboarding screen. The default implementation of this route is currently mapped to `OnboardingViewController`.
    public let onboardingURL = "onboarding"
    
    /// The URL path for the Category screen. The default implementation of this route is currently mapped to `CategoryListViewController`.
    /// - ToDo: Do we really need this API Path
    public let categoryURL = "category/"

    /// The URL path for the branded category screen. The default implementation of this route is currently mapped to `BrandedProductListViewController`.
    public let brandedCategoryURL = "brandedCategory/"

    /// The URL path for the Product List screen for a category. The default implementation of this route accepts a category id as a parameter and is currently mapped to the `ProductListViewController`.
    public let productsInCategoryURL = "products/category/"

    /// The URL path for the branded PLP screen for a category. The default implementation of this route accepts a category ID as a parameter and is currently mapped to the `BrandedProductListViewController`.
    public let productsInBrandedCategoryURL = "products/brandedCategory/"

    /// The URL path for the Group Product List screen.
    ///
    /// - Note: The default implementation of this route depends on a `PoqProduct` instance that should be provided in the `navigationContext` dictionary property of the `NavigationHelper` as a value to the key `groupedProduct`. The route is currently mapped to the `ProductGroupedListViewController`.
    public let productsInGroupURL = "products/group"

    /// The URL path for the Grouped Product List screen for a bundled product.
    ///
    /// - Note: The default implementation of this route depends on a `PoqProduct` instance that should be provided in the `navigationContext` dictionary property of the `NavigationHelper` as a value to the key `bundledProduct`. The route is currently mapped to the `ProductGroupedListViewController`.
    public let productsInBundleURL = "products/bundle"

    /// The URL path for the Product Detail screen. The default implementation of this route accepts a Product ID as a parameter and is mapped to either `ProductDetailViewController` or `ModularProductDetailViewController` depending on the value of the AppSetting ( MB setting ) `pdpViewType`.
    ///
    /// - ToDo: Remove Classic PDP
    public let productDetailURL = "products/detail/"

    /// The URL path for the Page List Screen. The default implementation of this route accepts the `parent_id` as a parameter and is currently mapped to the `PageListViewController`.
    public let pageListURL = "pages/"

    /// The URL path for the Page List Screen. The default implementation of this route accepts the `page_id` as a parameter and is currently mapped to the `PageDetailViewController`.
    public let pageDetailURL = "pages/detail/"

    /// The URL path for the Web Checkout Screen. The default implementation of this route is mapped to the `WebViewCheckoutViewController`.
    ///
    /// - Note: The `WebViewCheckoutViewController` is wrapped in a `PoqNavigationViewController` and presented.
    public let cartTransferURL = "cartTransfer/v2"

    /// The URL path for the Login Screen.
    ///
    /// - Note: The default implementation of this route accepts an `is_modal` parameter which determines if the screen is presented as a modal and the parameter `is_animated` which determines if the presentation is animated. The route is mapped to the `LoginViewController`.
    public let loginURL = "login"

    /// The URL path for the Login Screen. The default implementation of this route accepts an `is_modal` parameter which determines if the screen is presented as a modal. The route is mapped to the `SignUpViewController`.
    public let signUpURL = "signup"

    /// The URL path for the Store Detail Screen. The default implementation of this route accepts a `store_id` parameter and the route is mapped to `StoreDetailViewController`.
    public let storeURL = "stores/detail/"

    /// The URL path for the Stores List Screen. The default implementation of this route is mapped to present `StoresViewController` initialised with default arguments.
    public let storeListURL = "stores"

    /// The URL path for the Favorite Store Selection Screen. The default implementation of this route is mapped to present the `StoresViewController` with `isFavoriteStoreList` argument set to true.
    public let storeListFavoriteURL = "stores/favorite"

    /// The URL path for the Barcode Scanner Screen. The default implementation of this route is mapped to `ScannerViewController`.
    public let scanURL = "scan"

    /// The URL path for the Visual Search Screen. The default implementation of this route is mapped to `VisualSearchViewController`.
    public let visualSearchURL = "visual/search"
    
    /// The URL path for the Product List Screen for a search string. The default implementation of this route accepts the `keyword` parameter and is mapped to `ProductListViewController`.
    public let productsInSearchURL = "products/search/"

    /// The URL path for the Recently Viewed Products Screen. The default implementation of this route is mapped to RecentlyViewedProductListViewController.
    public let productsRecentlyViewedURL = "products/recentlyviewed"

    /// The URL path for the Order History List Screen. The default implementation of this route is mapped to `OrderListViewController`.
    public let orderHistoryURL = "orders"

    /// The URL path for the Order Detail/Confirmation Screen.
    ///
    /// - Note: The default implementation of this route is accepts the `orderKey` and `externalOrderId` parameters. The route is either mapped to either `OrderConfirmationViewController` or `OrderDetailViewController` based on the value of the `AppSettings` ( MB Settings ) property `orderDetailViewType`.
    /// 
    /// - ToDo: Remove the dependency on the MB setting and the enum with client specific cases.
    public let orderSummaryURL = "order/detail/"

    /// The URL path for the Reviews Screen. The default implementation of this route accepts the `is_Modal` and `product_id` parameters. The route is mapped to `ReviewsViewController`.
    public let reviewsURL = "reviews/"

    /// The URL path for the Barcode Screen. The default implementation of this route accepts the `barcode_id` parameter and the route is mapped to `MyProfileBarcodeFullscreenViewController`.
    ///
    /// - ToDo: Check if this route is used and remove if not.
    public let barcodeURL = "barcode/"

    /// The URL path for the Edit MyProfile Screen. The default implementation of this route is mapped to `EditMyProfileViewController`.
    public let editMyProfileURL = "editMyProfile"

    /// The URL path for the Brands Category Screen. The default implementation of this route accepts the `is_modal` parameter which determines if the screen is presented modally. The route is mapped to `CategoryListViewController`.
    ///
    /// - ToDo: Check if this route is required and remove it if not. The default implementation of could be improved if the route is required.
    public let brandsURL = "brands"

    /// The URL path for the Lookbook Screen. The default implementation of this route accpets the `lookbook_id` and `title` parameters. The route is mapped to `LookbookViewController`.
    public let lookbookURL = "lookbook"

    /// The URL path for the MyProfile Screen. The default implementation of this route is mapped to select the tab index specified in the `myProfileTabIndex` property of `AppSettings`
    public let myProfileURL = "myprofile"

    /// The URL path for the Wishlist Screen. The default implementation of this route is mapped to select the tab index specified by the `wishListTabIndex` property of `AppSettings` if the navigation is from the Tab bar. If not the route is mapped to present the `WishListViewController`.
    public let wishlistURL = "wishlist"

    /// The URL path for the Shopping Bag Screen.
    /// 
    /// - Note: The default implementation of this route is mapped to present the tab index specified by the `shoppingBagTabIndex` property for `AppSettings` if the navigation is from the tab bar or it presents one of `BagViewController` or `CheckoutBagViewController` based on the value of the `AppSettings` property `checkoutBagType`.
    ///
    /// - ToDo: Check if we can simplify or improve the logic for this route
    public let shoppingBagURL = "bag"

    /// The URL path for the Shop Screen.
    ///
    /// - Note: The default implementation of this route is mapped to present the tab index of 1 if the navigation is from the tab bar. If not the route is mapped to present the `ShopViewController`.
    ///
    /// - ToDo: Check if routing logic can be removed or improved upon. Remove the hardcoded tab index.
    public let shopURL = "shop"

    /// The URL path for Layar Screen.
    ///
    /// - ToDo: This route seems broken. Remove if unused.
    public let layarURL = "layar"

    /// The URL path for the MyProfile AddressBook screen. The default implementation of this route is mapped to `MyProfileAddressBookViewController`.
    public let myProfileAddressBookURL = "addressbook"

    /// The URL path for the Country Selection Screen.
    /// 
    /// - Note: The default implementation of this route accpets the `is_modal` parameter which determines if the screen is presented modally. The route is mapped to the `CountrySelectionViewController`.
    public let changeCountryURL = "changeCountry"
    
    /// The URL path for the Currency Switcher Screen.
    ///
    /// - Note: The route is mapped to the `CountrySwitcherViewController`.
    public let changeCurrencyURL = "changeCurrency"
    /// The URL path for the Story Detail Screen.
    /// 
    /// - Note: The default implementation of this route accepts the `story_id` parameter and is mapped to the  StoryDetailViewController.
    public let storyDetailURL = "stories/detail/"

    /// The URL path for the Change Password Screen.
    ///
    /// - Note: The default implementation of this route presents a `WebWrapperViewConroller` with the url, title, saveButtonTitle, jsCode properties of the ViewController set to the values of `changePasswordComponentUrl`, `changePasswordTitle`, `changePasswordSaveTitle` and `changePasswordSaveActionJS` properties of `AppSettings`.
    ///
    /// - ToDo: See if the implementation of this route can be improved upon.
    public let changePasswordURL = "account/changePassword"

    /// The URL path for the Forgot Password Screen.
    ///
    /// - Note: The default implementation of this route presents a `WebWrapperViewConroller` with the url, title, saveButtonTitle, jsCode properties of the ViewController set to the values of `forgotPasswordComponentUrl`, `forgotPasswordTitle`, `forgotPasswordSaveTitle` and `forgotPasswordSaveActionJS` properties of `AppSettings`.
    ///
    /// - ToDo: See if the implementation of this route can be improved upon.
    public let forgetPasswordURL = "account/forgetPassword"

    /// The URL for the Add Address Screen. The default implementation of this route accepts `addresType` as a parameter. The route is mapped to `CheckoutAddressViewController`.
    public let addAddressURL = "addAddress"

    /// The URL for the Voucher Detail Screen. The default implementation of this route accpets the `voucher_id` parameter. The route is mapped to VoucherDetailViewController`.
    public let voucherDetailURL = "vouchers/detail/"

    /// The URL for the Classic Search Screen. The defaul implementation of this route is mapped to `SearchViewController`.
    public let classicSearchURL = "search/classic"

    /// The URL to navigate to the Home Screen with Search Bar presented. The default implementation of this route is mapped to present the `HomeViewController` with the  search bar.
    ///
    /// - ToDo: The defaul implementation of this route makes a lot of assumptions. See if it can be improved.
    public let searchOnHomeURL = "home/search"

    /// The URL for the Product Filters Screen.
    ///
    /// - Note: The default implementation depends on the `PoqFilter` instance provided as the value for the key `filterData` and the `ProductListViewController` instance provided as the value for the key `delegate` in the `navigationContext` dictionary property of `NavigationHelper`.
    ///  The route is mapped to present either `ProductListDynamicFiltersViewController` or `ProductListFiltersController` based on the value of the `productListFilterType` property of `AppSettings`.
    ///
    /// - ToDo: Simplify/Refactor this logic.
    public let filterUrl = "filter"

    /// The URL for the Checkout Order Summary Screen ( Native Checkout ). The default implementation of this route is mapped to `CheckoutOrderSummaryViewController`.
    public let checkoutOrderSummaryURL = "checkoutOrderSummary"

    /// The URL for the Vouchers Dashboard Screen. The default implementation for this route checks if a ViewController of type `VouchersCategoryViewController` is present in the navigation stack of any of the navigation controllers in the root tab bar controller and presents it if it exists.
    ///
    /// - ToDo: Improve logic if possible,
    public let vouchersUrl = "vouchers"

    // Debug supprt URL

    /// The URL to change the severity level of the Logger. The default implementation of this route accepts the `severityLevel` parameter.
    public let debugLoggerSupportUrl = "debug/logger"

    /// The URL to toggle the preview mode. The default implementation of this route accepts the `isPreview` parameter.
    public let debugPreviewsSupportUrl = "debug/preview" // can have 2 optional parameters: isPreview: Int, dateValue: String
    
    /// Used to pass objects between ViewControllers.
    public var navigationContext: [String: Any]?

    /// Used to redirect to Web klarna payment validation
    public let klarnaURL = "klarna"

    /// Used to display the size selector
    public let sizeSelector = "sizeSelector"

    /**
        A setter for the `rootTabBarViewController` property.
     
        - parameter rootTabBarViewController: The UITabBarController instance that we want the `NavigationHelper` property rootTabBarViewController` to point to.
     
        - ToDo: Refactor to provide better name.
    */
    public final func setupTabBarNavigation(_ rootTabBarViewController: UITabBarController) {

        self.rootTabBarViewController = rootTabBarViewController

    }

    /**
        A setter for the `rootNavigationViewController` property.
     
        - parameter rootNavigationViewController: The UINavigationController instance that we want the `NavigationHelper` property `rootNavigationViewController` to point to.
     
        - ToDo: Refactor to provide better naming.
    */
    public final func setupNavigation(_ rootNavigationViewController: UINavigationController) {

        self.rootNavigationViewController = rootNavigationViewController
    }
    
    /**
     Registers a deeplink with Turnpike.
     
     - parameter deeplink: deeplink with will be associated with closure.
     - parameter toDestination: closure which will be called if deeplink will be triggered.
     
     - Note: This method must be used instead direct usage of `Turnpike.mapRoute`.
     */
    public final func mapRoute(_ deeplink: String, toDestination destination: @escaping RouteCompletionBlock) {
        Turnpike.mapRoute(deeplink, toDestination: destination)
    }
    
    // MARK: - Main routes
    /**
        Sets up all the navigation routes.
    */

    public final func setupRoutes() {

        Turnpike.mapRoute("\(klarnaURL)", toDestination: { (request: TurnpikeRouteRequest?) in
            if let sourceToken = request?.queryParameters?["token"], let fileURL = FileInjectionResolver.fileURL(named: "klarna", extension: "html") {
                let klarnaWebViewController = KlarnaWebViewController(sourceToken, url: fileURL)
                self.openController(klarnaWebViewController, modalWithNavigation: false, isSingleModal: true)
            }
        })
        
        // MARK: - Onboarding
        Turnpike.mapRoute("\(onboardingURL)", toDestination: { (request: TurnpikeRouteRequest?) in
            let onboardingViewController = OnboardingViewController(nibName: "OnboardingView", bundle: nil)
            self.openController(onboardingViewController, modalWithNavigation: true, isSingleModal: true)
        })
        
        // MARK: - Checkout Order Summary
        Turnpike.mapRoute("\(checkoutOrderSummaryURL)") { _ in
            let paymentProviders = ParsePaymentProvidersMap()

            typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>
            typealias CheckoutFlowControllerType = CheckoutOrderSummaryViewController<CheckoutItemType, PoqOrderItem>
            typealias ViewModelType = CheckoutFlowControllerType.ViewModel

            let checkoutSteps = ViewModelType.createCheckoutSteps(paymentProviders)
            let viewModel = ViewModelType(paymentProvidersMap: paymentProviders, checkoutSteps: checkoutSteps)
            let viewController = CheckoutFlowControllerType(viewModel: viewModel)
            viewController.hidesBottomBarWhenPushed = true
            self.openController(viewController)
        }

        // MARK: - VOUCHERS
        Turnpike.mapRoute("\(voucherDetailURL):voucher_id", toDestination: { (request: TurnpikeRouteRequest?) in

            guard let voucherIdString = request?.routeParameters?["voucher_id"], let voucherId = Int(voucherIdString) else {
                Log.error("Attempt to open voucher details for incorrect voucher id")
                return
            }

            let voucherDetailsViewController = VoucherDetailViewController(nibName: "VoucherDetailView", bundle: nil)
            voucherDetailsViewController.voucherId = voucherId

            self.openController(voucherDetailsViewController, modalWithNavigation: true)

        })

        // MARK: - ---- CATEGORY ------ ///
        Turnpike.mapRoute("\(categoryURL):category_id", toDestination: { (request: TurnpikeRouteRequest?) in

            let categoryIdValue = request?.routeParameters?["category_id"]
            let categoryTitle = request?.title ?? ""
            var isModal = false

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let categoryList: CategoryListViewController = CategoryListViewController()
            categoryList.selectedCategoryTitle = categoryTitle
            categoryList.source = categoryTitle

            if let categoryIdValueUnwrapped = categoryIdValue, let categoryId = Int(categoryIdValueUnwrapped) {
                categoryList.selectedCategoryId = categoryId
            } else {

                // Category id couldn't be resolved
                Log.warning(" Category id couldn't be resolved. Main category is going to be loaded")
                categoryList.selectedCategoryId = 0
                categoryList.selectedCategoryTitle = ""
            }

            categoryList.isModal = isModal

            // Check if navigation is from tabbar
            self.openController(categoryList, modalWithNavigation: isModal)
            // NOTE: what if the root Navigation is not the tab bar?

        })

        // MARK: - ---- BRANDS ------ ///
        Turnpike.mapRoute("\(brandsURL)", toDestination: { (request: TurnpikeRouteRequest?) in

            var isModal: Bool=false

            if let modal: String=request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let categoryTitle: String = "Brands"
            let categoryList: CategoryListViewController = CategoryListViewController()
            categoryList.selectedCategoryTitle = categoryTitle.descapeStr()
            let categoryId = -1
            categoryList.selectedCategoryId = categoryId
            categoryList.sort = true

            categoryList.isModal = isModal

            // Check if navigation is from tabbar
            self.openController(categoryList, modalWithNavigation: isModal)
            //NOTE: what if the root Navigation is not the tab bar?

        })

        // MARK: - ---- PRODUCTS IN CATEGORY ------ ///
        Turnpike.mapRoute("\(productsInCategoryURL):category_id", toDestination: { (request: TurnpikeRouteRequest?) in

            let categoryIdValue = request?.routeParameters?["category_id"]

            var externalId = categoryIdValue

            if let externalIdValue = (request?.queryParameters?["external_id"]) {
                externalId = externalIdValue
            }

            if let categoryIdValueUnwrapped = categoryIdValue, let categoryId = Int(categoryIdValueUnwrapped) {

                let productList: ProductListViewController = ProductListViewController(nibName: "ProductListView", bundle: nil)
                productList.selectedCategoryId = categoryId

                if let categoryTitle = request?.title, !categoryTitle.isEmpty {

                    productList.selectedCategoryTitle = categoryTitle

                    if let brandId = (request?.queryParameters?["brand_id"]) {
                        productList.brandId = brandId
                    }

                    productList.source = categoryTitle
                }

                if let externalIdUnwrapped = externalId {
                    productList.selectedExternalCategoryId = externalIdUnwrapped
                }

                // Check if navigation is from tabbar
                self.openController(productList)
            } else {

                // Category id is invalid
                self.openURL(self.appURLSchema)
            }

        })

        Turnpike.mapRoute("\(productsInBrandedCategoryURL):category_id", toDestination: { (request: TurnpikeRouteRequest?) in

            let categoryIdValue = request?.routeParameters?["category_id"]

            var externalId = categoryIdValue

            if let externalIdValue = (request?.queryParameters?["external_id"]) {
                externalId = externalIdValue
            }

            if let categoryIdValueUnwrapped = categoryIdValue, let categoryId = Int(categoryIdValueUnwrapped) {

                let productList: BrandedProductListViewController = BrandedProductListViewController(nibName: "BrandedProductListView", bundle: nil)
                productList.selectedCategoryId = categoryId

                if let categoryTitle = request?.title, !categoryTitle.isEmpty {
                    productList.selectedCategoryTitle = categoryTitle
                    productList.source = categoryTitle
                }

                if let externalIdUnwrapped = externalId {
                    productList.selectedExternalCategoryId = externalIdUnwrapped
                }

                // Check if navigation is from tabbar
                self.openController(productList)
            } else {

                // Category id is invalid
                self.openURL(self.appURLSchema)
            }

        })

        // MARK: - ---- BRAND LANDING PAGE ------ ///
        Turnpike.mapRoute("\(storyDetailURL):story_id", toDestination: { request in

            if let storyIdString = request?.routeParameters?["story_id"] {
                let storyId = Int(storyIdString) ?? 0

                let viewController: StoryDetailViewController = StoryDetailViewController(storyId: storyId)
                self.openController(viewController)
            }
        })

        // MARK: - ---- PRODUCTS IN GROUP ------ ///
        Turnpike.mapRoute("\(productsInGroupURL)", toDestination: { _ in

            guard let groupedProduct = self.navigationContext?["groupedProduct"] as? PoqProduct else {
                Log.error("No grouped product in navigationContext. Cannot load grouped product.")
                return
            }

            let groupedProductListViewController = ProductGroupedListViewController(nibName: "ProductGroupedListView", bundle: nil)
            groupedProductListViewController.groupedProduct = groupedProduct
            self.openController(groupedProductListViewController)
        })

        // MARK: - ---- PRODUCTS RECENTLY VIEWED ------ ///
        Turnpike.mapRoute("\(productsRecentlyViewedURL)", toDestination: { _ in

            let viewControler = RecentlyViewedProductListViewController(nibName: "RecentlyViewedProductListView", bundle: nil)
            if let service = self.navigationContext?["RecentlyViewedService"] as? PoqProductsCarouselService {
                viewControler.viewModel = service
            }

            self.openController(viewControler)
        })

        // MARK: - ---- ORDER HISTORY ------ ///
        Turnpike.mapRoute("\(orderHistoryURL)", toDestination: { _ in

            let orderListViewController = OrderListViewController(nibName: "OrderListViewController", bundle: nil)
            self.openController(orderListViewController)

        })

        // MARK: - ---- ORDER DETAIL SUMMARY ------ ///
        Turnpike.mapRoute("\(orderSummaryURL):orderKey", toDestination: { request in
            //externalOrderId

            if let orderKey =  request?.routeParameters?["orderKey"] {
                if AppSettings.sharedInstance.orderDetailViewType == OrderDetailViewType.missguided.rawValue {

                    typealias OrderItemType = PoqOrderItem

                    let externalOrderId = request?.queryParameters?["externalOrderId"]
                    let orderDetail = OrderConfirmationViewController<OrderItemType>(orderKey: orderKey, externalOrderId: externalOrderId)
                    orderDetail.isOrderConfirmationPage = false
                    self.openController(orderDetail)
                } else {
                    // let orderDetail:OrderDetailViewController = OrderDetailViewController(nibName:"OrderDetailViewController", bundle:nil)
                    let orderDetail: OrderDetailViewController = OrderDetailViewController(nibName: "OrderDetailViewController", bundle: Bundle(for: OrderDetailViewController.self))
                    orderDetail.orderKey = orderKey
                    self.openController(orderDetail)
                }
            } else {

                Log.verbose("order key  is invalid.")
            }
        })

        // MARK: - ---- STORE LIST ------ ///
        Turnpike.mapRoute("\(storeListURL)", toDestination: { _ in

            
            let storesViewController =  StoresViewController.initAs(.findStore)
            NavigationHelper.sharedInstance.openController(storesViewController)

        })

        // MARK: - ---- STORE LIST FAVORITE ------ ///
        Turnpike.mapRoute("\(storeListFavoriteURL)", toDestination: { _ in
            
            let storesViewController =  StoresViewController.initAs(.setFavoriteStore)
            NavigationHelper.sharedInstance.openController(storesViewController)
        })

        // MARK: - ---- STORE DETAIL ------ ///
        Turnpike.mapRoute("\(storeURL):store_id", toDestination: { request in

            guard let storeIdValue: String = request?.routeParameters?["store_id"],
                let storeId: Int = Int(storeIdValue) else {

                    Log.error("We were unable to parse store id from requies")
                    return
            }

            let storeDetail: StoreDetailViewController = StoreDetailViewController(nibName: "StoreDetailView", bundle: nil)
            storeDetail.selectedStoreId = storeId
            storeDetail.selectedStoreTitle = request?.title ?? ""
            NavigationHelper.sharedInstance.openController(storeDetail)
            
            PoqTrackerV2.shared.storeFinder(action: StoreFinderAction.details.rawValue, storeName: request?.title ?? "")

        })

        // MARK: - ---- LOOKBOOK ------ ///
        Turnpike.mapRoute("\(lookbookURL)", toDestination: { request in

            var lookbookId = 0
            var title = ""
            if let stringLookBookId: String = request?.queryParameters?["lookbook_id"], let validLookBookId = Int(stringLookBookId) {
                lookbookId = validLookBookId
            }
            if let validTitle: String = request?.queryParameters?["title"] {
                title = validTitle
            }
            // Get id
            if lookbookId > 0 {

                // Get title
                let lookbookTitle: String = title

                let lookbookViewController: LookbookViewController = LookbookViewController(nibName: "LookbookView", bundle: nil)
                lookbookViewController.lookbookId = lookbookId
                lookbookViewController.lookbookTitle = title
                lookbookViewController.source = lookbookTitle
                self.openController(lookbookViewController)

            } else {

                Log.verbose("Lookbook id is invalid.")
            }

        })

        // MARK: - ---- SCANNER ------ ///
        Turnpike.mapRoute("\(scanURL)", toDestination: { _ in

            let scanVeiwController = ScannerViewController(nibName: "ScannerViewController", bundle: nil)
            self.openController(scanVeiwController, modalWithNavigation: true, isViewAnimated: true)

        })
        
        // MARK: - ---- VISUALSEARCH ------ ///
        Turnpike.mapRoute("\(visualSearchURL)", toDestination: { _ in
            var viewController: UIViewController
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
            } else {
                let alertViewController = UIAlertController(title: "ERROR".localizedPoqString, message: "VISUAL_SEARCH_UNAVAILABLE".localizedPoqString, preferredStyle: UIAlertControllerStyle.alert)
                alertViewController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: nil))
                viewController = alertViewController
            }
            self.openController(viewController, modalWithNavigation: true, isViewAnimated: true)
        })
        
        // MARK: - ---- PAGE LIST ------ ///
        Turnpike.mapRoute("\(pageListURL):parent_id", toDestination: { request in

            let parentPageIdValue = request?.routeParameters?["parent_id"]
            let pageTitle = request?.title ?? ""
            var isModal = false

            if let modal: String=request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let nibBundle = NibInjectionResolver.findBundle(nibName: "PageListView")
            let pageList = PageListViewController(nibName: "PageListView", bundle: nibBundle)
            pageList.selectedParentPageTitle = pageTitle

            if let parentPageIdValueUnwrapped = parentPageIdValue, let parentPageId = Int(parentPageIdValueUnwrapped) {
                pageList.selectedParentPageId = parentPageId
            } else {

                // parent page id couldn't be resolved
                Log.warning("Parent Page id couldn't be resolved. Root page list is going to be loaded")
                pageList.selectedParentPageId = 0
                pageList.selectedParentPageTitle = ""
            }

            pageList.isModal = isModal

            // Check if navigation is from tabbar
            if AppSettings.sharedInstance.tab5 == TabBarItems.more.rawValue {
                pageList.isASubPageInMoreTab = true
                self.openController(pageList, modalWithNavigation: isModal)
            } else {
                self.openController(pageList, modalWithNavigation: isModal)
                pageList.isFromTab = false
            }

        })

        // MARK: - ---- PAGE DETAIL ------ ///
        Turnpike.mapRoute("\(pageDetailURL):page_id", toDestination: { request in

            let pageIdValue = request?.routeParameters?["page_id"]
            let pageTitle = request?.title ?? ""
            var isViewAnimated = true
            var isModal = false

            if let viewAnimated: String = request?.queryParameters?["is_animated"] {
                isViewAnimated = viewAnimated.toBool()
            }
            if let modal = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let pageDetail: PageDetailViewController = PageDetailViewController(nibName: "PageDetailView", bundle: nil)
            pageDetail.selectedPageTitle = pageTitle
            pageDetail.isModalView = isModal

            if let pageIdValueUnwrapped = pageIdValue, let pageId = Int(pageIdValueUnwrapped) {
                pageDetail.selectedPageId = pageId
            } else {

                // Category id couldn't be resolved
                Log.warning("Page id couldn't be resolved. Main page list is going to be loaded")
                pageDetail.selectedPageId = 0
                pageDetail.selectedPageTitle = ""
            }

            if isModal {

            }
            // Check if navigation is from tabbar
            self.openController(pageDetail, modalWithNavigation: isModal, isViewAnimated: isViewAnimated)

        })

        // MARK: - ---- LOGIN ------ ///
        Turnpike.mapRoute("\(loginURL)", toDestination: { request in

            Log.verbose("Resolving loginURL ")
            
            let isModal = request?.queryParameters?["is_modal"]?.toBool() ?? false
            let isViewAnimated = request?.queryParameters?["is_animated"]?.toBool() ?? true
            let isFromLoginOptions = request?.queryParameters?["is_FromLoginOptions"]?.toBool() ?? false

            let loginController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            loginController.isModalView = isModal
            loginController.isFromLoginOptions = isFromLoginOptions

            self.openController(loginController, modalWithNavigation: isModal, isViewAnimated: isViewAnimated)

        })

        // MARK: - ---- SIGN UP ------ ///
        Turnpike.mapRoute("\(signUpURL)", toDestination: { request in

            Log.verbose("Resolving signUpURL ")

            var isModal: Bool = true

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let signUpController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)

            self.openController(signUpController, modalWithNavigation: isModal)

        })

        // MARK: - ---- PRODUCT DETAIL ------ ///
        Turnpike.mapRoute("\(productDetailURL):product_id", toDestination: { request in

            // A PDP always require a positive Integer to get data from Poq System
            // if product ID is 0 then external ID must be sent to retrieve data using client's product Id (HoF Only)
            // if both of parameters are missing, we just open home screen to keep user in the app as fallback

            guard let productIdValue = request?.routeParameters?["product_id"], !productIdValue.isEmpty else {

                Log.error("Product Id missing in URL. Home screen is going to be open.")
                self.openURL(self.appURLSchema)
                return
            }

            // All product detail view types should support the same deeplink scheme.
            // All product detail view types should conform PoqProductDetailPresentable for this purpose

            var productDetailViewController: PoqProductDetailPresenter?

            switch AppSettings.sharedInstance.pdpViewType {

            case ProductDetailViewType.classic.rawValue:
                productDetailViewController = ProductDetailViewController(nibName: "ProductDetailView", bundle: nil)

            case ProductDetailViewType.modular.rawValue:
                productDetailViewController = ModularProductDetailViewController(nibName: "ModularProductDetailView", bundle: nil)
            default:
                Log.error("PDP View Type is not valid. Check pdpViewType value in Developer Center")
                self.openURL(self.appURLSchema)

            }

            if let validTrackingSource = self.navigationContext?["trackingSource"] as? PoqTrackingSource {
                productDetailViewController?.trackingSource = validTrackingSource
            }

            productDetailViewController?.selectedProductId = Int(productIdValue)
            productDetailViewController?.selectedProductExternalId = request?.queryParameters?["external_id"]

            guard let productDetailViewControllerValidated = productDetailViewController as? PoqBaseViewController else {

                self.openURL(self.appURLSchema)
                return
            }

            self.openController(productDetailViewControllerValidated)

        })

        // MARK: - ---- GROUPED PRODUCT DETAIL ------ ///
        Turnpike.mapRoute("\(productsInBundleURL)", toDestination: { _ in

            guard let bundledProduct = self.navigationContext?["bundledProduct"] as? PoqProduct else {
                Log.error("No grouped product in navigation context. Cannot load grouped product view controller.")
                return
            }

            let productGroupedList = ProductBundleListViewController(nibName: "ProductGroupedListView", bundle: nil)
            productGroupedList.groupedProduct = bundledProduct
            self.openController(productGroupedList)
        })

        // MARK: - --- Filter View ----- ///

        Turnpike.mapRoute("\(filterUrl)", toDestination: { request in

            guard let filterData = self.navigationContext?["filterData"] as? PoqFilter else {
                return
            }

            var isModal = false

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            guard let delegate = self.navigationContext?["delegate"] as? ProductListViewController else {
                Log.error("Delegate required. Pass it as navigationContext with key delegate. ")
                return
            }

            var viewController: ProductListFiltersController

            if NetworkSettings.shared.productListFilterType == ProductListFiltersType.static.rawValue {

                viewController = ProductListFiltersController(nibName: "ProductListFiltersView", bundle: nil)

            } else {
                viewController = ProductListDynamicFiltersViewController(nibName: "ProductListDynamicFiltersView", bundle: nil)
            }

            viewController.filters = filterData
            viewController.delegate = delegate

            self.openController(viewController, modalWithNavigation: isModal, isViewAnimated: true)
        })

        // MARK: - ---- Product Reviews ------ ///
        Turnpike.mapRoute("\(reviewsURL):product_id", toDestination: { request in

            var isModal: Bool = true

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            if let productIdValue = request?.routeParameters?["product_id"], let productId = Int(productIdValue) {
                // Check if navigation is from tabbar
                let reviewsController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
                reviewsController.productId = productId
                reviewsController.isModal = isModal
                self.openController(reviewsController, modalWithNavigation: isModal)
            } else {
                // Product id is invalid
                self.openURL(self.appURLSchema)

            }

        })

        // MARK: - ---- PRODUCT LIST BY SEARCH ------ ///

        Turnpike.mapRoute("\(productsInSearchURL):keyword", toDestination: { request in

            if let productSearch: String = request?.routeParameters?["keyword"] {
                let productListController = ProductListViewController(nibName: "ProductListView", bundle: nil)
                productListController.searchQuery = productSearch
                productListController.selectedCategoryTitle = String(format: AppLocalization.sharedInstance.searchTitleFormat, productSearch.descapeStr())
                if let searchType = request?.queryParameters?["search_type"] {
                    productListController.searchType = searchType
                }
                self.openController(productListController)
            }

        })

        // MARK: - ---- BARCODE FULL SCREEN ------ ///
        Turnpike.mapRoute("\(barcodeURL):barcode_id", toDestination: { request in

            if let barcodeValue = request?.routeParameters?["barcode_id"] {
                let barcodeFullscreen = MyProfileBarcodeFullscreenViewController(nibName: "MyProfileBarcodeFullscreenViewController", bundle: nil)
                barcodeFullscreen.barcodeValue = barcodeValue
                self.openController(barcodeFullscreen, modalWithNavigation: true, isViewAnimated: true)
            }

        })

        // MARK: - ---- EDIT PROFILE ------ ///
        Turnpike.mapRoute("\(editMyProfileURL)", toDestination: { _ in
            Log.verbose("Resolving editMyProfile ")
            let isViewAnimated: Bool = true
            let isModal: Bool=false

            let editProfileViewController = EditMyProfileViewController(nibName: "EditMyProfileViewController", bundle: nil)
            editProfileViewController.isModalView = isModal

            self.openController(editProfileViewController, modalWithNavigation: isModal, isViewAnimated: isViewAnimated)

        })

        // MARK: - ---- MY PROFILE TAB ------ ///
        Turnpike.mapRoute("\(myProfileURL)", toDestination: { _ in

            Log.verbose("NavigationHelper: Selecting my profile tab")

            // Check if navigation is from tabbar
            if let tabbar = self.rootTabBarViewController {

                tabbar.selectedIndex = Int(AppSettings.sharedInstance.myProfileTabIndex)
                (tabbar as? TabBarViewController)?.setMiddleButtonUnselected()
            }

        })

        // MARK: - ---- WISHLISH TAB ------ ///
        Turnpike.mapRoute("\(wishlistURL)", toDestination: { _ in

            Log.verbose("NavigationHelper: Selecting wish tab")

            // Check if navigation is from tabbar
            if let tabbar = self.rootTabBarViewController {

                tabbar.selectedIndex = Int(AppSettings.sharedInstance.wishListTabIndex)
                (tabbar as? TabBarViewController)?.setMiddleButtonUnselected()
            } else {

                let wishlistViewController = WishlistViewController(nibName: "WishlistView", bundle: nil)
                self.openController(wishlistViewController)
            }

        })

        // MARK: - ---- SHOPPING BAG TAB ------ ///
        Turnpike.mapRoute("\(shoppingBagURL)", toDestination: { _ in

            Log.verbose("NavigationHelper: Selecting bag tab")

            // Check if navigation is from tabbar
            if let tabbar = self.rootTabBarViewController {

                tabbar.selectedIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
                (tabbar as? TabBarViewController)?.setMiddleButtonSelected()
            }

            if let bagViewController  = NavigationHelper.createBagViewController() {
                //bag view on the top right for Missguided

                let navigationController = PoqNavigationViewController(rootViewController: bagViewController)

                if let validAnimator = bagViewController.bagAnimator {
                    navigationController.transitioningDelegate = validAnimator
                }

                navigationController.modalPresentationStyle = UIModalPresentationStyle.custom

                self.presentViewController(self.getHostViewController(), controllerToPresent: navigationController, animated: true, completion: nil)

            }
        })

        // MARK: - ---- SHOP SCREEN ------ ///
        Turnpike.mapRoute("\(shopURL)", toDestination: { _ in

            Log.verbose("NavigationHelper: Selecting shop tab")

            if AppSettings.sharedInstance.tab2 == TabBarItems.shop.rawValue {

                // Shop tab is available
                // Check if navigation is from tabbar
                if let tabbar = self.rootTabBarViewController {

                    tabbar.selectedIndex = 1
                    (tabbar as? TabBarViewController)?.setMiddleButtonUnselected()
                }
            } else {

                // Load shopping view
                let shopViewController = ShopViewController(nibName: "ShopView", bundle: nil)
                shopViewController.isFromTab = false
                self.openController(shopViewController)

            }
        })

        // MARK: - ---- MY PROFILE ADDRESSBOOK ------ ///
        Turnpike.mapRoute("\(myProfileAddressBookURL)", toDestination: { _ in

            let myProfileAddressBook = MyProfileAddressBookViewController(nibName: "MyProfileAddressBookViewController", bundle: nil)
            self.openController(myProfileAddressBook, modalWithNavigation: false, isViewAnimated: true)

        })
        
        // MARK: - ---- CURRENCY SWITCHER  ------ ///
        Turnpike.mapRoute("\(changeCurrencyURL)", toDestination: { request in
            
            var isModal = false
            
            if let modal = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }
            
            let currencySelectionViewController = CurrencySwitcherViewController(nibName: CurrencySwitcherViewController.XibName, bundle: nil)
            self.openController(currencySelectionViewController, modalWithNavigation: isModal, isViewAnimated: true)
        })

        // MARK: - ---- COUNTRY SELECTION LIST ------ ///
        Turnpike.mapRoute("\(changeCountryURL)", toDestination: { request in

            var isModal = false
            
            if let modal = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let countrySelectionViewController = CountrySelectionViewController(nibName: "CountrySelectionView", bundle: nil)
            self.openController(countrySelectionViewController, modalWithNavigation: isModal, isViewAnimated: true)
        })

        // MARK: - ---- ACCOUNT/PASSWORD MANIPULATION ------ ///
        Turnpike.mapRoute("\(changePasswordURL)", toDestination: { request in

            guard let url: URL = URL(string: AppSettings.sharedInstance.changePasswordComponentUrl) else {
                return
            }
            var isModal: Bool = false

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let title: String = request?.title ?? AppLocalization.sharedInstance.changePasswordTitle
            let buttonTitle: String = AppLocalization.sharedInstance.changePasswordSaveTitle
            let js = AppSettings.sharedInstance.changePasswordSaveActionJS

            let webWrapperViewConroller: WebWrapperViewConroller = WebWrapperViewConroller(url: url, title: title, saveButtonTitle: buttonTitle, jsCode: js)
            self.openController(webWrapperViewConroller, modalWithNavigation: isModal, isViewAnimated: true)
        })

        Turnpike.mapRoute("\(forgetPasswordURL)", toDestination: { request in

            guard let url: URL = URL(string: AppSettings.sharedInstance.forgetPasswordComponentUrl) else {
                return
            }

            var isModal: Bool = false

            if let modal: String = request?.queryParameters?["is_modal"] {
                isModal = modal.toBool()
            }

            let title: String = request?.title ?? AppLocalization.sharedInstance.forgetPasswordTitle
            let buttonTitle: String = AppLocalization.sharedInstance.forgetPasswordSaveTitle
            let js = AppSettings.sharedInstance.forgetPasswordSaveActionJS

            let webWrapperViewConroller: WebWrapperViewConroller = WebWrapperViewConroller(url: url, title: title, saveButtonTitle: buttonTitle, jsCode: js)
            self.openController(webWrapperViewConroller, modalWithNavigation: isModal, isViewAnimated: true)
        })

        Turnpike.mapRoute("\(addAddressURL)", toDestination: { request in

            // query may contain address type
            var addressType = AddressType.NewAddress
            if let addressTypeString = request?.queryParameters?["addressType"],
                let existedAddressType = AddressType(rawValue: addressTypeString.descapeStr()) {
                addressType = existedAddressType
            }
            let addressCreation = CheckoutAddressViewController(nibName: CheckoutAddressViewController.XibName, bundle: nil)
            addressCreation.addressTitle = AddressHelper.getTitle(addressType, newBookAddress: false)
            addressCreation.addressType = addressType

            if let checkoutAddressProvider = self.navigationContext?["checkoutItem"] as? CheckoutAddressesProvider {
                addressCreation.checkoutAddressProvider = checkoutAddressProvider
            }

            self.openController(addressCreation, modalWithNavigation: false, isViewAnimated: true)
        })

        Turnpike.mapRoute("\(cartTransferURL)", toDestination: { _ in
            let viewController = WebViewCheckoutViewController()
            let navigationController = PoqNavigationViewController(rootViewController: viewController)
            NavigationHelper.sharedInstance.defaultTabBar?.present(navigationController, animated: true, completion: nil)
        })

        // MARK: - ---- CLASSIC SEARCH ------ ///
        Turnpike.mapRoute("\(classicSearchURL)", toDestination: { _ in

            let hostNavigationController = self.getHostNavigationViewController()
            guard let transitionview = hostNavigationController?.view else {
                return
            }

            UIView.transition(with: transitionview, duration: 0.1, options: .transitionCrossDissolve, animations: {
                () -> Void in

                let searchController = SearchViewController(nibName: SearchViewController.XibName, bundle: nil)
                hostNavigationController?.pushViewController(searchController, animated: false)
                
            }, completion:nil)
        })
        
        // MARK: - ---- COUPONS ------ ///
        Turnpike.mapRoute("\(vouchersUrl)", toDestination: { _ in

            guard let viewControllers = self.rootTabBarViewController?.viewControllers else {
                return
            }

            /// Find tab index, where UINavigationController with root view controller kind of VouchersCategoryViewController
            let indexOrNil = viewControllers.index(where: {
                guard let rootViewController = ($0 as? UINavigationController)?.viewControllers.first else {
                    Log.error("One of view controller in tabs didn't wrapped in UINavigationController")
                    return false
                }
                return rootViewController is VouchersCategoryViewController
            })
            guard let index = indexOrNil else {
                Log.error("We don't have VouchersCategoryViewController in tabs")
                return
            }

            self.rootTabBarViewController?.selectedIndex = index
            let navigationController = self.rootTabBarViewController?.viewControllers?[index] as? UINavigationController
            navigationController?.popToRootViewController(animated: false)

        })

        Turnpike.mapRoute("\(searchOnHomeURL)", toDestination: { _ in

            let homeTabIndex = Int(AppSettings.sharedInstance.homeTabIndex)
            guard let tabBarController = self.rootTabBarViewController as? TabBarViewController,
                let viewControllers = tabBarController.viewControllers,
                homeTabIndex < viewControllers.count else {
                Log.error("We can't find TabBarController")
                return
            }

            guard let viewController = viewControllers[homeTabIndex] as? PoqNavigationViewController,
                let homeViewController = viewController.viewControllers.first as? HomeViewController else {
                    Log.error("We didn't find any HomeViewController")
                    return
            }

            tabBarController.dismiss(animated: false, completion: nil)

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                if tabBarController.selectedIndex == homeTabIndex {
                    homeViewController.presentSearch()
                } else {
                    self.openURL(self.appURLSchema)
                    homeViewController.prepareToPresentSearch()
                }
            }
            _ = viewController.popToRootViewController(animated: false)
            CATransaction.commit()

        })

        // MARK: - ---- SIZE SELECTOR ------ ///

        Turnpike.mapRoute("\(sizeSelector)", toDestination: { (request: TurnpikeRouteRequest?) in

            guard let product = self.navigationContext?["product"] as? PoqProduct else {
                Log.error("No product in navigationContext. Cannot load size selector.")
                self.navigationContext = nil
                return
            }

            guard let sizeSelectionDelegate = self.navigationContext?["sizeSelectionDelegate"] as? SizeSelectionDelegate else {
                Log.error("No sizeSelectionDelegate in navigationContext. Cannot load size selector.")
                self.navigationContext = nil
                return
            }

            let productSizeSelectionViewController = ProductSizeSelectionViewController(nibName: "ProductSizeSelectionViewController", bundle: nil)

            productSizeSelectionViewController.sizeSelectionDelegate = sizeSelectionDelegate
            productSizeSelectionViewController.sizes = product.productSizes

            let sheetContainerViewController = SheetContainerViewController(rootViewController: productSizeSelectionViewController)
            sheetContainerViewController.sheetCornerRadius = CGFloat(15)
            self.openController(sheetContainerViewController, modalWithNavigation: true, isViewAnimated: true, isSingleModal: true)

            self.navigationContext = nil
        })

        // MARK: - ---- DEFAULT - HOME TAB ------ ///
        Turnpike.mapDefault { _ in

            Log.verbose("NavigationHelper: URL Couldn't be resolved. Home tab is opened by default")

            // Check if navigation is from tabbar
            if let tabbar = self.rootTabBarViewController {

                tabbar.selectedIndex = 0
                (tabbar as? TabBarViewController)?.setMiddleButtonUnselected()
            }

        }

        // MARK: Debug support
        // I tried to find better place to put this debug helpers, but I failed
        // If it will be found feel free to move
        Turnpike.mapRoute(debugLoggerSupportUrl, toDestination: { request in

            Log.update(withDeeplinkParams: request?.queryParameters)
        })

        Turnpike.mapRoute(debugPreviewsSupportUrl, toDestination: { request in

            // be default, if app won't get isPreview=false as query parameter, assume we are in preview
            var isPreview = true
            if let isPreviewString = request?.queryParameters?["isPreview"], isPreviewString == "false" {
                isPreview = false
            }

            guard isPreview else {
                // have to do this trick to specify type of step to remove
                let _: PreviewModeHelper? = PoqNetworkRequestConveyor.remove()
                return
            }

            let dateString = request?.queryParameters?["dateValue"]

            PoqNetworkRequestConveyor.add(step: PreviewModeHelper(dateString: dateString))
        })

    }

    /**
        Presents or pushes the provided ViewController on either the `topMostViewController` or the `topViewController` of the `rootNavigationViewController`.
        - parameter controller: The `UIViewController` to be presented or pushed.
        - parameter modalWithNavigation: A Bool indicating that the provided ViewController is to be presented.
        - parameter isViewAnimated: A Bool indicating that the ViewController is to be presented or pushed with animation.
        - parameter isSingleModal: A Bool indicating that the ViewController is to be presented as a single Modal and will not be the root ViewController in a navigation stack.
        - parameter topViewController: The UIViewController which is to be the ViewController on top of which the given ViewController is to be presented.
    */
    public final func openController(_ controller: UIViewController, modalWithNavigation: Bool = false, isViewAnimated: Bool = true, isSingleModal: Bool = false, topViewController: UIViewController? = nil) {

        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        // Check if navigation is from tabbar
        if let tabbar = self.rootTabBarViewController, let selectedViewController = tabbar.selectedViewController as? PoqNavigationViewController {
            self.rootNavigationViewController = selectedViewController
        }

        if modalWithNavigation {
            // A controller can present only one controller at a time
            // We do a loop to find the current presented viewcontroller
            var presentingViewController = getHostViewController()

            while let presentedViewController = presentingViewController?.presentedViewController {
                presentingViewController = presentedViewController
            }

            if isSingleModal {
                presentViewController(presentingViewController, controllerToPresent: controller, animated: isViewAnimated, completion: nil)
            } else {

                // Present PoqNavigationViewController and instert target controller as first item in the navigation
                // Otherwise, views pushed from modal will not be visible
                let navigationController = PoqNavigationViewController(rootViewController: controller)
                presentViewController(presentingViewController, controllerToPresent: navigationController, animated: isViewAnimated, completion: nil)
            }
        } else {

            pushViewController(getHostNavigationViewController(), controllerToPush: controller, animated: isViewAnimated)
        }
    }

    /**
        Returns the `topMostViewController` if it's not nil or the `topViewController` of the `rootNavigationViewController` property if it's present.
        Else a nil is returned.
    */
    public func getHostViewController() -> UIViewController? {

        if let hostViewController = topMostViewController {

            return hostViewController
        }

        if let topViewController = rootNavigationViewController?.topViewController {

            return topViewController
        }

        return nil
    }

    /**
        Returns the `navigationController` of the `topMostViewController` of if it is not nil or the `rootNavigationViewController` if it is present.
        Else a nil is returned.
    */
    public func getHostNavigationViewController() -> UINavigationController? {
        
        if let hostNavigationViewController = topMostViewController?.navigationController {

            return hostNavigationViewController
        }

        if let hostNavigationViewController = rootNavigationViewController {
            return hostNavigationViewController
        }

        return nil
    }

    /**
        Returns an instance of either the `BagViewController` or the `CheckoutBagViewController` based on the value of the `checkoutBagType` property.
    */
    fileprivate class func createBagViewController() -> PoqBaseBagViewController? {

        var bagViewController: PoqBaseBagViewController?

        switch AppSettings.sharedInstance.checkoutBagType {

        case BagType.transfer.rawValue:
            bagViewController = BagViewController(nibName: "BagView", bundle: nil)
            bagViewController?.isModal = true

        case BagType.native.rawValue:
            bagViewController = CheckoutBagViewController(nibName: CheckoutBagViewController.XibName, bundle: nil)
            bagViewController?.isModal = true

        default:
            break
        }

        return bagViewController
    }

    fileprivate func presentViewController(_ hostController: UIViewController?, controllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {

        hostController?.present(controllerToPresent, animated: animated, completion: completion)
        clearTopMostViewController()
    }

    fileprivate func pushViewController(_ hostNavigationController: UINavigationController?, controllerToPush: UIViewController, animated: Bool) {

        hostNavigationController?.pushViewController(controllerToPush, animated: animated)
        clearTopMostViewController()
    }

    /**
        Opens the provided URL as an external link , or the mail or telephone app, or resolves it as a deeplink based on whether the link has an `http`/`https` or the link doesn't have the url schema as a prefix or the it does have the url schema as a prefix
        - parameter urlString: absolute url string or local path
        - parameter context: navigation context, to pass objects between sender and receiver, for example existed object
     */
    public final func openURL(_ urlString: String, context: [String: Any]? = nil) {

        navigationContext = context
        if urlString.hasPrefix("http") {
            Log.verbose("NavigationHelper: resolve url \(urlString) as extenal")
            navigationContext = nil
            loadExternalLink(urlString)
            return
        }

        if urlString.hasPrefix("mailto") || urlString.hasPrefix("tel") {

            // Replace direct calling with a prompt
            let urlSanitized = urlString.replacingOccurrences(of: "tel:", with: "telprompt:")

            if let url = URL(string: urlSanitized) {
                UIApplication.shared.openURL(url)
            }

            return
        }

        let appURLSchema: String = NavigationHelper.sharedInstance.appURLSchema

        let separatorRange = urlString.range(of: "://")
        if urlString.hasPrefix(appURLSchema) || separatorRange == nil {

            Log.verbose("NavigationHelper: resolve url \(urlString) as local")
            // url has app scheme ot it is relative url, what means 100% local
            var fullUrlString: String = urlString
            if separatorRange == nil {
                fullUrlString = appURLSchema + urlString
            }

            if let url = URL(string: fullUrlString) {

                Turnpike.resolve(url)
                navigationContext = nil
                return
            }
        }

        navigationContext = nil
        if let url = URL(string: urlString) {

            //handle telephone number
            if UIApplication.shared.canOpenURL(url) || urlString.contains("tel://") {
                UIApplication.shared.openURL(url)

            } else {

                Log.warning("NavigationHelper: Unable to open url:\n %@", urlString)
            }
        } else {

            Log.warning("NavigationHelper: URL is not set:\n %@", urlString)
        }
    }
    
    /**
     Opens the `onboardingURL` deeplink modally on top of all other views.
     */
    public final func loadOnboarding() {
        openURL(appURLSchema + onboardingURL)
    }

    /**
        Opens the `productsInBundleURL` deeplink.
        - parameter product: The PoqProduct instance with which the Bundled PLP is to be displayed.
    */
    public final func loadBundledProduct(using product: PoqProduct) {

        let url = appURLSchema + productsInBundleURL

        let context: [String: Any] = ["bundledProduct": product]

        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url, context: context)

    }

    /**
        Opens the `productsInGroupURL` deeplink.
        - parameter product: The PoqProduct instance with which the Grouped PLP is to be displayed.
     */
    public final func loadGroupedProduct(with groupedProduct: PoqProduct) {

        let url = appURLSchema + productsInGroupURL

        Log.verbose("NavigationHelper: Opening Url: \(url)")
        let context: [String: Any] = ["groupedProduct": groupedProduct]
        openURL(url, context: context)
    }
    
    /**
        Opens the PDP deeplink
        - parameter productId: The internal Product ID with which to open the PDP
        - parameter externalId: The external Product ID with which to open the PDP
        - parameter topViewController: The UIViewController on top of which to present or push the PDP ViewController.
    */
    public final func loadProduct(_ productId: Int, externalId: String?, topViewController: UIViewController? = nil, isModal: Bool = false, isViewAnimated: Bool = true, sourceTracking: PoqTrackingSource? = nil, source: String? = nil, productTitle: String? = nil) {

        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        var url = appURLSchema + productDetailURL + "\(productId)?"

        if let existingExternalId = externalId {
            url += "external_id=\(existingExternalId.escapeStr())&"
        }
        var context = [String: Any]()

        if let validSourceTracking = sourceTracking {
            context = ["trackingSource": validSourceTracking]
        }

        url += "is_animated=\(isViewAnimated)&is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url, context: context)
        
        PoqTrackerV2.shared.viewProduct(productId: productId, productTitle: productTitle ?? "", source: source ?? "")
    }

    /**
        Opens the `categoryURL` with the given parameters.
        - parameter categoryId: The category ID to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter sets the `selectedCategoryId` property of the `CategoryListViewController` instance.
        - parameter categoryTitle: The category title to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter sets the `source` property of the `CategoryListViewController` instance.
    */
    public final func loadCategory(_ categoryId: Int, categoryTitle: String, topViewController: UIViewController? = nil, isModal: Bool = false) {

        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        let url = appURLSchema + categoryURL + "\(categoryId)?title=\(categoryTitle.escapeStr())&is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }

    /**
        Opens the `storyDetailURL` deepLink with the given parameters.
        - parameter storyId: The story ID to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is passed as the initialisation parameter for `storyId` in the `StoryDetailViewController`.
    */
    public final func loadStoryDetailPage(_ storyId: Int) {

        let url = appURLSchema + storyDetailURL + "\(storyId)"

        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }

    /**
        Opens the productsInCategoryURL deepLink with the given parameters.
     
        - parameter categoryId: The category ID to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedCategoryId` property of the `ProductListViewController` instance.
        - parameter categoryTitle: The category title to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedCategoryTitle` and `source` properties of the `ProductListViewController` instance.
        - parameter brandId: The brand Id to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `brandId` of the `ProductListViewController` instance.
    */
    public final func loadProductsInCategory(_ categoryId: Int, categoryTitle: String, brandId: String? = "", parentCategoryId: Int? = nil) {

        let escapedTitle = categoryTitle.escapeStr()
        var brandParameters: String = ""
        if let validBrandId = brandId {
            brandParameters = "&brand_id=\(validBrandId)"
        }

        let url = appURLSchema + productsInCategoryURL + "\(categoryId)?title=\(escapedTitle)" + brandParameters
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
        
        PoqTrackerV2.shared.viewProductList(categoryId: categoryId, categoryTitle: categoryTitle, parentCategoryId: parentCategoryId ?? 0)
    }

    /**
        Opens the `productsInBrandedCategoryURL` deepLink with the given parameters.
     
        - parameters categoryId: The category ID to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedCategoryId` property of the `BrandedProductListViewController` instance.
        - parameters categoryTitle: The category title to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedCategoryTitle` and `source` properties of the `BrandedProductListViewController` instance.
     
    */
    public final func loadProductsInBrandedCategory(_ categoryId: Int, categoryTitle: String) {

        let escapedTitle = categoryTitle.escapeStr()
        let url = appURLSchema + productsInBrandedCategoryURL + "\(categoryId)?title=\(escapedTitle)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }

    /**
        Opens the `productsInSearchURL` deepLink with the give parameters.
     
        - parameter search: The search string to be passed in the query parameters for the deepLink. In the default implementations for the route, this parameter is used to set the `searchQuery` parameter of the `ProductListViewController` instance.
    */
    public final func loadProductsBySearch(_ search: String, searchType: String? = nil) {
        
        let escapedSearch = search.escapeStr()
        
        var searchParameters = ""
        if let type = searchType {
            searchParameters = "?search_type=\(type)"
        }
        
        let url = appURLSchema + productsInSearchURL + "\(escapedSearch)" + searchParameters
        
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }

    /**
        Opens the `pageListURL` deepLink with the given parameters.
     
        - parameter parentPageId: The parent page Id to be passed in the query parameters for the deepLink. In the default implementations for the route, this parameter is used to set the `selectedParentPageTitle` parameter of the `PageListViewController` instance.
    */
    public final func loadPageList(_ parentPageId: Int, parentPageTitle: String, topViewController: UIViewController? = nil, isModal: Bool=false) {

        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        let escapedTitle = parentPageTitle.escapeStr()
        let url = appURLSchema + pageListURL + "\(parentPageId)?title=\(escapedTitle)&is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }

    /**
        Opens the `pageDetailURL` deepLink with the given parameters.
     
        - parameter pagId: The page Id to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedPageId` parameter of the `PageDetailViewController` instance.
        - parameter pageTitle: The page title to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedPageTitle` parameter of the `PageDetailViewController` instance.
    */
    public final func loadPageDetail(_ pageId: Int, pageTitle: String, isModal: Bool = false, isViewAnimated: Bool = true, topViewController: UIViewController? = nil) {

        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        let escapedTitle = pageTitle.escapeStr()
        let url = appURLSchema + pageDetailURL + "\(pageId)?title=\(escapedTitle)&is_animated=\(isViewAnimated)&is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening page detail Url: \(url)")
        openURL(url)
    }

    /**
        Opens the `storeURL` deepLink with the given parameters.
     
     - parameter storeId: The store ID to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedStoreId` parameter of the `StoreDetailViewController`.
     - parameter storeTitle: The store title to be passed in the query parameters for the deepLink. In the default implementation for the route, this parameter is used to set the `selectedStoreTitle` parameter of the `StoreDetailViewController`.
    */
    public final func loadStoreDetail(_ storeId: Int, storeTitle: String) {

        let urlString = storeURL +  String(storeId) + "?title=\(storeTitle.escapeStr())"
        openURL(urlString)
    }

    /**
        Calls the `openURL` method with only the `appURLSchema`. That is with only the URL schema but no deepLink. By default this resolves to the `HomeViewController`.
     
        - ToDo: There has to be a better way to open the `HomeViewController`!
    */
    @objc public final func loadHome() {

        openURL(appURLSchema)
    }

    /**
        Opens the `StoresViewController`.
     
        - parameter delegate: The `StoreListDelegate` instance that is set as the `storeSelectionDelegate` property for the `StoresViewController` instance.
     
    */
    public final func loadStoreSelection(_ delegate: StoreListDelegate) {

        let storesViewController = StoresViewController(nibName: "StoresView", bundle: nil)
        storesViewController.isStoreSelection = true
        storesViewController.controllerType = .setFavoriteStore
        // This delegate will be called back after selection
        storesViewController.storeSelectionDelegate = delegate
        self.openController(storesViewController)
    }

    // - ToDo: Remove this. Doesn't seem to be used anywhere!
    public final func loadSizeSelection(_ target: UIViewController) {
        self.openController(target, modalWithNavigation: true)
    }

    /**
        Opens the Store Detail screen if a favorite store has been selected. If not the Store list screen is displayed.
    */
    public final func loadMyStore() {

        if StoreHelper.getFavoriteStoreId() != 0 {

            loadStoreDetail(StoreHelper.getFavoriteStoreId(), storeTitle: "")

        } else {

            loadStoreList()
        }
    }

    /**
     
        Opens an external http or app link.
     
        - parameter url: The URL to be opened in a web view.
        - parameter topViewController: The `UIViewController` on top which the web view is to be presented.
        - parameter title: The title of the presented webview.
     
        - ToDo: Looks like we have possible cycle with loadExternalLink and openURL. Some refactoring required
     
    */
    public func loadExternalLink(_ url: String, topViewController: UIViewController? = nil, title: String? = nil) {

        if url.contains("http") {

            if let topVC = topViewController, topVC.presentedViewController != nil {

                topVC.dismiss(animated: true, completion: { () -> Void in

                    self.openWebView(url, title: title)
                    self.clearTopMostViewController()
                })
            } else if topViewController?.isPresentedModally == true {

                topViewController?.dismiss(animated: true, completion: {

                    self.openWebView(url, title: title)
                })
            } else {

                self.openWebView(url, title: title)
            }

        } else if url.hasPrefix("tel") || url.hasPrefix("mailto") {
            openURL(url)
        } else {
            if let topVC = topViewController {
                setUpTopMostViewController(topVC)
            }

            // Just fire to the deeplinking handler
            openURL(url)
        }
    }

    /**
        Opens the given URL in a `PoqWebViewController`.
     
        - parameter url: The URL to be opened.
        - parameter url: The title of the Web View.
     
    */
    public func openWebView(_ url: String, title: String?) {

        guard let url = URL(string: url) else {
            Log.error("initialization failure")
            return
        }
        
        let webviewController = PoqWebViewController(url: url)
        
        webviewController.targetURLPageTitle = title
        webviewController.show()
    }

    /**
        Opens the `shoppingBagURL` deepLink with the given parameters. The default implementation of this route opens up either the `BagViewController` or the `CheckoutBagViewController` based on an MB setting.
    
        - parameter topViewController: The `UIViewController` on top of which the Bag screen is to be presented.
    */
    public final func loadBag( topViewController: UIViewController? = nil ) {

        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController( topVC )
        }

        let url = appURLSchema + shoppingBagURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }

    /**
        Opens up the `classicSearchURL` deepLink. The default implementation of this route opens up `SearchViewController`.
     
        - parameter topViewController: This paramter just sets the `topMostViewController` property of `NavigationHelper`.
    */
    public final func loadClassicSearch(topViewController: UIViewController? = nil) {

        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        let url = appURLSchema + classicSearchURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }

    /**
        Opens the tab at the index set in the MB property `wishListTabIndex`. This property should be set to the tab with the `WishListViewController`.
    */
    public final func loadWishlist() {
        defaultTabBar?.selectedIndex = Int(AppSettings.sharedInstance.wishListTabIndex)
    }

    /**
        Opens up the `MySizesViewController`.
     
        - parameter mySizeType: The `MySizeType` enum value that sets the `mySizeType` property of `MySizesViewController`.
 
    */
    public final func loadMySizes(_ mySizeType: MySizeType) {

        Log.verbose("NavigationHelper: MySizes")

        let mySizesViewController: MySizesViewController = MySizesViewController(nibName: "MySizesView", bundle: nil)
        mySizesViewController.mySizeType = mySizeType
        openController(mySizesViewController)
    }

    /**
        Opens up the `lookBookURL` deepLink. The default implementation of this route opens up the `LookBookViewController`.
     
        - parameter id: The id value that is passed in the `lookbook_id` query paramenter in the deepLink. This value is used to set the `lookbookId` property of the `LookBookViewController`.
        - title: The title value that is passed in the query parameters in the deepLink. This value is used to set the `lookbookTitle` property of the `LookBookViewController`.
 
    */
    public final func loadLookbook(_ id: Int, title: String) {

        let url = appURLSchema + lookbookURL + "?lookbook_id=" + String(id) + "&title=\(title.escapeStr())"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }

    /**
        Pushes the `StoresViewController` onto the top of the navigation stack.
     
        - parameter isFavoriteStoreList: A boolean that indicates whether the `StoresViewController` should be opened for the Favorite Store mode or the Find In Store mode.
    */
    public final func loadStoreList(_ isFavoriteStoreList: Bool = false) {
        
        let url = appURLSchema + (isFavoriteStoreList ? storeListFavoriteURL : storeListURL)
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
        Opens the `productsRecentlyViewedURL` deepLink. The default implementation of this route opens the `RecentlyViewedProductListViewController`.
     
        - parameter withService: The `PoqProductsCarouselService` instance that the RecentlyViewedProductListViewController depends on. This parameter is passed through the `navigationContext`.
    */
    public final func loadRecentlyViewedProducts(withService service: PoqProductsCarouselService? = nil) {

        var context = [String: Any]()
        if let serviceUnwrapped = service {
            context["RecentlyViewedService"] = serviceUnwrapped
        }

        let url = appURLSchema + productsRecentlyViewedURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url, context: context)
    }
    
    /**
        Opens the `orderHistoryURL` deeplink. The default implementation of this deeplink opens the `OrderListViewController`.
    */
    public final func loadOrderHistory() {

        let url = appURLSchema + orderHistoryURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
        Opens the `orderSummaryURL` deeplink.
     
        - parameter orderKey: This is the value that is passed in the `orderKey` query parameter. This parameter sets the value of the `orderKey` property of either `OrderConfirmationViewController` or the `OrderDetailViewController` that the deeplink resolves to. This parameter is used to identify the order.
        - parameter externalOrderId: This is the value that is passed in the `externalOrderId` query parameter. This parameter sets the value of the `externalOrderId` of the `OrderConfirmationViewController` instance that the deeplink resolves to.  This parameter is used to identify the order externally.
    */
    public final func loadOrderSummary(_ orderKey: String, externalOrderId: String) {

        let url = appURLSchema + orderSummaryURL + orderKey + "?externalOrderId=\(externalOrderId)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
     
        Opens the `scanURL` deeplink. The default implementation of the deeplink opens the `ScannerViewController`.
     
    */
    public final func loadScan() {

        let url = appURLSchema + scanURL

        openURL(url)

    }
    
    /**
     
     Opens the `visualSearchURL` deeplink. The default implementation of the deeplink opens the `VisualSearchViewController`.
     
     */
    public final func loadVisualSearch() {
        let url = appURLSchema + visualSearchURL
        openURL(url)
    }
    
    /**
     
        Opens the `shopURL` deeplink. The default implementation of the deeplink opens the `ShopViewController`.
 
    */
    public final func loadShop() {

        let url = appURLSchema + shopURL
        openURL(url)
    }
    
    /**
     
        Presents the `ProductAvailabilityViewController`.
     
        - parameter product: The `PoqProduct` instance that is used to set the `product` property of the `ProductAvailabilityViewController`.
        - parameter storeStock: The `PoqStoreStock` instance that is used to set the `storeStock` property of the `ProductAvialabilityViewController`.
 
    */
    public final func loadProductAvailability(_ product: PoqProduct?, storeStock: PoqStoreStock?) {

        Log.verbose("NavigationHelper: ProductAvailablity")
        let productAvailability: ProductAvailabilityViewController = ProductAvailabilityViewController(nibName: "ProductAvailabilityView", bundle: nil)
        productAvailability.product = product
        productAvailability.productStock = storeStock
        openController(productAvailability, modalWithNavigation: true, isViewAnimated: true)
    }
    
    /**
        Opens the `brandsURL` deeplink. The default implementation of this URL opens the `CategoryListViewController`.
     
        - parameter topViewController: This parameter sets the `topMostViewController` property of the `NavigationHelper`.
        - parameter isModal: This parameter decides whether the ViewController is presented as a modal or pushed.
    */
    public final func loadBrands(_ topViewController: UIViewController? = nil, isModal: Bool = false) {

        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }

        let url = appURLSchema + brandsURL + "?is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)

    }
    
    /**
 
        Opens the `loginURL` deeplink. The default implementation of this route is mapped to the `LoginViewController`.
     
        - parameter isModal: This parameter decides whether the ViewController is presented modally or pushed.
        - parameter isViewAnimated: This parameter decides whether the transition is animated or not.
 
    */
    public final func loadLogin(isModal modal: Bool = AppSettings.sharedInstance.isLoginViewPresentedModally,
                                isViewAnimated: Bool = true, isFromLoginOptions: Bool = false) {

        let url = appURLSchema + loginURL + "?is_modal=\(modal)&is_animated=\(isViewAnimated)&is_FromLoginOptions=\(isFromLoginOptions)"

        openURL(url)
    }
    
    /**
 
        Opens the `signUpURL` deeplink. The default implementation of this route is mapped to the `SignUpViewController`.
    */
    public final func loadSignUp(isModal modal: Bool = AppSettings.sharedInstance.isSignUpViewPresentedModally) {

        let url = appURLSchema + signUpURL + "?is_modal=\(modal)"

        openURL(url)
    }
    
    /**
        Opens the `addAddressURL`. The default implementation for this deeplink opens the `CheckoutAddressViewController`.
     
        - parameter addressType: This parameter provides the value for the `addressType` query parameter. It is used to set the `addressType` property of the `CheckoutAddressViewController`.
        - parameter title: This parameter provides the value for the `title` query parameter. It is used to set the `addressTitle` property of the `CheckoutAddressViewController`.
        - parameter checkoutAddressesProvider: This parameter provides the value that is used to set the `checkoutAddressProvider` property of the `CheckoutAddressViewController`. It is passed in the `navigationContext` dictionary with a key of `checkoutItem`.
     
    */
    public final func loadAddAddress(_ addressType: AddressType, title: String?, checkoutAddressesProvider: CheckoutAddressesProvider? = nil) {

        var url = appURLSchema + addAddressURL + "?addressType=\(addressType.rawValue.escapeStr())"
        if let existedTitle = title {
            url += "&title=\(existedTitle.escapeStr())"
        }

        // TODO: here we will do a short term fix - we will use hidden, not declared key, first and dirty time we pass objects
        var context: [String: Any]?
        if let existingCheckoutItem = checkoutAddressesProvider {
            context = ["checkoutItem": existingCheckoutItem]
        }

        openURL(url, context: context)
    }
    
    /**
        Opens the `filterUrl`. The default implementation of this deeplink opens either `ProductListDynamicFiltersViewController` or `ProductListFiltersController` based on the value of the `productListFilterType` property of `AppSettings`.
     
        - parameter delegate: The `FilterViewControllerDelegate` instance that is used to set the `delegate` property of the `ProductListDynamicFiltersViewController` or `
    */
    public final func showFilter(_ delegate: ProductListViewController? = nil, filterData: PoqFilter? = nil, isModal: Bool = false) {

        guard let data = filterData else {
            return
        }

        let url = appURLSchema + filterUrl + "?is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")

        var context: [String: Any]?
        if let delegateUnwrapped = delegate {
            context = ["delegate": delegateUnwrapped,
                       "filterData": data]
        }

        openURL(url, context: context)
    }

    /**
        Opens the reviewsURL deeplink. The default implementation of this deeplink opens the `ReviewsViewController`.
     
        - parameter productId: This parameter sets the value for the `productId` query parameter. In the default implementation for this route this value sets the `productId` property of the `ReviewsViewController` instance.
        - parameter topViewController: This parameter sets the `topMostViewController` of the `NavigationHelper`
        - parameter isModal: This parameter decides if the ViewController is presented modally.
    */
    public final func loadReviews(_ productId: Int, topViewController: UIViewController? = nil, isModal: Bool = true) {
        //if there is top modal VC then set up navigation on top of that.
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }
        let url = appURLSchema + reviewsURL + "\(productId)" + "?is_modal=\(isModal)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }

    /**
        Opens the `barcodeURL` deeplink. The default implementation of this deeplink opens the `MyProfileBarcodeFullscreenViewController`.
     
        - parameter barcodeValue: This parameter is used to set the `barcodeValue` property of `MyProfileBarcodeFullscreenViewController`. It is the barcode to be displayed.
     
    */
    public final func loadBarcode(_ barcodeValue: String) {
        let url = appURLSchema + barcodeURL + barcodeValue
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
        This is a setter method for the `topMostViewController` property.
     
        - parameter topViewController: The `UIViewController` instance to set the `topMostViewController` property to.
    */
    public final func setUpTopMostViewController(_ topViewController: UIViewController?) {
        topMostViewController = topViewController
    }
    
    /**
     
        Opens the `editMyProfileURL` deeplink. The default implementation of this deeplink opens the `EditMyProfileViewController`.
     
    */
    public final func loadEditMyProfile() {
        let url = appURLSchema + editMyProfileURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
     
        TODO: Remove this implementation!
 
    */
    public final func loadLayarViewController(_ isFromHome: Bool = false) {

        let url = appURLSchema + layarURL + "?isFromHome=\(isFromHome)"
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
     
        Sets the `topMostViewController` property to nil.
 
    */
    public final func clearTopMostViewController() {
        topMostViewController = nil
    }
    
    /**
     
        Opens the deeplink URL set in the `continueShoppingDeeplinkURL`. By default it is set to open the `shop` tab.
 
    */
    public final func continueShopping() {
        let url: String = appURLSchema + AppSettings.sharedInstance.continueShoppingDeeplinkURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
 
        Opens the cartTransferURL deeplink. The default implementation opens a `WebViewCheckoutViewController` instance.
 
    */
    public final func openCartTransfer() {
        let url: String = appURLSchema + cartTransferURL
        Log.verbose("NavigationHelper: Opening Url: \(url)")
        openURL(url)
    }
    
    /**
     
     Opens the klarnaURL deeplink. The default implementation opens a `KlarnaWebViewController` instance.
     
     */
    public final func openKlarnaWeb(token: String, topViewController: UIViewController? = nil) {
        if let topVC = topViewController {
            setUpTopMostViewController(topVC)
        }
        let url: String = appURLSchema + klarnaURL + "?token=" + token
        Log.verbose("NavigationHelper: Opening Klarna Url: \(url)")
        openURL(url)
    }
    
    // Create the page detail link.
    public final func pageDetailLink(pageId: String, title: String) -> String {
    
        let escapedTitle = title.escapeStr()
        let path = NavigationHelper.sharedInstance.appURLSchema + NavigationHelper.sharedInstance.pageDetailURL + pageId
        let urlString = path + "?title=\(escapedTitle)&is_modal=false"
        return urlString
    }

    /// Displays the size selector
    public final func displaySizeSelector(for product: PoqProduct, delegate: SizeSelectionDelegate?) {

        var context: [String: Any] = ["product": product]

        if let delegate = delegate {
            context["sizeSelectionDelegate"] = delegate
        }

        openURL(sizeSelector, context: context)
    }
}
