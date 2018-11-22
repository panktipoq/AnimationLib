//
//  PoqBaseViewProtocol.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

protocol BaseViewModelProtocol {
    
    // ______________________________________________________
    
    // MARK: - Presentation layer dependencies
    
    /// This should be weak.
    var viewControllerDelegate: PoqBaseViewController? { get set }

    // Loading indicator
    var spinnerView: PoqSpinner? { get set }
    
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
    
    /**
    Callback after async network task is completed
    */
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?)
}
