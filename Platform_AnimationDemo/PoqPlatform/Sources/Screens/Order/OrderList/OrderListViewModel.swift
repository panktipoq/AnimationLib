//
//  OrderListViewModel.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/**
 Class to instanciate the orders list View Model to handle the data to be shown.
 
 ## Usage Example: ##
 To be instanciated from the View Controller.
 ````
 let viewModel = OrderListViewModel(viewControllerDelegate: self)
 ````
 */
open class OrderListViewModel: BaseViewModel {
    
    // MARK: - Variables

    public typealias OrderType = PoqOrder<PoqOrderItem> 
    
    open var orderListItems: [OrderType]
    
    // MARK: - Init

    public override init(viewControllerDelegate: PoqBaseViewController) {
        
        orderListItems = []
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // MARK: - Orders

    /**
     Checks the number of Orders stored in the View Model.
     
     - returns: the number of Orders stored in the View Model.
     */
    func getItemsCount() -> Int {
        return orderListItems.count
    }
    
    // MARK: - Networking
    
    /**
     Networking call to retrieve the orders history.
     
     - Parameter isRefresh: true if backend should force the refresh of the cache, false otherwise.
     */
    open func getorderList(_ isRefresh: Bool = false) {
        let service = PoqNetworkService(networkTaskDelegate: self)
        let _: PoqNetworkTask<JSONResponseParser<OrderType>> = service.getOrders(isRefresh)
        //.getorderList(User.getUserId(), storeId: String(StoreHelper.getFavorite()),  isRefresh:isRefresh)
    }
    
    // MARK: - PoqNetworkTaskDelegate

    /**
    Callback before start of the async network task
    */
    override open func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override open func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        super.networkTaskDidComplete(networkTaskType,result:[])
        
        if result != nil {
            
            if networkTaskType == PoqNetworkTaskType.getOrderList {
                
                if !result!.isEmpty {
                    
                    orderListItems = result! as! [PoqOrder]
                    
                    //Handling DW connecting error
                    if orderListItems.count == 1 {
                        if let order = orderListItems[0] as PoqOrder? {
                            
                            if order.statusCode == 500 {
                                orderListItems = []
                            }
                        }
                    }
                }
                else {
                    orderListItems = []
                }
            }
        }
               
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
   
}
