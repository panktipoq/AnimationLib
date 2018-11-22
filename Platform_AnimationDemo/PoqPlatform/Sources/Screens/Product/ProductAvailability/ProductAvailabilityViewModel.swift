//
//  ProductAvailabilityViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 02/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

class ProductAvailabilityViewModel : BaseViewModel {
    
    var storeStock:PoqStoreStock?
    var product:PoqProduct?
    
    override init(viewControllerDelegate:PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    func getStoreStock(_ storeId:Int, sizeId:Int){
        
        PoqNetworkService(networkTaskDelegate: self).getStoreStock(self.product!.id!, productSizeId: sizeId, lat: 0, lng: 0, storeId: storeId, poqUserId: User.getUserId(), isRefresh: false)
    }
    
    // MARK: - Basic network task callbacks
    
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
        
        if networkTaskType == PoqNetworkTaskType.storeStock {
            
            if let result = result as? [PoqStoreStock] {
                
                if result.count > 0 {
                    
                    self.storeStock = result[0]
                    
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
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: nil)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

}
