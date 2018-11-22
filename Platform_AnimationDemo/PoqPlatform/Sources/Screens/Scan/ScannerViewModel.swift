//
//  ScannerViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 3/2/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class ScannerViewModel: BaseViewModel {
    open var product: PoqProduct?
    open var scanTask: PoqNetworkTask<JSONResponseParser<PoqProduct>>?
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    open func searchByScan(_ barcode: String) {
        guard let _ = scanTask else {
            scanTask = PoqNetworkService(networkTaskDelegate: self).getProductScan( User.getUserId(), scanContent: barcode, isRefresh: false )
            return
        }
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    open override func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    open func clearScanTaskIfExists() {
        if let validScanTask = scanTask {
            validScanTask.cancel()
            scanTask = nil
        }
    }
    
    /**
    Callback after async network task is completed
    */
    open override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result:[])
        
        if let product = result?.first as? PoqProduct {
            self.product = product
            
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        clearScanTaskIfExists()
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    open override func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
        clearScanTaskIfExists()
    }
}
