//
//  VoucherDetailViewModel.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 30/12/2016.
//
//

import Foundation
import PoqNetworking

class VoucherDetailViewModel: PoqVoucherDetailService {
    weak var presenter: PoqVoucherDetailPresenter?
    var voucher: PoqVoucherV2?
}
