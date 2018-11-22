//
//  PoqDataStore.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 20/08/2018.
//

import Foundation

/**
 This is the Singleton used all throughout the App for CRUD. This Singleton has a property store that needs to be initialised in the App Delegate because it will be the provider that the App uses to store data.
 The variable `store` has to conform to the protocol `DataStore` which implementes the functions for CRUD entities. An example of a class that conform to the protocol `DataStore` could be Realm or Core Data.
 ## Usage Example: ##
 ````
 PoqDataStore.store = RealmStore()

 ````
 */
public struct PoqDataStore {
    
    /// The shared data store instance.
    public static var store: DataStore?
}
