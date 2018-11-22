//
//  PoqVoucherListService.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 27/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol PoqVoucherListService: PoqNetworkTaskDelegate {
    
    //MARK :- Properties
    var presenter: PoqVoucherListPresenter? { get set }
    var vouchers: [PoqVoucherV2]? { get set }
    var content: [PoqVoucherListContentItem]? { get set }
    
    //MARK :- Network operation requests
    func getVouchers(_ categoryId: Int?)
    
    //MARK :- Network operation responses
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    func parseVouchers(_ result: [PoqVoucherV2]?)
    
    func generateContent()
    
    func showVoucherNotFound()
    
}


extension PoqVoucherListService {
    
    public func generateContent() {
        
        guard let vouchers = self.vouchers else {
            Log.error("Attempt to generate voucher content without fetching vouchers")
            return
        }
        content = []
        
        for voucher in vouchers {
            content?.append(PoqVoucherListContentItem(type: .info, voucher: voucher))
        }
    }
    
    public func getVouchers(_ categoryId: Int?) {
        guard let categoryId = categoryId else {
            Log.warning("Attempt to fetch vouchers for nil category id")
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).getVouchers(forCategory: categoryId)
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getVouchers:
            parseVouchers(result as? [PoqVoucherV2])
        default:
            Log.error("Response handler for network task type not implemented")
            
        }
    }
    
    public func parseVouchers(_ result: [PoqVoucherV2]?) {
        
        guard let vouchers = result, !vouchers.isEmpty else {
            showVoucherNotFound()
            self.vouchers = []
            return
        }
        
        self.vouchers = vouchers
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.getVouchers)
        
    }
    
    
    public func showVoucherNotFound() {
        
        let error = NSError(domain: "Not Found", code: HTTPResponseCode.NOT_FOUND, userInfo: [NSLocalizedDescriptionKey : AppLocalization.sharedInstance.vouchersNotFoundText])
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.getVouchers, withNetworkError: error)
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

