//
//  PoqMyProfileListPresenter.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by Gabriel Sabiescu on 20/01/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import SVProgressHUD
import UIKit

public protocol PoqMyProfileListPresenter: PoqPresenter {
    
    var service: PoqMyProfileListService { get }

    func setupNavigationBar(_ title: String)
    func tapProfileListCell(_ cellId: Int)
    func showLoginError()
    
}

extension PoqMyProfileListPresenter where Self: PoqBaseViewController {
    
    public func setupNavigationBar(_ title: String) {
        navigationItem.titleView = NavigationBarHelper.setupTitleView(title)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
    }
    
    public func tapProfileListCell(_ cellId: Int) {
        Log.verbose("Opening voucher detail view for voucher Id \(cellId)")
    }
    
    public func showLoginError() {
        
        // After updating email address, we get login error
        // So, "your account updated" message for SVProgressHUD might be on screen
        SVProgressHUD.dismiss()
        
        let title = "Login Error"
        let message = "An error occured while getting account details.\nPlease login again to refresh your session."
        let confirm = "OK"
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: confirm, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            PoqTrackerHelper.trackUserLogout()
            LoginHelper.clear()
            
        }))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
}
