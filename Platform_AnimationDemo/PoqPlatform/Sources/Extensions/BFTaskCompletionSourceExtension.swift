//
//  BFTaskCompletionSourceExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 02/03/2016.
//
//

import BoltsSwift
import Foundation
import PoqNetworking
import PoqUtilities

extension TaskCompletionSource: PoqNetworkTaskDelegate {
    
    @nonobjc
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
    }
    
    @nonobjc
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        guard let validResult = result as? TResult else {
            Log.error("We can't convers respons of request to TResult. TResult = \(type(of: TResult.self ))")
            return
        }
        set(result: validResult)
    }
    
    @nonobjc
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        let error: NSError = error ?? NSError(domain: "NetworkErrorDomain", code: 1, userInfo: nil)
        set(error: error)
    }

}
