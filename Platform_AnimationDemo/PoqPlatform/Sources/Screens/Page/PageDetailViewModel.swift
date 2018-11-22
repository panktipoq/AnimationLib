//
//  PageDetailViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

open class PageDetailViewModel: BaseViewModel {
    
    // ______________________________________________________
    
    // MARK: - Initializers
    open var page:PoqPage?
    
    public override init(viewControllerDelegate:PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network tasks
    public  func getPageDetails(_ pageId:Int, isRefresh:Bool = false){
        
        PoqNetworkService(networkTaskDelegate: self).getPageDetails(pageId, isRefresh:isRefresh)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    override open func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider){
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override open func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType,result:[])
        
        if result != nil{
            
            if networkTaskType == PoqNetworkTaskType.pageDetails {
                
                if result!.count > 0 {
                    
                    page = (result as! [PoqPage])[0]
                }
            }
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

}
