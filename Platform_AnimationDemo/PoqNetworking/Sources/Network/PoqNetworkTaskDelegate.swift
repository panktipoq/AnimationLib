//
//  PoqNetworkTaskDelegate.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 09/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public protocol PoqNetworkTaskDelegate: AnyObject {
        
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider)
    
    // TODO:
    //  Result is always carried as array of AnyObject. This bit is open to discussion
    //  I realised, almost all of our api endpoints are array of JSON objects except product detail
    //  So this approached looked OK for me in the first instance.
    //  However, any improvements are highly appreciated
    
    
    /// Callback after async network task is completed successfully
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type
    ///   - result: The response payload
    ///   - statusCode: The http status code
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?, statusCode: Int)
    
    /**
     Callback after async network task is completed successfully
     */
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    
    /**
    Callback when task fails due to lack of responded data, connectivity etc.
    */
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?)
}

extension PoqNetworkTaskDelegate {
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}
    
    
    // Default implementation to ensure clients do not have to implement the new protocol method with status code
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?, statusCode: Int) {
        
        self.networkTaskDidComplete(networkTaskType, result: result)
    }
}
