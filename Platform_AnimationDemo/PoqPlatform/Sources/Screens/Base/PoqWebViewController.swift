//
//  PoqWebViewController.swift
//  Poq.iOS
//  Used for all external links opened via NavigationHelper
//  Created by Mahmut Canga on 26/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities

let poqWebViewAccessibilityIdentifier = "PoqWebViewAccessibilityIdentifier"

open class PoqWebViewController: WebViewController {
    
    // Target url
    open var targetURL: URL?

    // Target url custom page title
    public var targetURLPageTitle: String?
    
    // Viewmodel used for skipping SSL and auto-login
    open var viewModel: CartViewModel?
    
    override public init(url: URL) {
        
        // Setup webview in base class
        super.init(url: url)
        targetURL = url
        
        // Init view model for SSL and auto-login
        viewModel = CartViewModel(controller: self, webView: self.webView)
        
        // When webview is hidden, it should at least to show white background
        view.backgroundColor = UIColor.white
        
        addDoneButton()
        
        // Set loading title
        loadingString = "WEBVIEW_LOADING".localizedPoqString
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = poqWebViewAccessibilityIdentifier
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addDoneButton() {
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(PoqWebViewController.doneDidTap))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneDidTap() {
        
        dismiss(animated: true, completion: nil)
    }
    
    open func startProcess() {
        
        // All assets loaded and can be injected inline
        // Checkout process can start now
        Log.verbose("Webview: Assets loaded, starting the checkout process")
        
        if let url = self.targetURL {
            
            // We are connecting to a staging/authenticated environment
            // We need to trust the server
            viewModel?.openUrl(url)
        }
    }

    // Starting point of loading target url
    override open func show() {

        super.show()
        
        if let absoluteString = self.targetURL?.absoluteString, absoluteString.contains(AppSettings.sharedInstance.clientDomain) {
            // If the URL is on the client domain then we want to see if the user is logged in, if so we inject cookies
            super.webView.stopLoading()
            startProcess()
        }
    }
    
    // MARK: - Webview delegates
    
    override open func webViewDidFinishLoad(_ webView: UIWebView) {
        
        super.webViewDidFinishLoad(webView)
        // Force webView to fit the screen
        if AppSettings.sharedInstance.shouldResizeWebContent == true {
            
            webView.resizeWebContent()
        }
        
        // Inject css everytime a request finish.
        CheckoutHelper.injectJSandCSS(webView)
    }
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        
        // Inject JS and CSS upfront.
        CheckoutHelper.injectJSandCSS(webView)
    }
    
    override open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
                
        if navigationType == UIWebViewNavigationType.linkClicked {

            // Continue shopping URL check
            // If user clicks continue shopping link then we go to home tab
            if let url: String = request.url?.absoluteString, url.contains(AppSettings.sharedInstance.checkoutContinueShoppingURL) {
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                NavigationHelper.sharedInstance.clearTopMostViewController()
                return false
            }
        }
        
        return super.webView(webView, shouldStartLoadWith: request, navigationType: navigationType)
    }
    
    override open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        super.webView(webView, didFailLoadWithError: error)
        
        Log.verbose(error.localizedDescription)
     }
}
