//
//  WebviewTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// A table view cell used to render HTML based content
open class WebviewTableViewCell: UITableViewCell {

    /// Constraint for the height of the cell
    @IBOutlet open var cellHeightConstraint: NSLayoutConstraint?

    /// Wether or not the cell is actively engaged in loading the content
    var loading: Bool = false
    
    /// Wether or not the cell is already loaded
    var alreadyLoaded: Bool = false
    
    /// The web view that holds the html content
    @IBOutlet open weak var termsWebview: UIWebView? {
        didSet {
            termsWebview?.scrollView.isScrollEnabled = false
            termsWebview?.delegate = self
            termsWebview?.scrollView.contentSize = CGSize.zero
            
            termsWebview?.isOpaque = false
            termsWebview?.backgroundColor = UIColor.clear
        }
    }
    
    /// Forces a layout upate of the content view and the webview. Sets the height of the cell
    override open func updateConstraints() {
        super.updateConstraints()
        
        // pretty strange hack, not sure that it will works always, but here we need size, ready to use
        // but without 'layoutIfNeeded' element may have some default initial size 
        contentView.layoutIfNeeded()
        termsWebview?.layoutIfNeeded()

        cellHeightConstraint?.constant = termsWebview?.scrollView.contentSize.height ?? 0
    }
}

// MARK: - UIWebViewDelegate implementation
extension WebviewTableViewCell: UIWebViewDelegate {
    
    /// Triggered when the webview has started loading
    ///
    /// - Parameter webView: The web view in discussion
    public func webViewDidStartLoad(_ webView: UIWebView) {
        loading = true
    }
    
    /// Triggered when the webview finished loading 
    ///
    /// - Parameter webView: The web view in discussion
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        setNeedsUpdateConstraints()
        alreadyLoaded = true
        loading = false
    }
    
    /// Triggered when the webview failed loading the content
    ///
    /// - Parameters:
    ///   - webView: The web view in discussion
    ///   - error: The error resulted trying to load the content
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loading = false
    }
}

// MARK: - MyProfileCell implementations
extension WebviewTableViewCell: MyProfileCell {
    
    /// Updates the cell UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item used to populate this cell
    ///   - delegate: The delegate that receives the calls as a result of the cells actions
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {

        guard let htmlBody: String = item.firstInputItem.value, !loading && !alreadyLoaded else {
            return
        }

        let css = AppSettings.sharedInstance.mobileCSS

        let wrappedHTMLString = String(format: AppSettings.sharedInstance.wrappedHTMLStringFormat, arguments: [css, htmlBody])

        termsWebview?.delegate = delegate
        termsWebview?.loadHTMLString(wrappedHTMLString, baseURL: nil)
    }
}
