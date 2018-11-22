//
//  LookbookViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 14/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

open class LookbookViewModel: BaseViewModel {
 
    // MARK: - Attributes
    
    open var lookbookImages: [PoqLookbookImage] = []
    
    // MARK: - Basic network tasks
    
    func getLookbookImages(_ lookbookId: Int, isRefresh: Bool = false) {
        
        PoqNetworkService(networkTaskDelegate: self).getLookbookImages(lookbookId, isRefresh: isRefresh)
    }
    
    // MARK: - Basic network task callbacks
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if networkTaskType == PoqNetworkTaskType.lookbookImages {
            if let result = result as? [PoqLookbookImage], !result.isEmpty {
                lookbookImages = result
            }
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}
