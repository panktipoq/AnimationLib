//
//  PageDetailViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import SafariServices
import UIKit

open  class PageDetailViewController: PoqBaseViewController, UIWebViewDelegate, UIGestureRecognizerDelegate,
                                       UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Fields
    open  var selectedPageId: Int = 0
    open  var selectedPageTitle: String = ""
    open  var viewModel: PageDetailViewModel?
    open  var webView: UIWebView?
    open  var isModalView = false
    open  var refreshControl: UIRefreshControl?

   // let webviewCellId = "pageDetailWebView"
    let webviewCellId = PageDetailWebViewTableViewCell.poqReuseIdentifier
    // ______________________________________________________
    
    // MARK: - Outlets (constraints)
    @IBOutlet var pageDetailTableView: UITableView?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        registerCells()
        
        // Set navigation bar
        title = selectedPageTitle
        navigationItem.titleView = nil
        
        // Set up close button if it's modal
        if isModalView {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        } else {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
        
        self.navigationItem.rightBarButtonItem = nil
        
        // Load page details
        viewModel = PageDetailViewModel(viewControllerDelegate: self)
        viewModel?.getPageDetails(selectedPageId, isRefresh: false)
        
        // Log page screen
        PoqTrackerHelper.trackPageScreen(selectedPageTitle)
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl?.addTarget(self, action: #selector(startRefresh), for: .valueChanged)
    }
    
    @objc open func startRefresh(_ refreshControl: UIRefreshControl) {
        
        viewModel?.getPageDetails(selectedPageId, isRefresh: true)
        refreshControl.endRefreshing()
    }
    
    open func registerCells() {
        pageDetailTableView?.registerPoqCells(cellClasses: [PageDetailWebViewTableViewCell.self])
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Called from view model when a network operation starts
    */
    override open  func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {  
    }
    
    /**
    Called from view model when a network operation ends
    */

    override open  func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.pageDetails {
            
            // Enable table view scrolling, as it was previously disabled due to conflicts with the scroll view of the nested web view.
            // But disable it when adding the refresh control again, to keep in-line with the previous behaviour.
            pageDetailTableView?.isScrollEnabled = true
            self.pageDetailTableView?.reloadData()
            title = viewModel?.page?.title
        }
    }
    
    /**
    Called from view model when a network operation fails
    */
    override open  func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Enable table view scrolling, as it was previously disabled due to conflicts with the scroll view of the nested web view.
        // But disable it when adding the refresh control again, to keep in-line with the previous behaviour.
        pageDetailTableView?.isScrollEnabled = true
    }

    override open func closeButtonClicked() {
        super.closeButtonClicked()
        NavigationHelper.sharedInstance.clearTopMostViewController()
    }
    
    // ______________________________________________________
    
    // MARK: - Webview delegations

    open  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let urlAbsoluteString = request.url?.absoluteString, navigationType == UIWebViewNavigationType.linkClicked {
            
            // Open inline browser for links in webview
            NavigationHelper.sharedInstance.loadExternalLink(urlAbsoluteString)

            return false
        } else {
            
            return true
        }
    }
    
    // MARK: - TableView delegate methods
    open  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
    // MARK: - TableView datasource methods
    open  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell: PageDetailWebViewTableViewCell = tableView.dequeueReusablePoqCell()!
        
        if self.webView == nil {
            self.webView = cell.webView
            self.webView?.delegate = self
        }
        
        if let refreshControlUnwrapped = refreshControl {
            // Disable table view scrolling, as it conflicts with the scroll view of the nested web view.
            // But re-enable it after the refresh control ends refreshing.
            pageDetailTableView?.isScrollEnabled = false
            cell.webView?.scrollView.addSubview(refreshControlUnwrapped)
        }
        
        cell.setPageData(self.viewModel?.page?.body)
        
        return cell        
    }

    open  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
