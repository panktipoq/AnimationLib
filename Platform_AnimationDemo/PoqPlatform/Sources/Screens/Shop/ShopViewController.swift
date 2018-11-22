//
//  ShopViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 27/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

open class ShopViewController: PoqBaseViewController, SearchBarPresenter, SearchScanButtonDelegate {
    
    // MARK: - Class Attributes
    public var viewModel: ShopViewModel?
    open var isFromTab = true
    
    // Dynamic height values
    let cellViewHeight = CGFloat(AppSettings.sharedInstance.shopTableViewCellHeight) // 75
    let cellSecondLevelHeight = CGFloat(AppSettings.sharedInstance.shopTableViewCellSubLevelsHeight) // 44
    
    // Main data comes from view model copied/managed for accordion effect
    public var dataSource = [ShopViewCategory]()
    
    // MARK: - SearchBarPresenter
    public var searchController: SearchController?

    // IBOutlets
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            tableView?.separatorStyle = AppSettings.sharedInstance.isShopTableEnableSeparator ? UITableViewCellSeparatorStyle.singleLine : UITableViewCellSeparatorStyle.none
            tableView?.backgroundColor = AppTheme.sharedInstance.shopTableBackgroundColor
            tableView?.backgroundView = nil
            tableView?.registerPoqCells(cellClasses: [ShopViewTableCell.self, ShopViewTableHeaderCell.self])
        }
    }

    // MARK: - View delegates
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Init view model
        viewModel = ShopViewModel(viewControllerDelegate: self)
        
        setUpLeftNavigationBarItem()
        
        // Hide empty cells
        tableView?.tableFooterView = UIView(frame: CGRect.zero)
        
        // Reload table to hide until data comes in
        tableView?.reloadData()
        
        // Get main categories
        viewModel?.getCategories()
        
        setUpPullToRefresh()
        setupSearchBar()
        tableView?.estimatedSectionHeaderHeight = 0
        PoqTrackerHelper.trackShopScreenLoaded()
    }
    
    func setUpLeftNavigationBarItem() {

        if isFromTab {
            
            // Remove back button as view is in a tab
            self.navigationItem.leftBarButtonItem = nil
        } else {
            
            // Set back button as view is pushed
            self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
    }
    
    func setUpPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(startRefresh), for: .valueChanged)
        tableView?.addSubview(refreshControl)
    }

    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        // Reset current data source
        // Pull down to refresh will reset the current state of the accordions
        // We refresh the table view and hide other UI elements
        // This is the most reliable way of doing it, otherwise scrolling while refreshing could crash
        dataSource = []
        tableView?.reloadData()
        
        // Get main categories
        viewModel?.getCategories(true)
        
        // Hide refresh controller
        refreshControl.endRefreshing()
    }
    
    func setupSearchBar() {
        guard AppSettings.sharedInstance.enableSearchBarOnShop else {
            return
        }
        setupSearch()
    }
    
    public func setupAdditionalSearchLayout() {
        let searchBar = searchController?.searchBar
        tableView?.contentInset = UIEdgeInsets(top: searchBar?.frame.height ?? 0, left: 0, bottom: 0, right: 0)
        searchBar?.visualSearchButton?.addTarget(self, action: #selector(searchVisualButtonClicked), for: .touchUpInside)
        searchBar?.scannerButton?.addTarget(self, action: #selector(searchScanButtonClicked), for: .touchUpInside)
    }
    
    // MARK: - Network delegates
    
    /**
    Called from view model when a network operation starts
    */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Called from view model when a network operation ends
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == PoqNetworkTaskType.categories {
            guard let categories = viewModel?.categories, !categories.isEmpty else {
                Log.error("Failed to retreive any categories.")
                return
            }
            
            guard let parentCategoryId = categories.first?.parentCategoryId else {
                // Maybe we should default to 0 if parentCategoryId is nil?..
                Log.error("Failed to retreive parent category id from first category.")
                return
            }
            
            // If they are the only categories loaded or the top level categories then we'll set the table with just these.
            guard !dataSource.isEmpty && parentCategoryId != 0 else {
                dataSource = createMainCategoriesDataSource(categories)
                tableView?.reloadData()
                return
            }
            
            guard let parentCategoryIndex = dataSource.index(where: { $0.id == parentCategoryId }) else {
                Log.error("Failed to find parent category in current categories.")
                return
            }
            
            let parentCategory = dataSource[parentCategoryIndex]
            
            for category in categories {
                guard let shopCategory = ShopViewCategory(category: category) else {
                    continue
                }
                
                // Update the subcategories level with respect to it's parent.
                // And then (I think) maintain the subcategory's accordian's through network loads.
                shopCategory.cellType.level = parentCategory.cellType.level + 1
                shopCategory.cellType.levelChildren.append(AccordionTableViewCategory())
                
                parentCategory.children.append(shopCategory)
            }
            
            showCategories(forParentAt: parentCategoryIndex)
        }
    }

    /**
    Called from view model when a network operation fails
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
    }

    // MARK: - Utility methods
    
    /* TableView Item Select */

    public func showCategories(forParentAt parentCategoryIndex: Int) {
        let parentCategory = dataSource[parentCategoryIndex]
        
        for (index, children) in parentCategory.children.enumerated() {
            children.type = .children
            
            // If the child category already has subcategories then it has been opened before, so we close it.
            // Otherwise, we set it to `init` as we don't know the state or subcategories.
            children.cellType.status = children.hasSubCategories && !children.children.isEmpty ? .closed : .init
            
            dataSource.insert(children, at: parentCategoryIndex + index + 1)
        }

        parentCategory.cellType.open()
        TableViewAccordionAnimationHelper.insertSubCategoryCells(parentCategory.children.count, atRow: parentCategoryIndex, in: tableView)
    }

    fileprivate func createMainCategoriesDataSource(_ responseCategories: [PoqCategory]) -> [ShopViewCategory] {
        var categories: [ShopViewCategory] = responseCategories.compactMap({ ShopViewCategory(category: $0) })
        
        if AppSettings.sharedInstance.isShopTabBannerEnabled {
            // Before showing the main categories
            // We need to add first row as header
            // HeaderView is tricky to disable sticky headers (by default)
            // So it is better to have header as another cell
            let headerPicture = DeviceType.IS_IPAD ? AppSettings.sharedInstance.shopHeaderImageURL_iPad : AppSettings.sharedInstance.shopHeaderImageURL_iPhone
            let headerCategory = ShopViewCategory(id: 0, name: "Header", hasSubCategories: false, picture: headerPicture, deeplinkUrl: nil)
            headerCategory.isHeader = true
            
            categories.insert(headerCategory, at: 0)
        }
        
        return categories
    }
}

