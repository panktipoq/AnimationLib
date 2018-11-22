//
//  VoucherListViewModel.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 27/12/2016.
//
//

import Foundation
import PoqNetworking

class VoucherListViewModel: PoqVoucherListService {
    
    weak var presenter: PoqVoucherListPresenter?
    var vouchers: [PoqVoucherV2]?
    var content: [PoqVoucherListContentItem]?
}
