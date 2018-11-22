//
//  PoqVoucherDetailPresenter.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 30/12/2016.
//
//

import Foundation


public protocol PoqVoucherDetailPresenter: PoqPresenter {
    
    var service: PoqVoucherDetailService { get }
    
    func setupNavigationBar()
    
    func openExclusionsView(_ exclusions: String)
}

extension PoqVoucherDetailPresenter where Self: PoqBaseViewController {
    
    public func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.voucherDetailsTitle)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
    }
    
    public func openExclusionsView(_ exclusions: String) {
        let exclusionsViewController = UIViewController()
        exclusionsViewController.navigationItem.titleView = NavigationBarHelper.setupTitleView("Exclusions")
        exclusionsViewController.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        let exclusionsTextView = UITextView(frame: exclusionsViewController.view.bounds)
        exclusionsTextView.text = exclusions
        exclusionsViewController.view.addSubview(exclusionsTextView)
        show(exclusionsViewController, sender: self)
    }
    
}
