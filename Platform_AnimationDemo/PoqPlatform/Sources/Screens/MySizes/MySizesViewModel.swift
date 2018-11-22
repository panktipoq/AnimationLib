//
//  MySizesViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

class MySizesViewModel : BaseViewModel {
    
    var mySizes:[PoqMySize] = []
    
    override init(viewControllerDelegate:PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: Network service calls
    
    /**
    Get my sizes
    */
    func getMySizes(_ isRefresh:Bool = false) {
        
        PoqNetworkService(networkTaskDelegate: self).getMySizes(User.getUserId(), isRefresh: isRefresh)
    }
    
    /**
    Set selected sizes
    
    - parameter selectedSizeId: ID of selected size from list
    */
    func setMySize(_ selectedSizeId:String) {
        
        PoqNetworkService(networkTaskDelegate: self).postMySizes(User.getUserId(), mySizes: selectedSizeId)
    }
    
    
    // ______________________________________________________
    
    // MARK: Network delegates
    
    /**
    Callback before start of the async network task
    */
    override func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed successfully
    */
    override func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        super.networkTaskDidComplete(networkTaskType, result: nil)
        
        if networkTaskType == PoqNetworkTaskType.getMySizes {
            
            if let result = result as? [PoqMySize] {
                
                if result.count > 0 {
                    
                    self.mySizes = result
                    
                    // Callback view controller to adjust UI
                    viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
                }
                else {
                    
                    // API couldn't find store stock data
                    viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil)
                }
            }
            else {
                
                // API returned error etc.
                viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil)
            }
        }
        else if networkTaskType == PoqNetworkTaskType.postMySizes {
            
            if let result = result as? [PoqMessage] {
                
                if result.count > 0 {
                    
                    //println(result[0].message)
                    viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
                }
            }
        }
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
}
