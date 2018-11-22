//
//  PageDetailWebViewTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 5/28/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

class PageDetailWebViewTableViewCell: UITableViewCell {

    @IBOutlet var webView: UIWebView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPageData(_ body:String?){
        
            
        // Setup webview
        if let htmlBody = body {
            
            let css = AppSettings.sharedInstance.mobileCSS
            
            let wrappedHTMLString = String(format: "<html><head><link rel='stylesheet' type='text/css' href='%@' /></head><body class='appcontent'>%@</body></html>", css, htmlBody)
            
            // Load content
            webView?.loadHTMLString(wrappedHTMLString, baseURL: nil)
            
        }

    }
    
}
