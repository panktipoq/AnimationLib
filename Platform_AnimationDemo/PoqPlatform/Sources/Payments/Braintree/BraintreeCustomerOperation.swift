//
//  BraintreeCustomerOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/07/2016.
//
//

import Foundation
import PoqNetworking

public typealias BraintreeOperationCompletion = (NSError?) -> Void

open class BraintreeCustomerOperation: PoqOperation {
    
    public let completion: BraintreeOperationCompletion
    
    public init(completion: @escaping BraintreeOperationCompletion) {
        self.completion = completion
    }
    
    open class func createError(withMessage message: String?) -> NSError {
        
        let errorString = message ?? "TRY_AGAIN".localizedPoqString
        let userInfo = [NSLocalizedDescriptionKey: errorString]
        
        let error = NSError(domain: braintreeErrorDomain, code: 0, userInfo: userInfo)
        return error
    }
    
    // MARK: - Subclass
    /**
     If any addition action required when we update customer - override this method
     */
    func updateCustomer(withResounse customer: PoqBraintreeCustomer) {
        BraintreeHelper.sharedInstance.updateBraintreeCustomer(customer)
    }
}

extension BraintreeCustomerOperation: PoqNetworkTaskDelegate {
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        guard let customer: PoqBraintreeCustomer = result?.first as? PoqBraintreeCustomer else {
            let resError: NSError = BraintreeCustomerOperation.createError(withMessage: nil)
            completion(resError)
            return
        }
        
        updateCustomer(withResounse: customer)
        
        completion(nil)
        finish()
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        let resError: NSError = BraintreeCustomerOperation.createError(withMessage: error?.localizedDescription)
        completion(resError)
        finish()
    }
}
