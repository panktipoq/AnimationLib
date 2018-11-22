//
//  PoqVoucherListPresenter.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 27/12/2016.
//
//

import Foundation
import PoqNetworking

public protocol PoqVoucherListPresenter: PoqPresenter {
    
    var service: PoqVoucherListService { get }
    
    func setupNavigationBar(_ title: String)
    
    func openVoucherDetail(_ voucherId: Int)
    
    func applyVoucherToBag(_ voucher: PoqVoucherV2)
}


extension PoqVoucherListPresenter where Self: PoqBaseViewController {
    
    public func setupNavigationBar(_ title: String) {
        navigationItem.titleView = NavigationBarHelper.setupTitleView(title)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
    }
    
}
