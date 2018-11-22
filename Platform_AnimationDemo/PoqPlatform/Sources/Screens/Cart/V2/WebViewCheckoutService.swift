//
//  WebViewCheckoutService.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import CoreLocation
import PoqNetworking
import PoqUtilities

public protocol WebViewCheckoutService: WebViewCheckout {
    
    /// This should be weak.
    var presenter: WebViewCheckoutPresenter? { get set }
    
    var cartTransferResponse: StartCartTransferResponse? { get set }
    
    /// Might be nil, depends on 'enableNearestStoreTracking'
    var locationManager: CLLocationManager? { get set }
    
    var isCheckoutCompleted: Bool { get }
    
    /// Create location manager if needed, should be called as soon as possible
    /// We also start here tracking, it is good, stop it somewhere later
    func createLocationManagerIfNeeded()
    
    /// Send request to API for getting cart transfer info
    func startCartTransfer()
    
    /// Create request to open web checkout. Depends on cartTransferResponse
    func createWebViewRequest() -> URLRequest?
    
    /// Check client specific cookies in MB, as well as cookies in cartTransferResponse
    /// Also, to avoid any duplications, we will crear cookies first
    func injectCookies()

    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
}

public extension WebViewCheckoutService {
    
    public typealias OrderItemType = PoqOrder<PoqOrderItem>

    func startCartTransfer() {
        let body = StartCartTransferPostBody()
        if let location = locationManager?.location, AppSettings.sharedInstance.enableNearestStoreTracking {
            body.latitude = location.coordinate.latitude 
            body.longitude = location.coordinate.longitude
            body.sendNearestStore = true
        }
        
        if BagHelper.usesCartApi {
            PoqNetworkService(networkTaskDelegate: self).checkoutStart()
        } else {
            PoqNetworkService(networkTaskDelegate: self).startCartTransfer(with: body)
        }
        
    }

    func createLocationManagerIfNeeded() {
        guard AppSettings.sharedInstance.enableNearestStoreTracking else {
            return
        }
        locationManager = CLLocationManager()
        locationManager?.startUpdatingLocation()
    }
    
    func createWebViewRequest() -> URLRequest? {
        guard let cartTransfer = cartTransferResponse else {
            Log.error("We are trying create requies, but don't have response")
            return nil
        }
        guard let urlString = cartTransfer.url, let url = URL(string: urlString) else {
            Log.error("Incorrect URL: \(String(describing: cartTransfer.url))")
            return nil
        }
        
        var res = URLRequest(url: url)
        cartTransferResponse?.headers?.compactMap { $0 }.forEach { header in
            if let name = header.name, let value = header.value {
                res.addValue(value, forHTTPHeaderField: name)
                Log.verbose("Adding header \(name): \(value)")
            }
        }
        res.httpMethod = cartTransfer.httpMethod ?? "GET"
        res.httpBody = cartTransfer.body?.data(using: .utf8)
        if res.httpBody != nil {
            res.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        if AppSettings.sharedInstance.isAuthenticationRequired {
            // For UAT /staging environment only set up the base64-encoded credentials
            let username = AppSettings.sharedInstance.userName
            let password = AppSettings.sharedInstance.passWord
            guard !username.isEmpty, !password.isEmpty else {
                Log.error("Authentication is required but empty username or password is provided.")
                return res
            }
            let loginString = "\(username):\(password)"
            guard let loginData = loginString.data(using: .utf8) else {
                Log.error("Error encoding username and data string")
                return res
            }
            let base64LoginString = loginData.base64EncodedString()
            res.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        return res
    }
    
    func injectCookies() {
        CookiesHelper.clearCookies()
        CookiesHelper.injectClientSpecificCookies()
        var cookies = [PoqAccountCookie]()
        if let cartCookies = cartTransferResponse?.cookies?.filter({ $0.name != nil && $0.value != nil }) {
            cookies.append(contentsOf: cartCookies)
        }
        CookiesHelper.injectCookies(cookies: cookies)
    }
    
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        guard let response = result?.first as? StartCartTransferResponse else {
            Log.error("We get response, but can't cast it to StartCartTransferResponse")
            return
        }
        order.update(with: response.order)
        cartTransferResponse = response
    }
    
    // MARK: - WebViewCheckout
    func trackOrderInternally(_ order: OrderItemType) {
        let postBody = CompleteCartTransferPostBody(order: order)
        
        if BagHelper.usesCartApi {
            PoqNetworkService(networkTaskDelegate: self).checkoutComplete(with: postBody)
        } else {
            PoqNetworkService(networkTaskDelegate: self).completeCartTransfer(with: postBody)
        }
    }

    // MARK: - PoqNetworkTaskDelegate
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }

    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        if networkTaskType == PoqNetworkTaskType.startCartTransfer {
            parseResponse(networkTaskType, result: result)
        }
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
}
