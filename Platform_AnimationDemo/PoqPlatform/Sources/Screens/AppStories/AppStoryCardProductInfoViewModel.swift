//
//  AppStoryCardProductInfoViewModel.swift
//  PoqPlatform
//
//  Created by Balaji Reddy on 31/01/2018.
//

import Foundation
import ObjectMapper
import PoqNetworking
import PoqUtilities

open class AppStoryCardProductInfoViewModel: PoqNetworkTaskDelegate {
    
    public weak var presenter: PoqPresenter?
    public let productId: PoqProductID
    public fileprivate(set) var product: PoqProduct?
    
    public init(with productId: PoqProductID) {
        self.productId = productId
    }
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        guard let responseProducts = result as? [PoqProduct], responseProducts.count == 1 else {
            Log.error("Error fetching product details.")
            return
        }
        
        product = responseProducts[0]
        
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
    open func fetchProductInfo() {
        
        PoqNetworkService(networkTaskDelegate: self).getProductDetails(User.getUserId(), productId: productId.internalProductId, externalId: productId.externalProductId)
        
    }
}
