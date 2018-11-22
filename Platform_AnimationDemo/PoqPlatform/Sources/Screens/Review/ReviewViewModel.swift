//
//  ReviewViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 3/10/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/**
 Class to instanciate the reviews View Model to handle the data to be shown.

 ## Usage Example: ##
 To be instanciated from the View Controller.
 ````
 let viewModel = ReviewViewModel(viewControllerDelegate: self)
 ````
 */
public class ReviewViewModel: BaseViewModel {
    
    // MARK: - Variables

    public var reviews:[PoqProductReview]?
    
    // MARK: - Init

    /**
     Init the Review View Model.
     
     - Parameter viewControllerDelegate: View Controller associated to the ViewModel.
     */
    override public init(viewControllerDelegate: PoqBaseViewController) {
        
        self.reviews = []
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // MARK: - Networking

    /**
     Networking call to retrieve the Reviews for the given Product ID
     
     - Parameter productId: The product ID related to the reviews to retrieve from the backend.
     - Parameter isRefresh: true if backend should force the refresh of the cache, false otherwise.
     */
    public func getProductReviews(_ productId: Int, isRefresh: Bool = false) {
        PoqNetworkService(networkTaskDelegate: self).getProductReviews(productId, isRefresh: true)
    }
    
    // MARK: - PoqNetworkTaskDelegate
    
    /**
    Callback before start of the async network task
    */
    override public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if result != nil{
            reviews = result as? [PoqProductReview]
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override public func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}
