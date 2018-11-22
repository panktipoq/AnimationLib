//
//  RealmSearchHistoryItem.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 16/08/2018.
//

import Foundation
import RealmSwift

/// Realm object, which will keep search history
open class RealmSearchHistoryItem: Object {
    
    /// We need way for identify detached objects
    /// We will use it as Primary Key, it will allow us do not duplicate objects
    // TODO: if Realm will be widespread - move it to super class
    @objc dynamic var objectId: String = UUID().uuidString
    
    @objc dynamic var typeRawValue: Int = 0
    
    open var type: SearcHistoryItemType {
        get {
            return SearcHistoryItemType(rawValue: typeRawValue) ?? .keyword
        }
        set(value) {
            typeRawValue = value.rawValue
        }
    }
    
    @objc dynamic var date: Date = Date()
    
    // MARK: - case .keyword
    @objc public dynamic var keyword: String?
    
    // MARK: - case .categoryId
    public var categoryIdNumber = RealmOptional<Int>()
    @objc public dynamic var title: String?
    
    public var categoryId: Int? {
        guard let existedCategoryId = categoryIdNumber.value else {
            return nil
        }
        
        return existedCategoryId
    }
    
    // MARK: - Parent category info
    public var parentCategoryIdNumber = RealmOptional<Int>()
    @objc public dynamic var parentCategoryTitle: String? // While saving/retrieving nil may become ""
    
    public var parentCategoryId: Int? {
        guard let existedParentCategoryId = parentCategoryIdNumber.value else {
            return nil
        }
        
        return existedParentCategoryId
    }
    // MARK: - Object overrides
    override open class func primaryKey() -> String? {
        return "objectId"
    }
}

extension SearchHistoryItem: Storable {
    public typealias ManageObjectType = RealmSearchHistoryItem
    
    public func storableObject() -> RealmSearchHistoryItem {
        let realmSearchHistoryItem = RealmSearchHistoryItem()
        realmSearchHistoryItem.objectId = self.objectId
        realmSearchHistoryItem.typeRawValue = self.typeRawValue
        realmSearchHistoryItem.type = self.type
        realmSearchHistoryItem.date = self.date
        realmSearchHistoryItem.keyword = self.keyword
        realmSearchHistoryItem.title = self.title
        realmSearchHistoryItem.categoryIdNumber = RealmOptional<Int>(self.categoryId)
        realmSearchHistoryItem.parentCategoryIdNumber = RealmOptional<Int>(self.parentCategoryId)
        realmSearchHistoryItem.parentCategoryTitle = self.parentCategoryTitle
        return realmSearchHistoryItem
    }
    
    public init(_ storableObject: RealmSearchHistoryItem) {
        self.objectId = storableObject.objectId
        self.typeRawValue = storableObject.typeRawValue
        self.date = storableObject.date
        self.keyword = storableObject.keyword
        self.title = storableObject.title
        self.parentCategoryTitle = storableObject.parentCategoryTitle
        self.categoryId = storableObject.categoryId
        self.parentCategoryId = storableObject.parentCategoryId
    }
}
