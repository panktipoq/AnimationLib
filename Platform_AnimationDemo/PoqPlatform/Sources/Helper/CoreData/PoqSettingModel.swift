//
//  PoqSettingModel.swift
//  Poq.iOS
//
//  Created by Erinç Erol on 30/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import CoreData

@objc(PoqSettingModel)
public class PoqSettingModel: NSManagedObject {

    @NSManaged var appId: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var key: String
    @NSManaged var settingTypeId: NSNumber
    @NSManaged var value: String
    
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, key: String, value: String, id: NSNumber, settingTypeId: NSNumber, appId: NSNumber) -> PoqSettingModel {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "PoqSettingModel", into: moc) as! PoqSettingModel
        newItem.key = key
        newItem.value = value
        newItem.id = id
        newItem.settingTypeId = settingTypeId
        newItem.appId = appId
        
        return newItem
    }

}
