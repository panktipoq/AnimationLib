//
//  ProductDetailOthersViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 04/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

class ProductDetailOthersViewModel: BaseViewModel {
    
    override init(viewControllerDelegate:PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    /**
    Show html content in webView by creating an html and appending appCSS in <head> tag
    
    - parameter webView:         UIWebView to show content
    - parameter bodyClassName:   CSS class name appended to body tag
    - parameter bodyHTML:        HTML content
    - parameter htmlWrapper:     Scaffolding wrapper (<html><head>..</head><body>..</body>..)
    */
    func showWebViewContent(_ webView: UIWebView?, bodyClassName: String, bodyHTML: String, htmlWrapper: String) {
        
        let css = AppSettings.sharedInstance.mobileCSS
        let htmlContent = String(format: htmlWrapper,
                                 arguments: [css, bodyClassName, bodyHTML])
        
        webView?.loadHTMLString(htmlContent, baseURL: nil)
    }
}
