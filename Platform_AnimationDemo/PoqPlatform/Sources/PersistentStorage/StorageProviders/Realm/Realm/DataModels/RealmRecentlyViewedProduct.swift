//
//  RealmRecentlyViewedProduct.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 16/08/2018.
//

import Foundation
import RealmSwift

public class RealmRecentlyViewedProduct: Object {
    
    @objc public dynamic var productId: Int = 0
    @objc public dynamic var date: Date = Date()
    
    // MARK: Object overrides
    override public class func primaryKey() -> String? {
        return "productId"
    }
}

extension RecentlyViewedProduct: Storable {
    public typealias ManageObjectType = RealmRecentlyViewedProduct

    public func storableObject() -> RealmRecentlyViewedProduct {
        let realmRecentlyViewedProduct = RealmRecentlyViewedProduct()
        realmRecentlyViewedProduct.productId = self.productId
        realmRecentlyViewedProduct.date = self.date
        return realmRecentlyViewedProduct
    }
    
    public init(_ storableObject: RealmRecentlyViewedProduct) {
        self.productId = storableObject.productId
        self.date = storableObject.date
    }
}
