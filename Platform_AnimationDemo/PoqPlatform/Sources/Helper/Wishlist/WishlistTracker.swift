import PoqNetworking
import PoqAnalytics

struct WishlistTracker {
    
    public func add(product: PoqProduct) {
        var params = [String: String]()
        params["Id"] = product.id.flatMap { return String(describing: $0) } ?? ""
        params["Title"] = product.title
        if let specialPrice = product.specialPrice {
            params["Price"] = specialPrice.toPriceString()
        } else if let price = product.price {
            params["Price"] = price.toPriceString()
        }
        PoqTrackerHelper.trackUserAddToWishList(params)
        PoqTrackerV2.shared.addToWishlist(quantity: 1, productTitle: product.title ?? "", productId: product.id ?? 0, productPrice: product.specialPrice ?? product.price ?? 0, currency: CurrencyProvider.shared.currency.code)
    }
    
    public func remove(productId: Int) {
        var params = [String: String]()
        params["productId"] = String(productId)
        PoqTrackerHelper.trackRemoveFromWishList(params)
        PoqTrackerV2.shared.removeFromWishlist(productId: productId)
    }
    
    public func removeAll() {
        PoqTrackerHelper.trackRemoveFromWishList()
    }
}
