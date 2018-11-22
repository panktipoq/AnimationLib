//
//  UIWebViewExtension.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 04/04/2017.
//
//

import UIKit

public extension UIWebView {
    
    /// Method to fit content of webview inside webview according to different screen size
    @nonobjc
    public func resizeWebContent() {
        
        // iOS procedure
        scalesPageToFit = true

        // Force resize if HTML do not allow
        let contentSize = scrollView.contentSize
        let viewSize = bounds.size

        let zoomScale = viewSize.width / contentSize.width

        // Avoid to re-update zoom while the webView is loading more content.
        // Second time, after the update, zoomScale will be 1.0, so we do not want to update it.
        if zoomScale != scrollView.zoomScale {
        
            let javaScript = "document. body.style.zoom = \(zoomScale);"
            stringByEvaluatingJavaScript(from: javaScript)
        }
    }
}
