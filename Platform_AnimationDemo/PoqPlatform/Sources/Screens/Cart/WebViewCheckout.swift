//
//  WebViewCheckout.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/16/17.
//
//

import Foundation
import ObjectMapper
import PoqModuling
import PoqUtilities
import PoqNetworking
import PoqAnalytics

/// Describe functionality for:
///     Checking does checkout complete or not
///     Collecting checkout data from web view
public protocol WebViewCheckout: PoqNetworkTaskDelegate {
    
    /// Here will occumalte information about order
    var order: PoqOrder<PoqOrderItem> { get set }
    
    var cartTransferWebView: UIWebView? { get }
    
    /// URL which currently loading by cartTransferWebView. Not always equal to cartTransferWebView?.request?.url
    /// Should updated on UIWebViewDelegate method 'func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType)'
    var currentLoadingURL: URL? { get set }
    
    var isOrderReadyForTracking: Bool { get }
    
    /// REturns true if 'currentLoadingURL' is continue shopping
    var isCurrentUrlContinueShopping: Bool { get }
    
    /// We will check all possible ways, using content of cartTransferWebView
    /// If we got all needed info - isOrderReadyForTracking will return true
    func checkOrderComplete()
    
    /// Send information to our API and clean bag, as wll as couple additional actions
    /// All infomation will be taken from 'order'
    func sendOrderCompleteTransaction()
    
    /// Will be called during 'sendOrderCompleteTransaction'. Default implementation do nothing
    func sendAdditionalTracking()
    
    /// Send request to POQ API for tracking order in our CMS
    func trackOrderInternally(_ order: PoqOrder<PoqOrderItem>)
}

extension WebViewCheckout {

    public func checkOrderComplete() {

        if shouldCheckOrderCompleteByTitle() {
            
            order.isCheckoutCompleted = isOrderCompleteAccordingToTitle
        } else if shouldCheckOrderCompleteByURLs {

            if let urlString = currentLoadingURL?.absoluteString {
                order.isCheckoutCompleted = checkOrderCompleteByMultipleURLs(urlString)
            }
        } else {
            Log.warning("checkoutCompleteType, checkoutCompleteTitle or checkoutCompleteURL missing in cloud settings")
        }

        parseOrderNumber()
        parseOrderSummary()
        parseUserEmail()

        // To track even problematic page/clients we need track if we loaded page, but didn't parse some details
        // For this we will check that we are loading now compleCheckoutUrl or title of page is desired one
        // Prev checks work also with URL whic onle WILL loads
        var shouldCheckFailoverScenario: Bool = false
        if let urlString = cartTransferWebView?.request?.url?.absoluteString, shouldCheckOrderCompleteByURLs {
        
            shouldCheckFailoverScenario = checkOrderCompleteByMultipleURLs(urlString)
        } else if shouldCheckOrderCompleteByTitle() {
            shouldCheckFailoverScenario = isOrderCompleteAccordingToTitle
        }
        
        guard shouldCheckFailoverScenario else {
            return
        }
        
        guard order.orderKey == nil, !order.isOrderInfoParsingFailed else {
            order.isCheckoutCompleted = true
            return
        }
        
        if let res = cartTransferWebView?.stringByEvaluatingJavaScript(from: "document.readyState"), res == "interactive" || res == "complete" {
            Log.warning("Failed to parse webpage. Going to use order id for external order id")
            // we complete load, DOM is loaded. If data wasn't parsed - it means our js failed
            order.isOrderInfoParsingFailed = true
            order.isCheckoutCompleted = true

            if let idUnwrapped = order.id, order.orderKey == nil {
                order.orderKey = String(idUnwrapped)
            } else {
                Log.error("We don't have order.id")
                order.orderKey = "nil"
            }
             
        }
    }
    
    public var isOrderReadyForTracking: Bool {

        return order.isOrderInfoParsingFailed || (order.isCheckoutCompleted && order.isTotalCostUpdated && order.isOrderNumberUpdated)
        
    }
    
