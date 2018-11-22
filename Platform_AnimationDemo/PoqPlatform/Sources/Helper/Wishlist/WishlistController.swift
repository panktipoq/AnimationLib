import Foundation
import PoqNetworking
import PoqModuling
import PoqUtilities

let wishlistChangeNotification: String = "PoqWishlistCountChanged"

/**
 The wish list logic is as follows:
 
 - When application start,
   import favorites from the backend to the local storage if they have not ever been imported before.

 - When the user sets a favorite,
   save the product id to the backend, and to local storage.
 
 - When the wishlist screen is shown,
   import the favorites from the backend to the local storage.
 
 This is used from many places:
 
 - CountrySelectionViewController - when switching country.
 - MyProfileViewController - on reload data. Maybe it shows the favorite count somewhere?
 - PoqMyProfileListService - on log out.
 - PoqProductInfoContentBlockView - on cell set up
 - PoqProductsCarousel - on cell set up, and like toggled
 - ProductDetailViewController - on cell set up, product detail downloaded, and like toggled
 - ProductListViewCell - on cell set up, and like toggled
 - ProductListViewController - when the screen loads and there is no category selected
 - ProductListViewPeek - when clicking the like action
 - SplashViewController: on viewDidLoad it calls replaceOnLaunchIfNeeded()
 - TinderViewModel - when swiping right (like)
 - WishlistViewController - Updates the totals when a wishlistChangeNotification is received
 - WishlistViewModel - I don’t know.
 */
public class WishlistController {
    
    private let apiClient: WishlistApiClient
    private let localStorage: WishlistLocalStorage
    private let tracker = WishlistTracker()
    
    public static var shared = WishlistController.create()
    
    @objc private var didFetchOnLaunch: Bool {
        get { return UserDefaults.standard.bool(forKey: #keyPath(didFetchOnLaunch)) }
        set { UserDefaults.standard.set(newValue, forKey: #keyPath(didFetchOnLaunch)) }
    }
    
    public static func create() -> WishlistController {
        guard let store = PoqDataStore.store else {
            fatalError("Expected to find a persistence implementation at PoqDataStore.store.")
        }
        return WishlistController(userId: User.getUserId(), store: store)
    }
    
    public init(userId: String, store: DataStore) {
        apiClient = WishlistApiClient(userId: userId)
        localStorage = WishlistLocalStorage(store: store)
        localStorage.addChangeObserver(self) { (_, favorites) in
            self.postChangeNotification()
            self.updateBadge(count: favorites.count)
        }
    }
    
    func postChangeNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: wishlistChangeNotification), object: self)
    }
    
    func updateBadge(count: Int) {
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.wishListTabIndex), value: count)
    }
    
    func setupRemoteNotifications() {
        if AppSettings.sharedInstance.pushRegistrationType == PushRegistrationType.afterLikeOrAddToBag.rawValue {
            PoqUserNotificationCenter.shared.setupRemoteNotifications()
        }
    }
    
    /// Used to perform a once-per-installation import during launch.
    public func fetchOnLaunchIfNeeded() {
        if !didFetchOnLaunch {
            fetchProductIds { _ in
                self.didFetchOnLaunch = true
            }
        }
    }
    
    public var localFavoritesCount: Int {
        return localStorage.favoritesCount()
    }
    
    // MARK: - Local and remote operations
    
    // Overwrite local favorites with remote favorites.
    public func fetchProductIds(completion: @escaping (Result<Void>) -> Void = { _ in }) {
        Log.verbose("~ Fetching products")
        apiClient.read { result in
            switch result {
            case .success(let productIds):
                
                if let productIds = productIds {
                
                    Log.verbose("~ Fetched \(productIds)")
                    self.localStorage.replace(productIds: Set(productIds), completion: completion)
                }
                
            case .failure(let error):
                Log.error("~ 🚨 \(error)")
                completion(Result.failure(error))
            }
        }
    }
    
    enum WishlistControllerError: Error {
        
        case illegalArgumentError
    }
    
    /// Add a product. Also, track notifications, and setup remote notifications.
    public func add(product: PoqProduct, completion: @escaping (Result<[PoqMessage]>) -> Void = { _ in }) {
        Log.verbose("~ Add product \(product)")
        guard let productId = product.id, let externalProductId = product.externalID else {
            completion(Result.failure(WishlistControllerError.illegalArgumentError))
            return
        }
        self.localStorage.add(productId: productId) { result in
            self.tracker.add(product: product)
            self.setupRemoteNotifications()
            self.apiClient.add(productId: productId, productExternalId: externalProductId) { result in
                completion(result)
            }
        }
    }
    
    /// Remove all favorites. Also, update badge and call the tracker.
    public func remove(completion: @escaping (Result<[PoqMessage]>) -> Void = { _ in }) {
        Log.verbose("~ Remove all favorites")
        localStorage.remove { _ in
            self.apiClient.remove { result in
                self.tracker.removeAll()
                completion(result)
            }
        }
    }
    
    /// Removes a product.
    public func remove(productId: Int, completion: @escaping (Result<[PoqMessage]>) -> Void = { _ in }) {
        Log.verbose("~ Remove productId \(productId)")
        localStorage.remove(productId: productId) { _ in
            self.apiClient.remove(productId: productId) { result in
                self.tracker.remove(productId: productId)
                 completion(result)
            }
        }
    }
    
    /// Return whether this product identifier is stored locally as favorite.
    public func isFavorite(productId: Int) -> Bool {
        Log.verbose("~ productId is favorite? \(localStorage.isFavorite(productId: productId))")
        return localStorage.isFavorite(productId: productId)
    }
}
