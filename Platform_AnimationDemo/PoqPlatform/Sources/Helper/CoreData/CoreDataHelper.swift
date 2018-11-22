//
//  CoreDataHelper.swift
//  PoqPlatform
//
//  Created by Joshua White on 23/05/2018.
//

import CoreData
import Foundation
import PoqUtilities

/// Core data stack manager responsible for sharing access to the platform's core data store.
class CoreDataHelper {
    
    /// Single instance of the core data helper.
    static let shared = CoreDataHelper()
    
    /// The directory the application uses to store the Core Data store file.
    /// This code uses a directory named "poq.iOS" in the application's documents Application Support directory.
    lazy var applicationDocumentsDirectory: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }()
    
    /// The managed object model for the application. This property is not optional.
    /// It is a fatal error for the application not to be able to find and load its model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: CoreDataHelper.self).url(forResource: "Poq.iOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// The persistent store coordinator for the application.
    /// This implementation creates and return a coordinator, having added the store for the application to it.
    /// This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let url = self.applicationDocumentsDirectory?.appendingPathComponent("Poq.iOS.sqlite") else {
            Log.error("Unable to locate application's documents directory.")
            return nil
        }
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options: [AnyHashable: Any] = [
                NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true),
                NSInferMappingModelAutomaticallyOption: NSNumber(value: true)
            ]
            
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error as NSError {
            // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html#//apple_ref/doc/uid/TP40004399-CH4-SW1
            Log.error("Aborting app because of CoreData: \(error)")
            coordinator = nil
            
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    private init() {
    }
    
}
