import Foundation
import RealmSwift

public struct WishlistProducts: Hashable {
    
    var productIdSet = Set<Int>()
    
    public init() {}
    
    public init(productIdSet: Set<Int>) {
        self.productIdSet = productIdSet
    }
    
    public var hashValue: Int { return productIdSet.hashValue }
}
