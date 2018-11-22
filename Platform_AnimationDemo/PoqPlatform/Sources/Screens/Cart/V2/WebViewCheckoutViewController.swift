//
//  WebViewCheckoutViewController.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import PoqUtilities
import PoqAnalytics
import PoqNetworking
import UIKit

/**
 Web view checkout controller:
 Here we will call our API to get all needed info for web view based checkout
 After this depends on response and some MB settings we will:
    1. Open cart web page
    2. Inject Cookies
    3. Inject CSS
    4. Inject JS
    5. Track order completion
    6. Set login/pass for UAT enviroments, which closed from public behind basic auth
 */
open class WebViewCheckoutViewController: PoqBaseViewController, WebViewCheckoutPresenter, ModalyPresentedCheckout, UIWebViewDelegate {

    weak public var webView: UIWebView?
    
    public static let progressBarHeight: CGFloat = 2

    open lazy var viewModel: WebViewCheckoutService = {
        let res = WebViewCheckoutViewModel()
        res.presenter = self
        return res
    }()

    open override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
        let webView = UIWebView()
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.delegate = self
        self.webView = webView
    }

    open override func viewDidLoad() {
        
        super.viewDidLoad()
        viewModel.createLocationManagerIfNeeded()
        setupCloseButton()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCartTransfer()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.locationManager?.stopUpdatingLocation()
    }
    
    override open func closeButtonClicked() {
        if viewModel.isCheckoutCompleted {
            closeCompletedCheckout()
        } else {
            promtUserAboutLeaveCheckout()
        }
    }
    
    open func continueShoppingClicked() {
        if viewModel.isCheckoutCompleted {
            closeCompletedCheckout()
        } else {
            closeOnContinueCheckout()
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        viewModel.currentLoadingURL = request.url
        if let loadURL = request.url?.absoluteString {
            // Track every url change
            Log.info("Webwiew shouldStartLoadWithRequest: \(loadURL)")
            PoqTrackerHelper.trackCardTransferCheckoutURLRequest(loadURL)
            PoqTrackerV2.shared.checkoutUrlChange(url: loadURL)
        }
        viewModel.checkOrderComplete()
        if viewModel.isOrderReadyForTracking {
            viewModel.sendOrderCompleteTransaction()
        }
        if viewModel.isCurrentUrlContinueShopping {
            continueShoppingClicked()
            return false
        }
        return true
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        Log.debug("Webwiew webViewDidFinishLoad = \(String(describing: webView.request?.url?.absoluteString))")
        let checkoutPagePoqJSCode = CheckoutHelper.initCSSwithJavaScriptCodes(css: AppSettings.sharedInstance.checkoutCSS, js: AppSettings.sharedInstance.checkoutJavaScript)
        webView.stringByEvaluatingJavaScript(from: checkoutPagePoqJSCode)
        viewModel.checkOrderComplete()
        if viewModel.isOrderReadyForTracking {
            viewModel.sendOrderCompleteTransaction()            
        }
        
        // Inject css everytime a request finish.
        CheckoutHelper.injectJSandCSS(webView)
    }
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        
        // Inject JS and CSS upfront.
        CheckoutHelper.injectJSandCSS(webView)
    }
}
