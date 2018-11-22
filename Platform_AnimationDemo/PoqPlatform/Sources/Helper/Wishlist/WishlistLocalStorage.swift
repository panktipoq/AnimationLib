import Foundation
import PoqUtilities
import PoqNetworking

// Results are undefined when two operations are called concurrently.
class WishlistLocalStorage {
    
    private var changeObservers = [UUID: (Set<Int>) -> Void]()
    private let store: DataStore
    
    init(store: DataStore) {
        self.store = store
        self.warmCache()
    }
    
    private func warmCache() {
        read { (identifiers) in
            Log.verbose("~ Cache initialised. Favorites are: \(identifiers)")
        }
    }
    
    // This exists so we can query synchronously whether a product is a favorite.
    private var favoritesCache = Set<Int>() {
        didSet {
            Log.verbose("~ favoritesCache changed to \(favoritesCache)")
            changeObservers.values.forEach { changeObserver in
                changeObserver(favoritesCache)
            }
        }
    }
    
    func addChangeObserver<T: AnyObject>(_ observer: T, closure: @escaping ((T, Set<Int>) -> Void)) {
        let id = UUID()
        changeObservers[id] = { [weak self, weak observer] favorites in
            // Remove the closure if the observer was deallocated
            guard let observer = observer else {
                self?.changeObservers.removeValue(forKey: id)
                return
            }
            closure(observer, favorites)
        }
    }
    
    func isFavorite(productId: Int) -> Bool {
        Log.verbose("~ \(productId) is \(favoritesCache.contains(productId) ? "a" : "not a") favorite")
        return favoritesCache.contains(productId)
    }
    
    func favoritesCount() -> Int {
        Log.verbose("~ favoritesCount is \(favoritesCache.count)")
        return favoritesCache.count
    }
    
    func add(productId: Int, completion: @escaping (Result<Void>) -> Void) {
        Log.verbose("~ Add \(productId)")
        read { (identifiers) in
            var productIds = identifiers
            productIds.insert(productId)
            self.replace(productIds: productIds, completion: { result in
                completion(result)
            })
        }
    }
    
    /// Remove the given product identifier.
    func remove(productId: Int, completion: @escaping (Result<Void>) -> Void) {
        Log.verbose("~ Remove \(productId)")
        read { (identifiers) in
            var productIds = identifiers
            productIds.remove(productId)
            self.replace(productIds: productIds, completion: { result in
                completion(result)
            })
        }
    }
    
    /// This will replace the set of favorites with the given product identifiers.
    func replace(productIds: Set<Int>, completion: @escaping (Result<Void>) -> Void) {
        store.create(WishlistProducts(productIdSet: productIds), maxCount: 1, completion: { error in
            self.favoritesCache = productIds
            if let error = error {
                Log.error("~ 🚨 Error: \(error)")
                completion(Result.failure(error))
            } else {
                Log.verbose("~ Created: \(productIds)")
                completion(Result.success(()))
            }
        })
    }
    
    /// Return all the favorites.
    func read(completion: @escaping (Set<Int>) -> Void) {
        store.getAll(completion: { (favorites: [WishlistProducts]) in
            let productIds = favorites.first?.productIdSet ?? Set<Int>()
            Log.verbose("~ Read: \(productIds)")
            self.favoritesCache = productIds
            completion(productIds)
        })
    }
    
    /// Remove all the favorites.
    func remove(completion: @escaping (Result<Void>) -> Void) {
        store.deleteAll(forObjectType: WishlistProducts(), completion: { (error) in
            if let error = error {
                Log.error("~ 🚨 Error: \(error.localizedDescription)")
                completion(Result.failure(error))
            } else {
                self.favoritesCache = Set<Int>()
                Log.verbose("~ Removed all products")
                completion(Result.success(()))
            }
        })
    }
}
