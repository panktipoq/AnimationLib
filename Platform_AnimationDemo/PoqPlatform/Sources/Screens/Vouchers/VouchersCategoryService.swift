//
//  VouchersCategoryService.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 1/4/17.
//
//

import Foundation
import PoqNetworking

public protocol VouchersCategoryService: PoqNetworkTaskDelegate {
    
    // Stored data in view model
    var presenter: VouchersCategoryPresenter? { get set }
    var featuredVouchers: [PoqVoucherV2] { get set }
    var voucherCategories: [PoqVoucherCategory] { get set }
    var content: [VouchersCategoryContent] { get set }
    var contentData: [PoqVoucherCategory?] { get set }
    var featuredVouchersContent: [VouchersCategoryFeaturedContent] { get set }
    
    // Network operation responses
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
}

extension VouchersCategoryService {
    
    // MARK: - Basic network task callbacks
    
    public func generateContent() {
        
        content = []
        
        content.append(VouchersCategoryContent(type: .header))
        content.append(VouchersCategoryContent(type: .section))
        
        let elements = [VouchersCategoryContent](repeating: VouchersCategoryContent(type: .element), count: voucherCategories.count)
        
        content.append(contentsOf: elements)
        
        content.append(VouchersCategoryContent(type: .section))
        content.append(VouchersCategoryContent(type: .element))
        
        // Setup content data
        contentData = []
        
        contentData.append(nil)
        
        let sectionVoucherCategory1 = PoqVoucherCategory()
        sectionVoucherCategory1.title = AppLocalization.sharedInstance.vouchersSectionTitleText
        
        contentData.append(sectionVoucherCategory1)
        
        contentData.append(contentsOf: voucherCategories.map({ $0 as PoqVoucherCategory? }))
        
        let sectionVoucherCategory2 = PoqVoucherCategory()
        sectionVoucherCategory2.title = AppLocalization.sharedInstance.offersSectionTitleText
        
        contentData.append(sectionVoucherCategory2)
        
        let allOffersVoucherCategory = PoqVoucherCategory()
        allOffersVoucherCategory.title = AppLocalization.sharedInstance.viewAllOffersText
        
        contentData.append(allOffersVoucherCategory)
        
        // Setup featured content data
        
        if !featuredVouchers.isEmpty {
            featuredVouchersContent = [VouchersCategoryFeaturedContent](repeating: VouchersCategoryFeaturedContent(type: .element),
                                                                        count: featuredVouchers.count)
        } else {
            featuredVouchersContent = [VouchersCategoryFeaturedContent(type: .logo)]
        }
    }
    
    public func getDashboardItems() {
        
        PoqNetworkService(networkTaskDelegate: self).getVouchersDashboard()
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        if networkTaskType == PoqNetworkTaskType.getVouchersDashboard {
            
            guard let networkResult: [PoqVouchersDashboard] = result as? [PoqVouchersDashboard], let dashboard = networkResult.first else {
                return
            }
            
            featuredVouchers = dashboard.featuredVouchers.sorted(by: {
                guard let sortIndex1 = $0.sortIndex, let sortIndex2 = $1.sortIndex else {
                    return false
                }
                return sortIndex1 > sortIndex2
            })
            voucherCategories = dashboard.voucherCategories.sorted(by: {
                guard let sortIndex1 = $0.sortIndex, let sortIndex2 = $1.sortIndex else {
                    return false
                }
                return sortIndex1 > sortIndex2
            })
            
            presenter?.update(state: .completed, networkTaskType: networkTaskType)
        }
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