    public func sendOrderCompleteTransaction() {
        
        guard !order.isTrackingSent else {
            return
        }
        
        // adds a timestamp and identifier to the output, whereas println will not
        Log.verbose("Webview: Order transaction is going to be sent via PoqTracker")
        
        // Log this order as total cost is not including shipping cost
        if order.isTotalCostUpdated {
            
            // Log parsing
            PoqTrackerHelper.trackCheckoutOrderUpdateTotalCost(PoqTrackerActionType.UpdatedTotalCost, order: order)
        } else {
            
            // Log parsing failure
            PoqTrackerHelper.trackCheckoutOrderUpdateTotalCost(PoqTrackerActionType.InvalidTotalCost, order: order)
            
        }
        
        PoqTrackerV2.shared.orderSuccessful(voucher: order.voucherCode ?? "", currency: CurrencyProvider.shared.currency.code, value: order.totalPrice ?? 0, tax: order.totalVAT ?? 0, delivery: order.deliveryOption ?? "", orderId: order.id ?? 0, userId: User.getUserId(), quantity: order.totalQuantity ?? 0, rrp: order.subtotalPrice ?? 0)
        
        // Convert order to tracking order
        let trackingOrder = PoqTrackingOrder(order: order)
        
        // Send transaction to the providers (GA, Fb, etc.)
        PoqTracker.sharedInstance.trackCompleteOrder(trackingOrder)
        
        // Send order details to Poq DB for internal tracking
        order.externalOrderId = order.orderKey
        order.email = LoginHelper.getEmail()            
        trackOrderInternally(order)
        
        // Remove all items in the bag (async and no need to wait result)
        removeBagItems()

        order.isTrackingSent = true
        order.isCompleted = true
    }
    
    public var isCurrentUrlContinueShopping: Bool {
        
        guard let existedUrl = currentLoadingURL else {
            return false
        }
        
        return existedUrl.absoluteString.contains(AppSettings.sharedInstance.checkoutContinueShoppingURL)
    }
        
    func sendAdditionalTracking() {
    }
    
    // MARK: helper implementation
    
    func shouldCheckOrderCompleteByTitle() -> Bool {
        
        let checkByTitle = AppSettings.sharedInstance.checkoutCompleteType == CheckoutComplete.byTitle.rawValue
        let hasValidTitle = !AppSettings.sharedInstance.checkoutCompleteTitle.isNullOrEmpty()
        
        return checkByTitle && hasValidTitle
    }
    
    public func trackOrderInternally(_ order: PoqOrder<PoqOrderItem>) {   
        PoqNetworkService(networkTaskDelegate: self).postCompletedOrder(order)
    }
    
    func removeBagItems() {
        
        PoqNetworkService(networkTaskDelegate: self).deleteUsersAllBagItems(User.getUserId())
    }

