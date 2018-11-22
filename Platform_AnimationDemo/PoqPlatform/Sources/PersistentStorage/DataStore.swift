//
//  DataStore.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 08/08/2018.
//

import Foundation

/// This protocol defines the functions that a data provider will have to implement in order to support Poq Apps data layers. This protocol implementes the functions for CRUD entities. An example of a class that conform to this protocol could be providers such as Realm or Core Data.
public protocol DataStore {
    
    /// This function will be in charge of storying an entity given. It should always return in the main thread
    ///
    /// - Parameters:
    ///   - entity: The entity to be stored
    ///   - maxCount: The maximun amount of entities that we want to store in the table
    ///   - completion: The completion block that should always be call in the Main Thread
    /// - Returns: It will return with an error if something went wrong. This should always return in the main thread
    func create<T: Storable>(_ entity: T, maxCount: Int?, completion: ((Error?) -> Void)?)
    
    /// This function will return all entities for a specific type. It should always return in the main thread.
    ///
    /// - Parameter completion: This block will return an array of al entities for the type defined
    /// - Returns: Returns should always be in the main thread
    func getAll<T: Storable>(completion: @escaping ([T]) -> Void)
    
    /// This function will delete all entities for a given type. It should always return in the main thread.
    ///
    /// - Parameters:
    ///   - forObjectType: The given type used for deleting all entities
    ///   - completion: It will return with an error if something went wrong. This should always return in the main thread
    func deleteAll<T: Storable>(forObjectType: T, completion: ((Error?) -> Void)?)
}

/// This protocol defines the design that an entity has to follow for it to able to be stored.
public protocol Storable {
    
    /// This is the type of the object that will be stored in the data base
    associatedtype ManageObjectType
    
    /// This function will generate a new instance of the business object for a given data managed object
    ///
    /// - Parameter storableObject: This is the data managed object
    init(_ storableObject: ManageObjectType)
    
    /// This function will return a new instance of the Data Managed object for a given business object
    ///
    /// - Returns: This is the data managed object that can be stored.
    func storableObject() -> ManageObjectType
}