// MARK: - TableView Delegate
extension ShopViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let category = dataSource[indexPath.row]
        
        guard !category.isHeader else {
            return DeviceType.IS_IPAD ? CGFloat(AppSettings.sharedInstance.iPadShopHeaderViewHeight) : CGFloat(AppSettings.sharedInstance.shopHeaderViewHeight)
        }
        
        if category.cellType.level == 0 {
            return cellViewHeight
        } else {
            return cellSecondLevelHeight
        }
    }
}

// MARK: - TableView Data Source
extension ShopViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    /* Create cell for index */
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = dataSource[indexPath.row]
        
        guard !category.isHeader else {
            let cell: ShopViewTableHeaderCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
            cell.setUp(category.picture)
            return cell
        }
        
        let cell: ShopViewTableCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = AppTheme.sharedInstance.shopTableCellSelectedBackgroundColor
        cell.updateData(category)
        
        cell.accessibilityIdentifier = AccessibilityLabels.shopViewCategories
        cell.changeLabelColor(category.type)
        
        if category.hasSubCategories {
            // If the category has subcategories the we will setup the accessory indicator to be closed or open.
            if category.cellType.status == .init || category.cellType.status == .closed {
                cell.setClose(animated: false)
                category.cellType.status = .closed
            } else if category.cellType.status == .open {
                cell.setOpen(animated: false)
                cell.changeLabelColor(category.type)
            }
        } else if category.cellType.status == .init || category.cellType.status == .detail {
            // Otherwise we will show that the category will take the user somewhere.
            cell.setDetail()
            category.cellType.status = .detail
        }
        
        // Show or hide the loading state based on the category's status.
        if category.cellType.status == .loading {
            cell.setLoading()
        } else {
            cell.unsetLoading()
        }
        
        let categoryImageIndent = AppSettings.sharedInstance.isCategoryImageEnabled ? CGFloat(60) : CGFloat(0)
        let subcategoryIndent = CGFloat(AppSettings.sharedInstance.subcategoryIndent)
        
        // Indent based on cell level and cell style.
        if category.cellType.level == 1 {
            cell.indentView.constant = AppSettings.sharedInstance.isCategoryImageEnabled ? categoryImageIndent : subcategoryIndent
        } else if category.cellType.level > 1 {
            cell.indentView.constant = (CGFloat(category.cellType.level) * subcategoryIndent) + categoryImageIndent
        } else {
            cell.indentView.constant = 0
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard dataSource.count > indexPath.row else {
            return
        }
        
        let category = dataSource[indexPath.row]
        
        // If the category is the header then we'll skip it.
        guard !category.isHeader else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? ShopViewTableCell
        cell?.changeLabelColor(category.type)
        
        if category.hasSubCategories {
            if category.cellType.status == .closed {
                if category.children.count > 0 {
                    showCategories(forParentAt: indexPath.row)
                } else {
                    // Show the loading state whilst the subcategories are being requested.
                    cell?.setLoading()
                    category.cellType.status = .loading
                    
                    viewModel?.getSubCategories(category.id)
                }
                
                cell?.changeLabelColor(.parent)
                category.type = .parent
            } else if category.cellType.status == .open {
                let index = TableViewAccordionAnimationHelper.findNextAvailableLevel(indexPath.row, dataSource: dataSource.map({ $0.cellType }))
                let range = (indexPath.row + 1) ..< index
                
                for categoryIndex in range {
                    dataSource[categoryIndex].type = .default
                }
                
                dataSource.removeSubrange(range)
                
                let intRange = Range<Int>(uncheckedBounds: (range.lowerBound, range.upperBound))
                dataSource[indexPath.row].cellType.close()
                TableViewAccordionAnimationHelper.removeSubCategoryCells(intRange, forRow: indexPath.row, in: tableView)
                
                if category.cellType.level > 0 {
                    cell?.changeLabelColor(.children)
                    category.type = .children
                } else {
                    cell?.changeLabelColor(.default)
                    category.type = .default
                }
            }
        } else if let categoryDeepLinkUrl = category.deeplinkUrl, !categoryDeepLinkUrl.isEmpty {
            NavigationHelper.sharedInstance.openURL(categoryDeepLinkUrl)
        } else {
            cell?.changeLabelColor(category.cellType.level == 0 ? .default : .children)
            NavigationHelper.sharedInstance.loadProductsInCategory(category.id, categoryTitle: category.name, parentCategoryId: category.parentCategoryId)
        }
    }
    
    // MARK: - SearchVisualButtonDelegate
    
    @objc public func searchVisualButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchVisualButtonClicked(self)
    }
    
    @objc public func searchScanButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchScanButtonClicked(self)
    }
}
