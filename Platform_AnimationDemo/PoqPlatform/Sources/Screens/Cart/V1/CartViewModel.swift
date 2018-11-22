//
//  CartViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 04/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqNetworking
import PoqUtilities

// TODO: Is this still true?
// Because PoqWebviewController not able to extend both PoqBaseViewController and JBWebViewController
// This viewmodel is not going to extend BaseViewModel
// So then we can use this viewmodel in CartViewController and PoqWebviewController together

open class CartViewModel: NSObject, PoqNetworkTaskDelegate {

    // Target url
    open var targetURL: URL?
    
    // Logged in user account. This includes cookie data etc. So it LoginHelper and saved data is not used. It needs to be fresh!
    open var currentUser: PoqAccount?
    
    // Webview reference from the controller
    open var webView: UIWebView?
    
    // Activity indicator to be shown during network operation material desing loading indicator

    open var spinnerView: PoqSpinner?
    
    // Controller uses this viewmodel
    open var controller: UIViewController
    
    public override init() {
        self.controller = UIViewController()
    }

    public init(controller: UIViewController, webView: UIWebView) {
        self.webView = webView
        self.controller = controller
    }

    public func openUrl(_ targetURL: URL) {
        self.targetURL = targetURL
        Log.verbose("Webview: URL Connection\n\(String(describing: self.targetURL))")
        if targetURL.absoluteString.contains(AppSettings.sharedInstance.clientDomain), LoginHelper.isLoggedIn() {
            // If there is a logged user then auto-login
            Log.verbose("Webview: Url a client domain and user logged in. Auto-login is triggered")
            loginUser()
        } else {
            Log.verbose("Webview: Url a client domain but user is not logged in")
            // User data not found. Load target url
            if let targetURL = self.targetURL {
                let request = createRequest(targetURL) as URLRequest
                Log.info("Loading \(request)")
                webView?.loadRequest(request)
            }
        }
    }
    
    public func removeBagItems() {
        PoqNetworkService(networkTaskDelegate: self).deleteUsersAllBagItems(User.getUserId())
    }
    
    public func loginUser() {
        // Always get latest cookie information for auto-login to avoid cache issues
        PoqNetworkService(networkTaskDelegate: self).getAccount(true)
    }

    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskType) {
        if networkTaskType == PoqNetworkTaskType.getAccount {
            Log.verbose("Webview: Account details are called")
        }
        if networkTaskType == PoqNetworkTaskType.deleteAllBag {
            Log.verbose("Webview: Bagitems removal called")
        }
    }
    
    // TODO:
    //  Result is always carried as array of AnyObject. This bit is open to discussion
    //  I realised, almost all of our api endpoints are array of JSON objects except product detail
    //  So this approached looked OK for me in the first instance.
    //  However, any improvements are highly appreciated
    
    /**
    Callback after async network task is completed successfully
    */
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        var isAccountDataLoaded = false
        if networkTaskType == PoqNetworkTaskType.getAccount {
            if let accountDetails = result as? [PoqAccount], let userRespons = accountDetails.first, userRespons.statusCode == HTTPResponseCode.OK {
                currentUser = userRespons
                isAccountDataLoaded  = true
                if let url = targetURL {
                    let request = createRequest(url)
                    CookiesHelper.injectCookies(cookies: currentUser?.cookies)
                    Log.verbose("Webview: URL is loaded with user credentials (auto login). Loading \(request)")
                    webView?.loadRequest(request as URLRequest)
                }
            }
            if !isAccountDataLoaded {
                Log.verbose("User data not found or api returned error. Load target url anyway")
                if let url = self.targetURL {
                    let request = createRequest(url) as URLRequest
                    Log.verbose("Loading \(request)")
                    webView?.loadRequest(request)
                }
            }
        }
        if networkTaskType == PoqNetworkTaskType.deleteAllBag {
            Log.verbose("User bag items removed")
            let tabIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
            BadgeHelper.setBadge(for: tabIndex, value: 0)
        }
    }
    
    /**
    Callback when task fails due to lack of responded data, connectivity etc.
    */
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError? ) {
        if networkTaskType == PoqNetworkTaskType.getAccount {
            // User data not found or api returned error. Load target url anyway
            if let url = self.targetURL {
                let request = createRequest(url) as URLRequest
                Log.verbose("Loading \(request)")
                webView?.loadRequest(request)
            }
        }
    }

    // MARK: - Basic network task callbacks
    
    public func startSpinner() {
        if spinnerView == nil {
            let spinnerView = PoqSpinner(frame: CGRect.zero)
            spinnerView.tintColor = AppTheme.sharedInstance.mainColor
            controller.view.addSubview(spinnerView)
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            spinnerView.applyCenterPositionConstraints()
            self.spinnerView = spinnerView
        }
        spinnerView?.startAnimating()
    }
    
    public func stopSpinner() {
        spinnerView?.stopAnimating()
        spinnerView?.removeFromSuperview()
    }
    
    public func createRequest(_ url: URL) -> NSMutableURLRequest {
        Log.verbose("Request will be created for:\n\(url)")
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        if AppSettings.sharedInstance.isAuthenticationRequired {
            // For UAT /staging environment only set up the base64-encoded credentials
            let username = AppSettings.sharedInstance.userName
            let password = AppSettings.sharedInstance.passWord
            let loginString = NSString(format: "%@:%@", username, password)
            if let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue) {
                let base64LoginString = loginData.base64EncodedString(options: [])
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            }
        }
        return request
    }
}
