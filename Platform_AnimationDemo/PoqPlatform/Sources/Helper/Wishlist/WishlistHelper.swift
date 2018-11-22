import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics

open class WishlistHelper: PoqNetworkTaskDelegate {
    
    public static let sharedInstance = WishlistHelper()
    
    @available(iOS, deprecated: 9.0, message:" Replace with WishlistController.shared.replaceWithRemote()")
    public func updateWishlistedProductIds( _ isRefresh: Bool = false ) {
        WishlistController.shared.fetchProductIds()
    }
    
    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shared.add(product: product)")
    public func add(_ product: PoqProduct) {
        WishlistController.shared.add(product: product)
    }
    
    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shared.remove(productId: productId)")
    public func remove(_ productId: Int) {
        WishlistController.shared.remove(productId: productId)
    }
    
    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shared.remove(productId: productId){}")
    public func remove(_ productId: Int, networkTaskDelegate: PoqNetworkTaskDelegate) {
        WishlistController.shared.remove(productId: productId) { _ in
            networkTaskDelegate.networkTaskDidComplete(PoqNetworkTaskType.deleteWishList, result: [])
        }
    }

    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shardInstance.remove()")
    public func removeAll(_ networkTaskDelegate: PoqNetworkTaskDelegate) {
        WishlistController.shared.remove()
    }
    
    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shared.isFavorite(productId: productId)")
    public func isProductWhishlisted(_ product: PoqProduct) -> Bool {
        return product.id.flatMap { WishlistController.shared.isFavorite(productId: $0) } ?? false
    }
    
    @available(iOS, deprecated: 9.0, message: "Replace with WishlistController.shared.isFavorite(productId: productId)")
    public func isProductWhishlisted(_ productId: Int) -> Bool {
        return WishlistController.shared.isFavorite(productId: productId)
    }
    
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}
    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {}
    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {}
}
