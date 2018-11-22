//
//  MyProfileStoreViewModelCell.swift
//  Poq.iOS.Belk
//
//  Created by Manuel Marcos Regalado on 11/12/2016.
//
//

import Foundation
import PoqNetworking

/// Store cell's view model used to render a preview of the user's favorite cell
open class MyProfileStoreCellViewModel: FavouriteStoreBlockProtocol, PoqNetworkTaskDelegate {
    
    /// The delegate to which cell actions are sent
    weak var myProfileStoreViewCellDelegate: MyProfileStoreViewCell?
    
    /// The id of the user's favorite store
    var storeId: Int = StoreHelper.getFavoriteStoreId()
    
    /// The store object. Upon setting the store information is updated on the cell
    var store: PoqStore? {
        didSet {
            updateStoreDetails()
        }
    }    
    
    /// Initializes the cell with the required delegate
    ///
    /// - Parameter myProfileStoreViewCellDelegate: The cell's delegate
    public init(myProfileStoreViewCellDelegate: MyProfileStoreViewCell) {        
        self.myProfileStoreViewCellDelegate = myProfileStoreViewCellDelegate
        updateStoreDetails()
    }
    
    /// Returns the store's details
    ///
    /// - Returns: The store object that will be returned
    open func getStoreDetails() -> PoqStore? {
        if storeId != StoreHelper.getFavoriteStoreId() {
            updateStoreDetails()
            return nil
        }
        return store
    }

    /// Checks if the store object is present
    ///
    /// - Returns: Wether or not the cell has an assigned store
    open func isValidStore() -> Bool {
        if store != nil {
            return true
        }
        return false
    }
    
    /// Updates the store's details
    open func updateStoreDetails() {
        guard let profileCellDelegate = myProfileStoreViewCellDelegate else {
            return
        }
        
        if ((storeId != 0) || (StoreHelper.getFavoriteStoreId() != 0)) {
            if store != nil {
                // Check if there is a new favourite
                if storeId == StoreHelper.getFavoriteStoreId() {
                    profileCellDelegate.showDetails()
                } else {
                    // Set the new value
                    storeId = StoreHelper.getFavoriteStoreId()
                    reloadDetails()
                }
            } else {
                reloadDetails()
            }
        }
    }
    
    /// Reloads the store's details. TODO: I suggest grouping the update and the reload into a single method as it replicates a lot of functionality
    func reloadDetails() {
        if let profileCellDelegate = myProfileStoreViewCellDelegate {
            if storeId == 0 && StoreHelper.getFavoriteStoreId() == 0 {
                profileCellDelegate.toggleView(false)
                if let _ = store {
                    store = nil
                }
            }
            else {
                profileCellDelegate.toggleView(true)
                profileCellDelegate.spinnerView?.startAnimating()
                if storeId == 0 {
                    storeId = StoreHelper.getFavoriteStoreId()
                }
                getStoreDetails(storeId)
            }
        }
    }
    
    /// Returns the store details via a request
    ///
    /// - Parameter storeID: The id of the store that is to be returned from backend
    open func getStoreDetails(_ storeID: Int) {
        PoqNetworkService(networkTaskDelegate: self).getStoreDetail(storeID)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /// Called when a network task type starts
    ///
    /// - Parameter networkTaskType: The type of the network task that started
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
    }
    
    /// Called when a network request is completed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that completed
    ///   - result: The result of the network request completion
    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        guard let networkResults = result as? [PoqStore], networkResults.count > 0 else {
            return
        }
        store = networkResults[0]
    }
    
    /// Called when a network request failed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed
    ///   - error: The acompanying error of the request failure
    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
    }
}