    // MARK: PoqNetworkTaskDelegate
    // Actually all requests here is just notification to API, we have nothing to do with response
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}

    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {}

    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {}
    
    // MARK: Private
    
    fileprivate var shouldCheckOrderCompleteByURLs: Bool {
        
        let checkByMultipleURLs = AppSettings.sharedInstance.checkoutCompleteType == CheckoutComplete.byMultipleURLs.rawValue
        let hasValidURL = !AppSettings.sharedInstance.checkoutCompleteURL.isNullOrEmpty()
        
        return checkByMultipleURLs && hasValidURL
    }
    
    /// Return true, if according to title checkout is completed
    fileprivate var isOrderCompleteAccordingToTitle: Bool {
        
        return getCurrentPageTitleFromWebView().lowercased().contains(AppSettings.sharedInstance.checkoutCompleteTitle.lowercased())
        
    }
    
    fileprivate func getCurrentPageTitleFromWebView() -> String {
        
        if let pageTitle = cartTransferWebView?.stringByEvaluatingJavaScript(from: "document.title") {
            
            return pageTitle
        } else {
            
            return ""
        }
    }
    
    /// Return true if accroding to URL one checkout is completed
    fileprivate func checkOrderCompleteByMultipleURLs(_ urlString: String) -> Bool {
        let checkoutCompleteURL = AppSettings.sharedInstance.checkoutCompleteURL
        let checkoutCompleteURLSeperator = AppSettings.sharedInstance.checkoutCompleteURLSeperator
        return checkIfURLContainsCheckoutCompleteURL(checkoutCompleteURL, seperator: checkoutCompleteURLSeperator, currentPageURL: urlString)
    }
    
    fileprivate func checkIfURLContainsCheckoutCompleteURL(_ multipleCheckoutCompleteURLs: String, seperator: String, currentPageURL: String) -> Bool {
        
        let checkoutCompleteURLs = multipleCheckoutCompleteURLs.components(separatedBy: seperator)
        
        for checkoutCompleteURL in checkoutCompleteURLs {
            
            if currentPageURL.contains(checkoutCompleteURL) {
                
                return true
            }
        }
        
        return false
    }
    
    fileprivate func parseOrderNumber() {
        
        if let orderNumberParsed = cartTransferWebView?.stringByEvaluatingJavaScript(from: AppSettings.sharedInstance.orderNumberParser), !orderNumberParsed.isNullOrEmpty() {
            
            Log.verbose("Order number parsed: \(orderNumberParsed)")
            order.orderKey = orderNumberParsed
            order.isOrderNumberUpdated = true
            
        }
        
        // one more try - search order number in URL
        // we do it if
        // 1) 'checkoutCompleteOrderNumberKey' and 'checkoutCompleteOrderNumberURL' are set in MB
        // 2) UIWebView loading proper url, which contains 'checkoutCompleteOrderNumberURL'
        
        let queryItemName: String = AppSettings.sharedInstance.checkoutCompleteOrderNumberKey
        let orderNumberUrlPattern: String =  AppSettings.sharedInstance.checkoutCompleteOrderNumberURL
        
        let urlsSeparator: String = AppSettings.sharedInstance.checkoutCompleteURLSeperator
        
        if !order.isOrderNumberUpdated && queryItemName.isNullOrEmpty() == false && orderNumberUrlPattern.isNullOrEmpty() == false {
            
            if let existedURL: URL = currentLoadingURL {
                
                // make sure we checking proper url for order number
                if checkIfURLContainsCheckoutCompleteURL(orderNumberUrlPattern, seperator: urlsSeparator, currentPageURL: existedURL.absoluteString) {
                    
                    if let urlComponents: URLComponents = URLComponents( url: existedURL, resolvingAgainstBaseURL: false),
                        let queryItems = urlComponents.queryItems {
                        
                        for queryItem: URLQueryItem in queryItems {
                            if queryItem.name == queryItemName {
                                
                                // we found it!
                                order.orderKey = queryItem.value
                                order.isOrderNumberUpdated = true
                                
                                break
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    fileprivate func parseUserEmail() {
        
        // Check anonymous user's email
        if !LoginHelper.isLoggedIn() && AppSettings.sharedInstance.checkoutUserEmailParserEnabled {
            
            if let pageContent = cartTransferWebView?.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('html')[0].innerHTML;") {
                
                CheckoutHelper.getUserEmailFromPage(pageContent)
            }
        }
    }
    
    fileprivate func parseOrderSummary() {
        
        if AppSettings.sharedInstance.orderSummaryParser.isNullOrEmpty() {
            order.isTotalCostUpdated = true
            return
        }
        
        let orderSummaryParse = cartTransferWebView?.stringByEvaluatingJavaScript(from: AppSettings.sharedInstance.orderSummaryParser)
        
        // Get order summary page for order details as JSON string
        // Parsed JSON string into PoqParsedOrder
        // JSON data will have the label value from HTML
        // Due to running some JS Regex issues,
        // parsing the actual data needs to be done in app level
        if let orderSummary = orderSummaryParse, !orderSummary.isNullOrEmpty() {
            
            Log.verbose("Webview: Order Summary \n%@", orderSummary)
            
            let finalOrder = Mapper<PoqParsedOrder>().map(JSONString: orderSummary)

            // Update order with the current selected currency by default
            order.currency = CurrencyProvider.shared.currency.code
            
            // Update order with parsed currency if it exists
            if let currency = finalOrder?.currency, !currency.isNullOrEmpty() {
                
                order.currency = currency
            }
            
            if let subTotal = finalOrder?.subTotal?.toDouble() {
                
                order.subtotalPrice = subTotal
            }
            
            // The total revenue of a transaction, including tax and shipping
            if let totalPrice = finalOrder?.total?.toDouble() {
                
                order.totalPrice = totalPrice
                order.isTotalCostUpdated = true
            }
            
            if let discount = finalOrder?.discount?.toDouble() {
                order.voucherAmount = discount
            }
            
            // Shipping cost
            if let deliveryCost = finalOrder?.delivery?.toDouble() {
                
                order.deliveryCost = deliveryCost
            }
            
        }
    }
}
