//
//  VouchersCategoryViewModel.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/23/16.
//
//

import PoqNetworking
import UIKit

open class VouchersCategoryViewModel: VouchersCategoryService {
    
    open weak var presenter: VouchersCategoryPresenter?
    open var featuredVouchers: [PoqVoucherV2] = []
    open var voucherCategories: [PoqVoucherCategory] = []
    open var content: [VouchersCategoryContent] = []
    open var contentData: [PoqVoucherCategory?] = []
    open var featuredVouchersContent: [VouchersCategoryFeaturedContent] = []
    
}
