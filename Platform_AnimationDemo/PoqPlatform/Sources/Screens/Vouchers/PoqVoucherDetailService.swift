//
//  PoqVoucherDetailService.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 30/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol PoqVoucherDetailService: PoqNetworkTaskDelegate {
    var presenter: PoqVoucherDetailPresenter? { get set }
    var voucher: PoqVoucherV2? { get set }
    
    
    func getVoucherDetails(_ voucherId: Int)
    func postVoucherToBag(_ voucher: PoqVoucherV2)
    
    //MARK :- Methods
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    func parseVoucherDetails(_ result: [PoqVoucherV2]?)
}

extension PoqVoucherDetailService {
    
    public func getVoucherDetails(_ voucherId: Int) {
        
        PoqNetworkService(networkTaskDelegate: self).getVoucherDetails(voucherId)
    }
    
    public func postVoucherToBag(_ voucher: PoqVoucherV2) {
        
        // Empty default implementation
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
        case PoqNetworkTaskType.getVoucherDetails:
            parseVoucherDetails(result as? [PoqVoucherV2])
        default:
            Log.error("Response handler for network task type not implemented")
            
        }
    }
    
    public func parseVoucherDetails(_ result: [PoqVoucherV2]?) {
        
        guard let vouchers = result, vouchers.count == 1 else {
            showVoucherNotFound()
            return
        }
        
        voucher = vouchers[0]
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.getVoucherDetails)
        
    }
    
    
    func showVoucherNotFound() {
        
        let error = NSError(domain: "Not Found", code: HTTPResponseCode.NOT_FOUND, userInfo: [NSLocalizedDescriptionKey : "VOUCHER_NOT_FOUND".localizedPoqString])
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.getVoucherDetails, withNetworkError: error)
    }
    
    
    // MARK: - Network Task Callbacks
    
    /**
     Callback before start of the async network task
     */
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    /**
     Callback after async network task is completed successfully
     */
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
    }
    
    /**
     Callback when task fails due to lack of responded data, connectivity etc.
     */
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }

}
