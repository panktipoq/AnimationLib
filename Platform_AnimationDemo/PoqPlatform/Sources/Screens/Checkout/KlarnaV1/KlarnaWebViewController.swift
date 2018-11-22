//
//  KlarnaWebViewController.swift
//  Poq.iOS.Platform
//
//  Created by Gabriel Sabiescu on 19/09/2018.
//

import UIKit
import WebKit

class KlarnaWebViewController: UIViewController {

    public var token: String
    private var url: URL
    
    required public init(_ token: String, url: URL) {
        self.token = token
        self.url = url
        super.init(nibName: "KlarnaWebView", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension KlarnaWebViewController: WKUIDelegate {
    // Stub
}

extension KlarnaWebViewController: WKNavigationDelegate {
    // Stub
}
