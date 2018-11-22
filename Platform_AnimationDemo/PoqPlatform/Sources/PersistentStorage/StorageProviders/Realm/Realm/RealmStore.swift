//
//  RealmStore.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 16/08/2018.
//

import Foundation
import RealmSwift
import PoqUtilities

enum RealmStoreError: Error {
    case unexpectedManagedObject
}

open class RealmStore: DataStore {
    
    fileprivate let workingQueue = DispatchQueue(label: "RealmStore.WorkingQueue")
    public static let shared = RealmStore()
    
    public init() {}

    public func create<T: Storable>(_ entity: T, maxCount: Int?, completion: ((Error?) -> Void)?) {
        workingQueue.async {
            autoreleasepool {
                // Store the completion block into a constant so we don't have to write the same lines few times in this function
                let completionHandler: (Error?) -> Void = { (error) in
                    if let completionBlock = completion {
                        DispatchQueue.main.async {
                            completionBlock(error)
                        }
                    }
                }
                // Map the value type to the reference type
                guard let manageObject = entity.storableObject() as? Object else {
                    completionHandler(RealmStoreError.unexpectedManagedObject)
                    assertionFailure("A Realm managed object was expected")
                    return
                }
                var returnError: Error?
                do {
                    let realm = try Realm(configuration: RealmHelper.configuration)
                    try realm.write({
                        realm.add(manageObject, update: true)
                    })
                    // After adding the object we need to check how many objects we have already stored because we have a maximum number of
                    // Objects that we can show. The constant maxNumberOfHistoryItems will tell us how many.
                    // Therefore, we will do the following:
                    // 1.- Check that we have been given a maxCount of objects
                    // 2.- Fetch all objects,
                    // 3.- if we've reached the limit, slice the array and remove the extra ones
                    if let maxCountItems = maxCount {
                        guard let type = T.ManageObjectType.self as? Object.Type else {
                            completionHandler(RealmStoreError.unexpectedManagedObject)
                            assertionFailure("A Realm managed object was expected")
                            return
                        }
                        let fetchResults = realm.objects(type).sorted(byKeyPath: "date", ascending: false)
                        // Count we have more than the max limit, we should remove the spare ones
                        if fetchResults.count > maxCountItems && maxCountItems > 0 {
                            let removeItems = Array(fetchResults.suffix(from: maxCountItems))
                            try realm.write {
                                realm.delete(removeItems)
                            }
                        }
                    }
                } catch Realm.Error.fileAccess {
                    Log.error("Exception while accessing Realm file. We will delete database to prevent problems and allow Realm init.")
                    self.deleteRealmDatabase()
                } catch let error {
                    returnError = error
                    Log.error("We caught exception while saving to realm: \(error)")
                }
                completionHandler(returnError)
            }
        }
    }
    
    public func getAll<T: Storable>(completion: @escaping ([T]) -> Void) {
        workingQueue.async {
            var detachedResults = [T]()
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: RealmHelper.configuration)
                    
                    guard let type = T.ManageObjectType.self as? Object.Type else {
                        DispatchQueue.main.async {
                            completion(detachedResults)
                        }
                        assertionFailure("A Realm managed object was expected")
                        return
                    }
                    
                    let fetchResults =  realm.objects(type).sorted(byKeyPath: "date", ascending: false)
                    for index in 0..<fetchResults.count {
                        guard let managedObject = fetchResults[index] as? T.ManageObjectType else {
                            DispatchQueue.main.async {
                                completion(detachedResults)
                            }
                            assertionFailure("A Realm managed object was expected")
                            return
                        }
                        let detached = T.init(managedObject)
                        detachedResults.append(detached)
                    }
                } catch Realm.Error.fileAccess {
                    Log.error("Exception while accessing Realm file. We will delete database to prevent problems and allow Realm init.")
                    self.deleteRealmDatabase()
                } catch {
                    Log.error("We caught exception while saving to realm")
                }
                DispatchQueue.main.async {
                    completion(detachedResults)
                }
            }
        }
    }
    
    public func deleteAll<T: Storable>(forObjectType: T, completion: ((Error?) -> Void)?) {
        workingQueue.async {
            autoreleasepool {
                // Store the completion block into a constant so we don't have to write the same lines few times in this function
                let completionHandler: (Error?) -> Void = { (error) in
                    if let completionBlock = completion {
                        DispatchQueue.main.async {
                            completionBlock(error)
                        }
                    }
                }
                var returnError: Error?
                do {
                    guard let type = T.ManageObjectType.self as? Object.Type else {
                        completionHandler(RealmStoreError.unexpectedManagedObject)
                        assertionFailure("A Realm managed object was expected")
                        return
                    }
                    let realm = try Realm(configuration: RealmHelper.configuration)
                    let results = realm.objects(type)
                    try realm.write({
                        realm.delete(results)
                    })
                } catch Realm.Error.fileAccess {
                    Log.error("Exception while accessing Realm file. We will delete database to prevent problems and allow Realm init.")
                    self.deleteRealmDatabase()
                } catch let error {
                    returnError = error
                    Log.error("We catch exception while deleting from realm: \(error)")
                }
                completionHandler(returnError)
            }
        }
    }
    
    private func deleteRealmDatabase() {
        guard let fileURL = Realm.Configuration.defaultConfiguration.fileURL else {
            Log.error("It was impossible to delete Realm Database")
            return
        }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            Log.error("It was impossible to delete Realm Database")
        }
    }
}
