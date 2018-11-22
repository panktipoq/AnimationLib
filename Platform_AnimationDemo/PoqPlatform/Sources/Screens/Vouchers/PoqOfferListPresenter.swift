//
//  PoqOfferListPresenter.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation


public protocol PoqOfferListPresenter: PoqPresenter {
    
    var service: PoqOfferListService { get }
    
    func setupNavigationBar()
    
}


extension PoqOfferListPresenter where Self: PoqBaseViewController {
    
    public func setupNavigationBar() {
        navigationItem.titleView = NavigationBarHelper.setupTitleView("Offers")
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
    }
}
