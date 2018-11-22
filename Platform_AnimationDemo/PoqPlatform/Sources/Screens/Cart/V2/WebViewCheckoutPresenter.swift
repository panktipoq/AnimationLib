//
//  WebViewCheckoutPresenter.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

public protocol WebViewCheckoutPresenter: PoqPresenter {
    
    /// This should be weak.
    var webView: UIWebView? { get }
    var viewModel: WebViewCheckoutService { get }
    
    /// In default implementation put close button on top right
    /// Self should override CloseButtonDelegate methods to customize behaviour
    func setupCloseButton()
}

public extension WebViewCheckoutPresenter where Self: PoqBaseViewController {
    
    func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        guard let request = viewModel.createWebViewRequest() else {
            Log.error("Completer API call, but don't have a proper response")
            // Looks like we won't get info, usful for user
            showErrorMessage(nil)
            return
        }
        
        switch networkTaskType {
        case PoqNetworkTaskType.startCartTransfer:
            viewModel.injectCookies()
            Log.verbose("Loading \(request)")
            webView?.loadRequest(request)
        default:
            break
        }
    }
    
    func setupCloseButton() {
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
    }
}
