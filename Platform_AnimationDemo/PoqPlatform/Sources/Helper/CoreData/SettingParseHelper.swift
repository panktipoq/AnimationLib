//
//  SettingParseHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 01/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import CoreData
import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities

public class SettingParseHelper {
    
    public static func parseSettingsFromExistedDB(_ context: NSManagedObjectContext?) {
        
        let existedContext: NSManagedObjectContext = {
            guard let passedContext: NSManagedObjectContext = context else {
                
                let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                managedObjectContext.persistentStoreCoordinator = CoreDataHelper.shared.persistentStoreCoordinator
                return managedObjectContext
            }
            
            return passedContext
        }()
        
        for settingType: PoqSettingsType in PoqSettingsType.allSettingTypes {
            
            let configs: [PoqSetting] = SettingsCoreDataHelper.fetchSettingsByType(existedContext, settingType: settingType)
            PoqPlatform.shared.modules.forEach({ $0.apply(settings: [settingType: configs]) })
        }
        
    }
    
    public static func updateAppSettingsWithSplashObject(_ splash: PoqSplash) {
        
        let privateMOC: NSManagedObjectContext? = {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = CoreDataHelper.shared.persistentStoreCoordinator
            return context
        }()
        
        let typeResponseMap: [PoqSettingsType: [PoqSetting]] = PoqSettingsType.typeResponseMapFromSplash(splash)
        for (settingType, settingsArray): (PoqSettingsType, [PoqSetting]) in typeResponseMap {
            
            PoqPlatform.shared.modules.forEach({ $0.apply(settings: [settingType: settingsArray]) })
            
            if let moc: NSManagedObjectContext = privateMOC {
                moc.perform({
                    () -> Void in
                    SettingsCoreDataHelper.upsertSettings(moc, resultsArr: settingsArray, settingType: settingType)
                    
                    do {
                        try moc.save()
                    } catch {
                        Log.error("unknow error during save")
                    }

                })
            }
        }
    }

}
