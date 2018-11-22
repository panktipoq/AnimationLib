//
//  Checkout.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/28/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit
import WebKit

public class CheckoutHelper {

    // Set the tabbar badge based on index 0 - 4
    public static func setBadge(_ index: Int, badgeValue: String?) {

        var intValue = 0
        if let badgeValueUnwrapped = badgeValue, let existedIntValue = Int(badgeValueUnwrapped) {
            intValue = existedIntValue
        }
        
        BadgeHelper.setBadge(for: index, value: intValue)
    }
    
    // Return product size name based on selected size id
    public static func getProductSize<ProductType: Product>(_ selectedSizeId: Int?, product: ProductType) -> String {
        let sizes = product.productSizes ?? []
        for productSize in sizes where selectedSizeId == productSize.id {
            if let sizeName = productSize.size {
                return sizeName
            } else {
                return "ONE_SIZE".localizedPoqString
            }
        }
        return "ONE_SIZE".localizedPoqString
    }
    
    // Get the total cost of items in the bag
    public static func getBagItemsTotal<BagItemType: BagItem>(_ bagItems: [BagItemType]) -> Double {
        var total = 0.0
        
        // Loop through each bag item and add total item cost * quantity
        for item in bagItems {
            var itemCost = item.product?.specialPrice == nil ? item.product?.price : item.product?.specialPrice
            
            if item.product?.price == nil {
                itemCost = 0
            }
            guard let quantity = item.quantity else {
                continue
            }
            if let itemCost = itemCost {
                total += Double(itemCost) * Double(quantity)
            }
        }
        return total
    }
    
    // Return the number of items in the bag
    public static func getNumberOfBagItems<BagItemType: BagItem>(_ bagItems: [BagItemType]) -> Int {
        var totalItems = 0
        
        for item in bagItems {
            guard let validQuantity = item.quantity else {
                continue
            }
            totalItems += validQuantity
        }
        
        return totalItems
    }
    
    // Return the number of items in the order
    public static func getNumberOfOrderItems<OrderItemType: OrderItem>(_ orderItems: [OrderItemType]) -> Int {
        var totalItems = 0
        
        for item in orderItems {
            guard let validQuantity = item.quantity else {
                continue
            }
            totalItems += validQuantity
        }
        
        return totalItems
    }
    
    /// To inject JS and CSS into page we need prepare special JS to evaluete it on page
    /// Returns: js string for UIWebView.stringByEvaluatingJavaScript(from:)
    /// NOTE: we will do some adjustments on input, to be able wrap it. 
    ///       Depends on 2 formats: mobileInlineCSSJS +  mobileCheckoutJS
    public static func initCSSwithJavaScriptCodes(css cssString: String = AppSettings.sharedInstance.checkoutCSS,
                                                  js jsString: String? = AppSettings.sharedInstance.checkoutJavaScript) -> String {
        var checkoutPagePoqJSCode = ""
        
        // Replace ' with "
        let escapedCSS = cssString.replacingOccurrences(of: "'", with: "\"", options: NSString.CompareOptions.literal, range: nil)
        var trimmedCSS = escapedCSS.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
        trimmedCSS = trimmedCSS.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        // Apply checkout css inline
        checkoutPagePoqJSCode += String(format: AppSettings.sharedInstance.mobileInlineCSSJS, arguments: [trimmedCSS])
        
        // Checkout mobile view port
        if AppSettings.sharedInstance.shouldAddCheckoutViewPort {
            checkoutPagePoqJSCode += AppSettings.sharedInstance.mobileViewPortCode
        }
        
        // Checkout mobile js
        if let existedJsCode = jsString, !existedJsCode.isNullOrEmpty() {
            // Replace ' with "
            let escapedJS = existedJsCode.replacingOccurrences(of: "'", with: "\"", options: NSString.CompareOptions.literal, range: nil)
            var trimmedJS = escapedJS.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
            trimmedJS = trimmedJS.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            // Apply checkout js inline
            checkoutPagePoqJSCode += String(format: AppSettings.sharedInstance.mobileCheckoutJS, arguments: [trimmedJS])
        }
        return checkoutPagePoqJSCode
    }
    
    public static func injectJSandCSS(_ webView: UIWebView) {
        
        let prePopulateUserEmailJQuery = AppSettings.sharedInstance.prePopulateUserEmailJQuery
        
        webView.stringByEvaluatingJavaScript(from: prePopulateUserEmailJQuery)

        let checkoutPagePoqJSCode = CheckoutHelper.initCSSwithJavaScriptCodes(css: AppSettings.sharedInstance.checkoutCSS,
                                                                              js: AppSettings.sharedInstance.checkoutJavaScript)
        
        webView.stringByEvaluatingJavaScript(from: checkoutPagePoqJSCode)
    }
    
    // We are parsing order complete page to get user's email address
    // If user is not logged in previously, we are saving this email as username
    // The next time user checks out, we will be pre-populating or when user tries to login
    public static func getUserEmailFromPage(_ pageContent: String) {
        
        // Find <span ="poq-user-email">.....</span> tag range in pageContent
        let regexRange = pageContent.range(of: "(<span[^>]+=\"poq-user-email\"[^>]*>)[^<]*(</span>)", options: .regularExpression)
        
        if let emailRange = regexRange {
            
            // Extract span tag with the range
            let spanContent = pageContent[emailRange.lowerBound..<emailRange.upperBound]
            
            // Get email adress in the page
            var email = String(spanContent).findEmails()
            
            // There should be only 1 email in the span tag
            if email.count > 0 {
                
                // Take the first email address matching
                // We are taking the first email because if there are any other email in footer etc. they will be skipped
                // This email will be added to DC Storm email attribution
                let userEmail = email[0]
                
                if !LoginHelper.isLoggedIn() {
                    
                    Log.verbose("Webview: User email is parsed: %@", userEmail)
                    LoginHelper.saveEmail(userEmail)
                }
            }
        }
    }
}
