//
//  StoresViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/17/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import MapKit
import PoqNetworking
import UIKit

// Used for the sorts below where both sides are optional.. distance < distance, city < city
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

open class StoresViewModel: BaseViewModel {
   
    // ______________________________________________________
    
    // MARK: - Initializers
    public final var stores: [PoqStore] = []
    
    override public init(viewControllerDelegate: PoqBaseViewController) {

        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network tasks
    open func getStores(_ isRefresh: Bool = false) {
        PoqNetworkService(networkTaskDelegate: self).getStores(isRefresh)
    }

    open func getCurentStoreFromId(_ selectedStoreId: Int) -> (selectedStore: PoqStore?, selectedIndex: Int?) {
        
        for (index, store): (Int, PoqStore) in stores.enumerated() {

            if store.id == selectedStoreId {
                return (store, index)
            }
        }
        
        return (nil, nil)
    }
    
    open func setStoresDistance(_ currentLocation: CLLocationCoordinate2D) {
        
        let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)

        for store: PoqStore in stores {

            guard let latitude: NSString = store.latitude as NSString?, let longitude: NSString = store.longitude as NSString? else {
                store.distance = nil
                continue
            }
            
            let lat = latitude.doubleValue
            let long = longitude.doubleValue
            
            let storeLocation = CLLocation(latitude: lat, longitude: long)

            store.distance = storeLocation.distance(from: current)
        }
    }
    
    open func sortByDistance() {
        self.stores.sort(by: { $0.distance < $1.distance })
    }

    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if networkTaskType == PoqNetworkTaskType.stores {

            if let newStores: [PoqStore] = result as? [PoqStore] {

                stores = newStores
                _ = createCityStoresMap()
            }
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
}

// MARL: Support
extension StoresViewModel {
    /**
     Lets prepare data for presentation, we need map [String:[PoqStore]], at the same time, lets create alphabet
     - return: locase alphabet + map stores per city letter
     */
    public final func createCityStoresMap() -> (alphabet: [String], citiesStoresMap: [String: [PoqStore]]) {
        
        var newCityLetterStoresMap: [String: [PoqStore]] = [:]
        var letters: [String] = []
        
        // Sort by city name
        let storesAlphabetically: [PoqStore] = stores.sorted { $0.city < $1.city }
        stores = storesAlphabetically
        
        for store: PoqStore in stores {
            guard let city: String = store.city,
                !city.isNullOrEmpty() else {
                    
                continue
            }
            
            let cityLetter: String = city[0]
            let lowcaseLetter: String = cityLetter.lowercased()
            
            if !letters.contains(cityLetter.lowercased()) {
                letters.append(cityLetter.lowercased())
                newCityLetterStoresMap[lowcaseLetter] = []
            }

            newCityLetterStoresMap[lowcaseLetter]?.append(store)
        }
        
        // alphabetize
        letters.sort(by: { $0 < $1 })

        return (alphabet: letters, citiesStoresMap: newCityLetterStoresMap)
    }
}
