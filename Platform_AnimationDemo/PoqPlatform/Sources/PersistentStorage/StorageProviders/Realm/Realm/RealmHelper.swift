//
//  RealmHelper.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 06/08/2018.
//

import Foundation
import RealmSwift

public struct RealmHelper {
    static let configuration = Realm.Configuration(
        schemaVersion: 2,
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                // Bear in mind that SearcHistoryItem has a type where it is missing an 'h' but since Realm table was created with it in the future we should keep as it is.
                migration.enumerateObjects(ofType: "SearcHistoryItem", { (oldObject, _) in
                    if let oldObject = oldObject {
                        migration.create("RealmSearchHistoryItem", value: oldObject)
                    }
                })
                
                migration.enumerateObjects(ofType: "ViewedAppStory", { (oldObject, _) in
                    if let oldObject = oldObject {
                        migration.create("RealmViewedAppStory", value: oldObject)
                    }
                })
                
                migration.enumerateObjects(ofType: "RecentlyViewedProduct", { (oldObject, _) in
                    if let oldObject = oldObject {
                        migration.create("RealmRecentlyViewedProduct", value: oldObject)
                    }
                })
            }
    }, objectTypes: [RealmSearchHistoryItem.self, RealmViewedAppStory.self, RealmRecentlyViewedProduct.self, RealmWishlistProducts.self, IntObject.self])
}
