//
//  ProductGroupedListViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 26/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

/// TODO: Gabriel Sabiescu documentation
open class ProductGroupedListViewModel  : BaseViewModel {
    
    /// TODO: Gabriel Sabiescu documentation
    open var products:[PoqProduct]
    
    /// TODO: Gabriel Sabiescu documentation
    open var filteredResult:PoqFilterResult?
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameter viewControllerDelegate: TODO: Gabriel Sabiescu documentation
    override init(viewControllerDelegate:PoqBaseViewController) {
        
        self.products = []
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameter bundleId: TODO: Gabriel Sabiescu documentation
    func getProductsByBundleId( _ bundleId: String? ){
        guard let validBundleId = bundleId else {
            Log.error("Bundle ID is nil cannot fetch product")
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).getProductsByBundleId(validBundleId)
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - relatedProductIds: TODO: Gabriel Sabiescu documentation
    ///   - isRefresh: TODO: Gabriel Sabiescu documentation
    func getProducts(withIDs relatedProductIds: [Int], isRefresh: Bool = false) {
        
        PoqNetworkService(networkTaskDelegate: self).getProductsByIds(relatedProductIds: relatedProductIds, isRefresh:isRefresh)
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - relatedProductExternalIds: TODO: Gabriel Sabiescu documentation
    ///   - isRefresh: TODO: Gabriel Sabiescu documentation
    func getProducts(withIDs relatedProductExternalIds: [String], isRefresh: Bool = false) {
        PoqNetworkService(networkTaskDelegate: self).getProductsByIds(relatedProductExternalIds: relatedProductExternalIds, isRefresh:isRefresh)
    }
    
    /// Called when a network task type starts
    ///
    /// - Parameter networkTaskType: The type of the network task that started
    override open func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider){
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /// Called when a network request is completed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that completed
    ///   - result: The result of the network request completion
    override open func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?){
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType,result:[])
        
        if result != nil{
            
            if networkTaskType == PoqNetworkTaskType.productsByIds || networkTaskType == PoqNetworkTaskType.productsByBundle {
                
                filteredResult = (result! as! [PoqFilterResult])[0]
                
                guard let filteredProducts = filteredResult?.products else {
                    networkTaskDidFail(networkTaskType, error: nil)
                    return
                }
                
                products.append(contentsOf: filteredProducts)
           
            } else if networkTaskType == PoqNetworkTaskType.productsByExternalIds {
                
                guard let productsInResponse = result as? [PoqProduct] else {
                    Log.error("Wrong response received for \(networkTaskType)")
                    networkTaskDidFail(networkTaskType, error: nil)
                    return
                }
                
                products.append(contentsOf: productsInResponse)
            }
            
            viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
            
        }
        else {
            
            self.networkTaskDidFail(networkTaskType, error: nil)
        }
        
    }
    
    /// Called when a network request failed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed
    ///   - error: The acompanying error of the request failure
    override open func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}
