//
//  SearchHistoryItem.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/2/17.
//
//

import Foundation

public let maxNumberOfHistoryItems: Int = 5

public enum SearcHistoryItemType: Int {
    case keyword = 0
    case categoryId = 1
}

/// Realm object, which will keep search history
public struct SearchHistoryItem {
    
    /// We need way for identify detached objects
    /// We will use it as Primary Key, it will allow us do not duplicate objects
    public var objectId: String = UUID().uuidString
    
    public var typeRawValue: Int = 0
    
    public var type: SearcHistoryItemType {
        get {
            return SearcHistoryItemType(rawValue: typeRawValue) ?? .keyword
        }
        set(value) {
            typeRawValue = value.rawValue
        }
    }
    
    var date: Date = Date()

    // MARK: - case .keyword
    public var keyword: String?

    // MARK: - case .categoryId
    public var categoryId: Int?
    public var title: String?

    // MARK: - Parent category info
    public var parentCategoryId: Int?
    public var parentCategoryTitle: String? // While saving/retrieving nil may become ""
    
    public init() {}
}
