//
//  RealmViewedAppStory.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 16/08/2018.
//

import Foundation
import RealmSwift

public class RealmViewedAppStory: Object {
    
    @objc dynamic var storyId: String = ""
    @objc dynamic var date: Date = Date()
    
    // MARK: - Object overrides
    override public class func primaryKey() -> String? {
        return "storyId"
    }
}

extension ViewedAppStory: Storable {
    public typealias ManageObjectType = RealmViewedAppStory
    
    public func storableObject() -> RealmViewedAppStory {
        let realmViewedAppStory = RealmViewedAppStory()
        realmViewedAppStory.storyId = self.storyId
        realmViewedAppStory.date = self.date
        return realmViewedAppStory
    }
    
    public init(_ storableObject: RealmViewedAppStory) {
        self.storyId = storableObject.storyId
        self.date = storableObject.date
    }
}
