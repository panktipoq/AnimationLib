import Foundation
import PoqNetworking
import PoqUtilities

class WishlistApiClient: GenericNetworkTaskDelegatable {
    

    private var userId: String {
        return User.getUserId()
    }
    internal var delegates = [UUID: AnyObject]()
    
    init(userId: String) {
        /*
         self.userId = userId
         
         Unfortunately, we are resetting the user id from the PoqNetworking layer when we logout,
         and given that the parent of this class is used as a singleton everywhere, I replaced this
         variable with a calculated one.
        */
    }
    
    func read(completion: @escaping ((Result<[Int]>) -> Void)) {
        let delegate: GenericNetworkTaskDelegate<[Int]> = createDelegate(completion: completion)
        PoqNetworkService(networkTaskDelegate: delegate).getWishListProductIds(userId, isRefresh: false)
    }
    
    func remove(completion: @escaping ((Result<[PoqMessage]>) -> Void)) {
        let delegate: GenericNetworkTaskDelegate<[PoqMessage]> = createDelegate(completion: completion)
        PoqNetworkService(networkTaskDelegate: delegate).clearAllWishList(userId)
    }
    
    func remove(productId: Int, completion: @escaping ((Result<[PoqMessage]>) -> Void)) {
        let delegate: GenericNetworkTaskDelegate<[PoqMessage]> = createDelegate(completion: completion)
        PoqNetworkService(networkTaskDelegate: delegate).deleteWishList(userId, productId: productId)
    }
    
    func add(productId: Int, productExternalId: String, completion: @escaping ((Result<[PoqMessage]>) -> Void)) {
        let delegate: GenericNetworkTaskDelegate<[PoqMessage]> = createDelegate(completion: completion)
        PoqNetworkService(networkTaskDelegate: delegate).postWishList(userId, productId: productId, externalId: productExternalId)
    }
}
