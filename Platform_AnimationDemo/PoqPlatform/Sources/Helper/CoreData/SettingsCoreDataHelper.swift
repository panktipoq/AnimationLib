//
//  PoqSettingsCoreDataHelper.swift
//  Poq.iOS
//
//  Created by Erinç Erol on 30/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import CoreData
import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

public class SettingsCoreDataHelper {
    
    /**
     Update or insert value to context
     - parameter context: COreDataContext
     - parameter resultsArr: new values
     - parameter settingType: type of settings
     - prameter appId: identifier of app, might be usfull for multicountry apps
     */
    public static func upsertSettings(_ context: NSManagedObjectContext, resultsArr: [PoqSetting], settingType: PoqSettingsType, appId: String = PoqNetworkTaskConfig.appId) {
        
        let existingSettings = fetchAllSettings(context, settingType: settingType, appId: appId)
        
        for result in resultsArr {
            guard let key = result.key, let value = result.value, let id = result.id, let appId = result.appId, let settingTypeId = result.settingTypeId else {
                Log.error("We got wrong PoqSetting object = \(result)")
                continue
            }
            
            var setting = existingSettings.filter({ $0.key == key }).first
            
            if setting == nil {
                setting = PoqSettingModel.createInManagedObjectContext(context, key: key, value: value,
                                                                       id: NSNumber(value: id),
                                                                       settingTypeId: NSNumber(value: settingTypeId),
                                                                       appId: NSNumber(value: appId))
            } else if setting?.value != value {
                setting?.value = value
            }
        }
    }
    
    public static func fetchAllSettings (_ context: NSManagedObjectContext, settingType: PoqSettingsType, appId: String = PoqNetworkTaskConfig.appId) -> [PoqSettingModel] {
        
        let intAppId: Int = Int(appId) ?? 3
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PoqSettingModel")
        
        let predicate = NSPredicate(format: "settingTypeId == %d AND appId == %d", settingType.rawValue, intAppId)
        
        fetchRequest.predicate = predicate
        
        if let fetchResults = (try? context.fetch(fetchRequest)) as? [PoqSettingModel] {
            return fetchResults
        } else {
            return []
        }
    }
    
    public static func fetchSettingsByType (_ context: NSManagedObjectContext, settingType: PoqSettingsType, appId: String = PoqNetworkTaskConfig.appId) -> [PoqSetting] {
        
        let intAppId: Int = Int(appId) ?? 3
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PoqSettingModel")
        
        let predicate = NSPredicate(format: "settingTypeId == %d AND appId == %d", settingType.rawValue, intAppId)
        
        fetchRequest.predicate = predicate
        
        if let fetchResults = (try? context.fetch(fetchRequest)) as? [PoqSettingModel] {
            
            var result: [PoqSetting] = []
            
            if !fetchResults.isEmpty {
                
                for fetchResult in fetchResults {
                    
                    var poqSetting = PoqSetting()
                    poqSetting.id = fetchResult.id as? Int
                    poqSetting.key = fetchResult.key
                    poqSetting.value = fetchResult.value
                    poqSetting.settingTypeId = fetchResult.settingTypeId as? Int
                    poqSetting.appId = fetchResult.appId as? Int
                    result.append(poqSetting)
                }
            }
            
            return result
        } else {
            
            return []
        }
    }
    
    // simplify this func, let them pass nil to avoid ourside creation of context
    public static func fetchSetting(_ context: NSManagedObjectContext?, key: String, settingTypeId: Int, appId: String = PoqNetworkTaskConfig.appId) -> PoqSetting? {
        
        let existedContext: NSManagedObjectContext
        if let passedContext: NSManagedObjectContext = context {
            existedContext = passedContext
        } else {

            existedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            existedContext.persistentStoreCoordinator = CoreDataHelper.shared.persistentStoreCoordinator
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PoqSettingModel")
        
        let intAppId: Int = Int(appId) ?? 3
        
        let predicate = NSPredicate(format: "settingTypeId == %d AND appId == %d AND key == %@", settingTypeId, intAppId, key)
        
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        var fetchResults: [AnyObject] = []
        
        do {
            fetchResults = try existedContext.fetch(fetchRequest)
            if let fetchedSettings: [PoqSettingModel] = fetchResults as? [PoqSettingModel] {
                if let existingSetting: PoqSettingModel = fetchedSettings.first {
                    
                    var poqSetting = PoqSetting()
                    poqSetting.id = existingSetting.id as? Int
                    poqSetting.key = existingSetting.key
                    poqSetting.value = existingSetting.value
                    poqSetting.settingTypeId = existingSetting.settingTypeId as? Int
                    poqSetting.appId = existingSetting.appId as? Int
                    return poqSetting
                }
            }

        } catch let error as NSError {
            Log.error("during execution fetch, error = \(error)")
        } catch {
            Log.error("during execution fetch, have no idea what is wrong")
        }
        return nil
    
    }
}
