//
//  AppStoryProductInfoService.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/18/17.
//
//

import Foundation
import PoqNetworking

open class AppStoryProductInfoService: PoqNetworkTaskDelegate {
    
    weak open var presenter: PoqPresenter?
    
    public init() {
    }
    
    public func addToBag(selectedSize productSizeId: Int?, forProduct product: PoqProduct?) {
        
        guard let selectedSizeId = productSizeId, let product = product else {
            assertionFailure("Cannot add to bag without a valid productSizeID and Product")
            return
        }
        
        BagHelper.addToBag(delegate: self, selectedSizeId: selectedSizeId, in: product)

    }
    
    // MARK: PoqNetworkTaskDelegate
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presenter?.update(state: .loading, networkTaskType: networkTaskType, withNetworkError: nil)
    }
    
    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        presenter?.update(state: .completed, networkTaskType: networkTaskType, withNetworkError: nil)
        
        BagHelper.completedAddToBag()
        BagHelper.incrementBagBy(1)
    }

    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
}
