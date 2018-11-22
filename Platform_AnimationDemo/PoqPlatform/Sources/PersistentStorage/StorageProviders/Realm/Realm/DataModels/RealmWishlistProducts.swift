import Foundation
import RealmSwift

class IntObject: Object {
    @objc dynamic var identifier = 0
    
    convenience init(identifier: Int) {
        self.init()
        self.identifier = identifier
    }
}

public class RealmWishlistProducts: Object {
    
    @objc dynamic var primaryKey = UUID().uuidString
    var productIdList = List<IntObject>()
    @objc dynamic var date = Date()
    
    // MARK: - Object overrides
    override public class func primaryKey() -> String? {
        return "primaryKey"
    }
}

extension WishlistProducts: Storable {
    
    public typealias ManageObjectType = RealmWishlistProducts
    
    public func storableObject() -> RealmWishlistProducts {
        let object =  RealmWishlistProducts()
        productIdSet.forEach { (productId: Int) in
            object.productIdList.append(IntObject(identifier: productId))
        }
        return object
    }
    
    public init(_ storableObject: ManageObjectType) {
        self.productIdSet = Set(storableObject.productIdList.map { $0.identifier })
    }
}
