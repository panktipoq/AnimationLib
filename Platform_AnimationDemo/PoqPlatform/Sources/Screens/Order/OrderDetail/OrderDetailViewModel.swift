//
//  OrderDetailViewModel.swift
//  Poq.iOS
//
//  Created by Jun Seki on 16/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class OrderDetailViewModel: BaseViewModel {

    // MARK: - Variables

    /// Order type.
    public typealias OrderType = PoqOrder<PoqOrderItem>

    /// Order retrieved from the backend.
    open var order: OrderType?

    // MARK: - Init

    override init(viewControllerDelegate: PoqBaseViewController) {

        super.init(viewControllerDelegate: viewControllerDelegate)
    }

    // MARK: - Networking

    /**
     Networking call to retrieve the order details.
     
     - Parameter orderKey: Order Key as ID of to the order.
     - Parameter isRefresh: true if backend should force the refresh of the cache, false otherwise.
     */
    func getOrderDetails(_ orderKey: String, isRefresh: Bool = false) {
        let service = PoqNetworkService(networkTaskDelegate: self)
        let _: PoqNetworkTask<JSONResponseParser<OrderType>> = service.getOrderSummary(orderKey, isRefresh: isRefresh)
    }

    // Not used
    func getProductsCount() -> Int {
        if let poqOrder = order,
            let orderItems = poqOrder.orderItems {

            return orderItems.count
        }
        return 0
    }

    // MARK: - PoqNetworkTaskDelegate

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

        if let result = result,
            networkTaskType == PoqNetworkTaskType.getOrderSummary,
            result.count > 0,
            let resultOrder = result as? [OrderType] {

            order = (resultOrder)[0]
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
