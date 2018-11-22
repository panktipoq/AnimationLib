//
//  ProductDetailWebViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/16/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class ProductDetailOthersViewController: PoqBaseViewController {

    @IBOutlet public final var webView: UIWebView?
    
    public final var pageHTML: String = ""
    public final var webViewTitle: String = ""
    public final var bodyClassName: String = ""
    public final var isBranded: Bool = false
    
    var viewModel: ProductDetailOthersViewModel?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNavigationBar()
        
        // Setup view model for networking calls and other business logic
        viewModel = ProductDetailOthersViewModel(viewControllerDelegate: self)
        
        viewModel?.showWebViewContent(webView, bodyClassName:bodyClassName, bodyHTML:pageHTML, htmlWrapper: AppSettings.sharedInstance.productOthersDetailViewWrapperHtml)
    }
    
    func setupNavigationBar() {
        
        var titleFont = AppTheme.sharedInstance.pdpDetailOtherNavigationTitleFont
        let titleColor = AppTheme.sharedInstance.pdpDetailOtherNavigationTitleColor
        
        if isBranded {
            titleFont = AppTheme.sharedInstance.brandedPdpDetailOtherNavigationTitleFont
        }
        
        self.navigationItem.titleView = NavigationBarHelper.setupTitleView(webViewTitle, titleFont: titleFont, titleColor: titleColor)
        self.navigationItem.titleView?.accessibilityIdentifier = AccessibilityLabels.navigationTitle
        
        // set up back button
        self.navigationItem.leftBarButtonItem = isPresentedModally ? NavigationBarHelper.setupCloseButton(self) : NavigationBarHelper.setupBackButton(self)
        self.navigationItem.rightBarButtonItem = nil
    }
 
    /**
    Called from view model when a network operation ends
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        viewModel?.showWebViewContent(webView, bodyClassName: bodyClassName, bodyHTML: pageHTML, htmlWrapper: AppSettings.sharedInstance.productOthersDetailViewWrapperHtml)
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        viewModel?.showWebViewContent(webView, bodyClassName: bodyClassName, bodyHTML: pageHTML, htmlWrapper: AppSettings.sharedInstance.productOthersDetailViewWrapperHtml)

    }
    
    open override func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}
