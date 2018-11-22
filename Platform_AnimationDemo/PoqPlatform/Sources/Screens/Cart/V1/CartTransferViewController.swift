//
//  CartTransferViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import ObjectMapper
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class CartTransferViewController: PoqBaseViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, ModalyPresentedCheckout, WebViewCheckout {
    
    public typealias OrderItemType = PoqOrder<PoqOrderItem>
    
    // IBOutlets
    @IBOutlet open  weak var cartTransferWebView: UIWebView?
    
    // Fields
    open var cartURL: String?
    open var order = OrderItemType()
    
    // Viewmodel for auto-signing and ssl issues
    open var viewModel = CartViewModel()
    
    open var hasRedirectedCart = false
    
    // This value can be different from current UIWebView URL
    open var currentLoadingURL: URL?
    
    open lazy var previousNavigationButton : () -> UIBarButtonItem? = {
        [weak self] in
        let previousButton = PreviousButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        previousButton.backgroundColor = UIColor.clear
        previousButton.addTarget(self, action: #selector(CartTransferViewController.previousButtonClicked), for: UIControlEvents.touchUpInside)
        return self?.poqCheckoutButtonWithCustomView(previousButton)
    }
    
    open lazy var nextNavigationButton : () -> UIBarButtonItem? = {
        [weak self] in
        let nextButton = NextButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        nextButton.addTarget(self, action: #selector(CartTransferViewController.nextButtonClicked), for: UIControlEvents.touchUpInside)
        nextButton.backgroundColor = UIColor.clear

        return self?.poqCheckoutButtonWithCustomView(nextButton)
    }
    
    open func getIsSameDomain() -> Bool {
        return true
    }
    
    open func updateNavigationButtons() {
        
        guard let webView = cartTransferWebView else {
            return
        }
        
        var buttonArray: Array<UIBarButtonItem> = Array<UIBarButtonItem>()
        
        if webView.canGoForward, let validNextNavigationButton = self.nextNavigationButton() {
            buttonArray.append(validNextNavigationButton)
        }
        
        if webView.canGoBack, let validPreviousNavigationButton = self.previousNavigationButton() {
            buttonArray.append(validPreviousNavigationButton)
        }
        self.navigationItem.rightBarButtonItems = buttonArray
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavigationBar()
        setupViewModel()
        
        CookiesHelper.injectClientSpecificCookies()
        
        startCheckout()
        
    }
    
    @objc open func previousButtonClicked() {
        guard let webView = cartTransferWebView else {
            return
        }

        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc open func nextButtonClicked() {
        guard let webView = cartTransferWebView else {
            return
        }
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    open func setupViewModel() {
        
        viewModel.controller = self
        viewModel.webView = cartTransferWebView
    }
    
    open func setupNavigationBar() {
        
        self.navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.checkoutNavigationTitle, titleFont: AppTheme.sharedInstance.checkoutNaviTitleFont, titleColor: UIColor.black)
        
        // set up back button
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        self.updateNavigationButtons()
    }
    
    open override func closeButtonClicked() {
        
        if order.isCheckoutCompleted {
            closeCompletedCheckout()
        } else {
            promtUserAboutLeaveCheckout()
        }
    }

    // Called after downloading css/js
    open func startCheckout() {
        
        // Skip adding items to bag for logged in user
        // Instead just connect to client domain to show cart details
        if LoginHelper.isLoggedIn() {
            
            if let url = URL(string: AppSettings.sharedInstance.showCartURL) {
                viewModel.openUrl(url)
            }
        } else {
            
            // Anonymous user checkout
            // Clear all cookies to avoid duplicated items in shopping bag
            if let urlString = cartURL, let url = URL(string: urlString) {
                viewModel.openUrl(url)
            }
        }
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        let nsError: NSError = error as NSError

        parseAndTrackWebViewError(webView, error: nsError)
        
        if nsError.code == Int(kCFStreamErrorDomainSSL) {
            
            showWebViewSSLErrorWarning(webView, error: nsError)
        }
    }
    
    open func showWebViewSSLErrorWarning(_ webView: UIWebView, error: NSError) {
        guard !error.isCancelledRequestError() else {
            return
        }
        
        let extraParams = error.trackingData()
        
        Log.verbose("Webview ssl error data:\n \(extraParams)")
        
        PoqTrackerHelper.trackCardTransferCheckoutErrorRefresh(String(error.code), extraParams: extraParams)
    }
    
    open func parseAndTrackWebViewError(_ webView: UIWebView, error: NSError) {
        
        Log.verbose("Webview error description:\n \(error.localizedDescription)")
        Log.verbose("Webview error code:\n \(error.code)")
        
        // Track SSL error for extra debugging
        var extraParams: [String: String] = [:]
        extraParams["description"] = error.localizedDescription
        extraParams["domain"] = error.domain
        
        if let url = webView.request?.url?.absoluteString {
            
            extraParams["url"] = url
        }
        
        if let failureReason = error.localizedFailureReason {
            
            extraParams["localizedFailureReason"] = failureReason
        }
        
        PoqTrackerHelper.trackCardTransferCheckoutError(String(error.code))

    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
 
        currentLoadingURL = request.url

        if let loadURL = request.url?.absoluteString {
            Log.verbose("Webwiew shouldStartLoadWithRequest: %@", loadURL)
            
            // Track every url change
            PoqTrackerHelper.trackCardTransferCheckoutURLRequest(loadURL)
            PoqTrackerV2.shared.checkoutUrlChange(url: loadURL)
        }

        checkOrderComplete()
        if isOrderReadyForTracking {
            
            sendOrderCompleteTransaction()            
        }

        if isCurrentUrlContinueShopping {
            
            stopLoadingAndCloseView(webView)
            return false
        }
        
        self.updateNavigationButtons()
        
        return true
    }

    open func stopLoadingAndCloseView(_ webView: UIWebView) {
        
        webView.stopLoading()
        closeButtonClicked()
    }
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        self.updateNavigationButtons()
        
        // Inject JS and CSS upfront.
        CheckoutHelper.injectJSandCSS(webView)
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {

        Log.debug("Webwiew webViewDidFinishLoad = \(webView.request?.url?.absoluteString ?? "")")
        
        checkOrderComplete()
        if isOrderReadyForTracking {
            
            sendOrderCompleteTransaction()            
        }
        
        updateNavigationButtons()
        
        // Inject css everytime a request finish.
        CheckoutHelper.injectJSandCSS(webView)
    }

    // Mark: - Layar
    open func sendLayarTrackingForOrder(_ order: OrderItemType) {
        
        self.sendTrackingDetailsForPurchasedLayarItems(order)
        self.sendTrackingDetailsIfUsedLayarScannerThenMadeAnyPurchase()
    }

    open func sendTrackingDetailsForPurchasedLayarItems(_ order: OrderItemType) {
    }
    
    open func sendTrackingDetailsIfUsedLayarScannerThenMadeAnyPurchase() {
    }
    
    open func poqCheckoutButtonWithCustomView( _ customView: UIView ) -> UIBarButtonItem? {
        guard let currentRequest = cartTransferWebView?.request, let urlAbsoluteString = currentRequest.url?.absoluteString else {
            return nil
        }
        
        if AppSettings.sharedInstance.showCheckoutNavigation && urlAbsoluteString.contains(AppSettings.sharedInstance.acceptedCheckoutDomains) {
            return UIBarButtonItem(customView: customView)
        } else {
            return nil
        }
    }
    
    // MARK: WebViewCheckout
    open func sendAdditionalTracking() {
        self.sendLayarTrackingForOrder(order)
    }
}
