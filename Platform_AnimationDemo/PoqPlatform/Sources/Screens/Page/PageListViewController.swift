//  PageListViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import PoqUtilities
import UIKit

open class PageListViewController: PoqBaseViewController, SearchBarPresenter, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet public var pageListTable: UITableView?
    
    open var viewModel: PageListViewModel?
    
    public var selectedParentPageId: Int = 0
    public var selectedParentPageTitle = ""
    public var tableHeaderHeight: CGFloat = 15.0
    public var isModal = false
    public var isFromTab = true
    public var isASubPageInMoreTab = false
    public var isPopOver = false
    public var refreshControl = UIRefreshControl()
    
    // MARK: - SearchBarPresenter
    public var searchController: SearchController?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationHelper.sharedInstance.defaultTabBar?.setMiddleButtonUnselected()
                
        viewModel = PageListViewModel(viewControllerDelegate: self)
        viewModel?.getPages(selectedParentPageId)
        
        setupNavigationBar()
        registerNibs()
        setupPullToRefresh()
        setupSearchBar()
       
        pageListTable?.backgroundColor = AppTheme.sharedInstance.pageListBackgroundColor
        pageListTable?.tableFooterView = UIView(frame: .zero)
        
        // Clear view after loading
        NavigationHelper.sharedInstance.clearTopMostViewController()
    }
    
    open func setupSearchBar() {
        guard !AppSettings.sharedInstance.pagelistSearchBarHidden else {
            return
        }
        setupSearch()
    }
    
    public func setupAdditionalSearchLayout() {
        let searchBar = searchController?.searchBar
        pageListTable?.contentInset = UIEdgeInsets(top: searchBar?.frame.height ?? 0, left: 0, bottom: 0, right: 0)
        searchBar?.visualSearchButton?.addTarget(self, action: #selector(searchVisualButtonClicked), for: .touchUpInside)
        searchBar?.scannerButton?.addTarget(self, action: #selector(searchScanButtonClicked), for: .touchUpInside)
    }
    
    @objc public func searchScanButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchScanButtonClicked(self)
    }
    
    @objc public func searchVisualButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchVisualButtonClicked(self)
    }
    
    func setupNavigationBar() {
        
        setupNavigationBarTitle()
        setupBarButtonItems()
    }
    
    func setupNavigationBarTitle() {
        
        if selectedParentPageTitle != "" {
            // Set navigation bar
            self.title = self.selectedParentPageTitle
            self.navigationItem.titleView = nil
        } else if isPopOver && selectedParentPageTitle == "" {
            // Set first launch navigation title for iPad
            self.title = AppLocalization.sharedInstance.popOverNavigationTitle_iPad
            self.navigationItem.titleView = nil
        }
    }
    
    func setupBarButtonItems() {
        
        if !isPopOver {
            if isModal {
                self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)

            } else if !isFromTab || isASubPageInMoreTab {

                self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
            }
        }
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func setupPullToRefresh() {
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(PageListViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        pageListTable?.addSubview(refreshControl)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable edge swipe back or disable it if it's root
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (selectedParentPageTitle != "")
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel?.getPages(selectedParentPageId, isRefresh: true)
        refreshControl.endRefreshing()
    }
    
    func registerNibs() {
        
        self.pageListTable?.registerPoqCells(cellClasses: [PageListTableViewCell.self, VersionInfoTableViewCell.self])
    }
    
    func containsHeader(_ pages: NSArray) -> Bool {
        
        var hasHeader: Bool = false
        
        for index in 0 ..< pages.count {
            
            guard let page: PoqPage = pages[index] as? PoqPage,
                let actionType: PoqPageType = page.pageType else {
                    continue
            }
            hasHeader = actionType == PoqPageType.Header
        }
        
        return hasHeader
    }

    // ______________________________________________________
    // MARK: - Network task callbacks
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.pages {
            
            Log.verbose("Loading Pages...")
        }
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        pageListTable?.reloadData()
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
    }

    // MARK: - Search
    
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        NavigationHelper.sharedInstance.loadClassicSearch(topViewController: self)
        return false
    }
    
    // Barcode scanner functionality
    open func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let scanPage = PoqPage()
        scanPage.pageType = PoqPageType.Scan
        PageHelper.openPage(scanPage, optionalViewController: self)
    }

    // MARK: - UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections: [PagesSection] = viewModel?.groupedPages else {
            return 0
        }
        
        return sections.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections: [PagesSection] = viewModel?.groupedPages else {
            return 0
        }
        
        return sections[section].pages.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections: [PagesSection] = viewModel?.groupedPages,
            let cell: PageListTableViewCell = tableView.dequeueReusablePoqCell() else {
                return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ThisIsStrange")
        }
        let section: PagesSection = sections[indexPath.section]
        let poqPage: PoqPage = section.pages[indexPath.row]
        
        cell.setTableCellData(poqPage)
        cell.createAccessoryView()
        return cell
    }

    // MARK: - UITableViewDelegate

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections: [PagesSection] = viewModel?.groupedPages else {
            return nil
        }
        
        let section: PagesSection = sections[section]

        let headerTitle: String? = section.header?.title
        
        return headerTitle
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let sections: [PagesSection] = viewModel?.groupedPages else {
            return 0
        }
        
        if sections.count == 1 && sections[0].header == nil && AppSettings.sharedInstance.pagelistSearchBarHidden {
            return .leastNonzeroMagnitude
        }
        
        return UITableViewAutomaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard let sections: [PagesSection] = viewModel?.groupedPages else {
            return
        }

        let section: PagesSection = sections[indexPath.section]
        
        let poqPage: PoqPage = section.pages[indexPath.row]
        
        PageHelper.openPage(poqPage, optionalViewController: self, isFromHome: false)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let groupedPagesUnwrapped = viewModel?.groupedPages,
            let cell: VersionInfoTableViewCell = tableView.dequeueReusablePoqCell(),
            !groupedPagesUnwrapped.isEmpty && AppSettings.sharedInstance.shouldShowVersionInfo {
            return cell
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let groupedPagesUnwrapped = viewModel?.groupedPages,
            !groupedPagesUnwrapped.isEmpty && AppSettings.sharedInstance.shouldShowVersionInfo {
            return VersionInfoTableViewCell.height
        }
        return 0
    }
}
