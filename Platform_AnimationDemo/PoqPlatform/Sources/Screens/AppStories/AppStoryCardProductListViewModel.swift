//
//  AppStoryProductListViewModel.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/12/17.
//
//

import Foundation
import ObjectMapper
import PoqNetworking
import PoqUtilities

public class AppStoryCardProductListViewModel: PoqNetworkTaskDelegate {
    
    public weak var presenter: PoqPresenter?
    
    public let storyCard: PoqAppStoryCard
    public fileprivate(set) var products = [PoqProduct]()
    
    
    init(with storyCard: PoqAppStoryCard) {
        self.storyCard = storyCard
    }
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        if let responseProducts = result as? [PoqProduct] {
            products = responseProducts
        }
        
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }

    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
    open func fetchProducts() {
        guard storyCard.productIds.count > 0 else {
            Log.error("We shuld not create model with 0 product ids")
            products = []
            return
        }

        let externalIds = storyCard.productIds.map({ $0.externalProductId })
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.appStoriesQueryProducts, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: self)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiProductsByExternalIds)

        networkRequest.setQueryParam("externalIds", toValues: externalIds)

        NetworkRequestsQueue.addOperation(networkTask)

    }
}
