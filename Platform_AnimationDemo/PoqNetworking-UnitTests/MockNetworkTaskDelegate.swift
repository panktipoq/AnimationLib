//
//  MockNetworkTaskDelegate.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/4/17.
//
//

import Foundation

@testable import PoqNetworking

class MockNetworkTaskDelegate: PoqNetworkTaskDelegate {
    
    var willStartBlock: ((PoqNetworkTaskTypeProvider) -> Void)?
    var didCompleteBlock: ((PoqNetworkTaskTypeProvider, [Any]?) -> Void)?
    var didFailBlock: ((PoqNetworkTaskTypeProvider, NSError?) -> Void)?
    
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        willStartBlock?(networkTaskType)
    }
    
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        didCompleteBlock?(networkTaskType, result)
    }
    
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        didFailBlock?(networkTaskType, error)
    }
    
}
