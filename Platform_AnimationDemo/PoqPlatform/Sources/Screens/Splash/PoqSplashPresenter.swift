//
//  PoqSplashPresenter.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 07/08/2017.
//
//

import Foundation
import PoqModuling
import UIKit

public protocol PoqSplashPresenter: PoqPresenter {
    
    var service: PoqSplashService { get }
    
    /**
     Present a `ForceUpdateViewController` when MightyBot setting `forceUpdate` is enabled.
     Default value for `forceUpdate` is false.
     */
    func showForceUpdateViewController()
    
    /**
     Setup UINavigationBar styling of the current UINavigationController.
     Default implementation hides the navigation bar.
     */
    func setupNavigationBar()
}

extension PoqSplashPresenter where Self: PoqBaseViewController {
    func showForceUpdateViewController() {
        let forceViewController: ForceUpdateViewController =  ForceUpdateViewController(nibName: ForceUpdateViewController.XibName, bundle: nil)
        navigationController?.present(forceViewController, animated: true, completion: nil)
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
}
