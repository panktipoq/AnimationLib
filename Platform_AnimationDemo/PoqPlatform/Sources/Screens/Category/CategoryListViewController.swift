//
//  CategoryListTableViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/19/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/// The list view controller that renders the category view
open class CategoryListViewController: PoqBaseViewController, SearchBarPresenter, SearchScanButtonDelegate {
    
    /// The name of the screen as it appears on the title
    override open var screenName: String {
        return "Product Category List Screen"
    }
    
    /// The UITableView that renders the category cells
    weak open var categoryTable: UITableView?
    
    /// The view model that handles the data for this viewcontroller
    open var viewModel: CategoryListViewModel?
    
    /// An array of first letters of the categories used for quick navigation
    open var alphabet = [String]()
    
    /// The sorted category objects
    open var sortedCategories: [String: [PoqCategory]]?
    
    /// Wether or not to sort the categories
    open var sort: Bool = false
    
    /// Wether to display this viewcontroller as modal or not
    open var isModal = false
    
    /// Wether to display this viewcontroller's header or not
    open var shouldShowHeader: Bool = AppSettings.sharedInstance.isCategoryHeaderVisible
    
    /// The source category title name. TODO: Rename this to something more relevamt
    open var source: String?
    
    /// The default height of a givenr row. TODO: Rename this to seomething more relevant

    open var defaultHeight: CGFloat = 60

    // O for loading main categories
    open var selectedCategoryId = 0

    // Navigation title
    open var selectedCategoryTitle: String = ""
    
    /// The view controller in which we render predictive search data
    public var searchController: SearchController?
    
    /// The refresh control of the list
    public var refreshControl = UIRefreshControl()
    
    /// Creates the table view and sets up the visuals. Registers the table view cells. TODO: Rename this to something more relevant
    override open func loadView() {
        view = UIView()

        // To avoid the navigation bar becoming black because background is transparent.
        // The main problem is that this is probably the only ViewController in the app without xib.
        view.backgroundColor = .white
        
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = .white
        tableView.backgroundView = nil
        tableView.bounces = true
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        categoryTable = tableView
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = .clear // Set later when categories arrive..?

        if poqNavigationController?.brandStory?.findBrandedHeader() != nil {
            tableView.estimatedRowHeight = CGFloat(AppSettings.sharedInstance.brandedTextCategoryCellHeight)
        } else {
            tableView.estimatedRowHeight = defaultHeight
        }

        tableView.registerPoqCells(cellClasses: [ShopViewTableHeaderCell.self, CategoryListViewCell.self])
    }
    
    /// Triggered when the view finished loading. Makes the initial network requeest. Sets up the navigation. Sets the titleSet
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Initialize view model
        viewModel = CategoryListViewModel(viewControllerDelegate: self)

        // Set title and navigationbar title view
        if (!selectedCategoryTitle.isEmpty) {

            // Set up navigation bar
            self.title = selectedCategoryTitle

            // Track category loaded
            PoqTrackerHelper.trackCategoryLoaded(selectedCategoryTitle)
        }

        // Set up back/close button
        setUpNavigationBar()

        // Load subcategories of the selected category
        // If selected category is 0 then it loads main categories
        if selectedCategoryId == -1 {
            self.viewModel?.getBrands()
        } else {
            self.viewModel?.getSubCategories(self.selectedCategoryId)
        }

        // Clear view after loading
        NavigationHelper.sharedInstance.clearTopMostViewController()
        setupSearchBar()
        setUpPullToRefresh()
        updateTitleView()

        categoryTable?.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - search
    
    /// Sets up the search bar if enabled in MB
    open func setupSearchBar() {
        guard AppSettings.sharedInstance.enableSearchBarOnShop else {
            return
        }
        setupSearch()
    }
    
    open func setupAdditionalSearchLayout() {
        let searchBar = searchController?.searchBar
        categoryTable?.contentInset = UIEdgeInsets(top: searchBar?.frame.height ?? 0, left: 0, bottom: 0, right: 0)
        searchBar?.visualSearchButton?.addTarget(self, action: #selector(searchVisualButtonClicked), for: .touchUpInside)
        searchBar?.scannerButton?.addTarget(self, action: #selector(searchScanButtonClicked), for: .touchUpInside)
    }
    
    @objc public func searchVisualButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchVisualButtonClicked(self)
    }
    
    @objc public func searchScanButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchScanButtonClicked(self)
    }

    /// Sets up the pull to refresh functionality action. Calls the startRefresh method whenever the user pulls to refresh
    func setUpPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(CategoryListViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)

        categoryTable?.refreshControl = refreshControl
    }
    
    /// Sets up the navigation buttons in this screen
    fileprivate func setUpNavigationBar() {

        if isModal {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        } else {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }

        if selectedCategoryId == 0 {
            navigationItem.leftBarButtonItem = nil
        }

        navigationItem.rightBarButtonItem = nil
    }
    
    /// Triggered when the view has appeared. Enables or disables the navigationController.interactivePopGestureRecognizer based on wether the controller has a selected category or not
    ///
    /// - Parameter animated: Wether or not the appearance is animated
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Enable edge swipe back or disable it if it's root
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (selectedCategoryTitle as NSString).length > 0
    }
   
    /// Triggers the refresh action. Either does a getBrands() call or a getSubCategories depending if the category list is sorted or not
    ///
    /// - Parameter refreshControl: The refresh control that triggered the action
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {

        // If we are sorting get brands
        if sort {
            self.viewModel?.getBrands(isRefresh: true)
        } else {
            self.viewModel?.getSubCategories(self.selectedCategoryId, isRefresh: true)
        }
        refreshControl.endRefreshing()
    }

    // MARK: - IB Actions
    
    /// Loads the categories upon a click action. TODO: This is not used in the platform we need to either move it to a client implementation or remove it entirely
    ///
    /// - Parameter sender: The object that sends the action
    @IBAction func loadCategoriesButtonClick(_ sender: AnyObject) {

        viewModel?.getCategories()
    }

    // ______________________________________________________

    // MARK: - Network task callbacks
    
    /// Called when a network task type starts
    ///
    /// - Parameter networkTaskType: The type of the network task that started
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        if networkTaskType == PoqNetworkTaskType.categories {
            Log.verbose("Loading Categories...")
        }
    }
    
    /// Called when a network task is completed
    ///
    /// - Parameter networkTaskType: The type of the network task that completed
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        if networkTaskType == PoqNetworkTaskType.categories {
            if shouldShowHeader {
                viewModel?.addHeaderImage()
            }

            reloadTableView()

        } else if networkTaskType == PoqNetworkTaskType.brands {
            self.sortCategories()
        }
    }
    
    /// Called when a network request failed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed
    ///   - error: The acompanying error of the request failure
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
    }

    // MARK: - brands sorting
    
    /// Sorts the categories for the right side letter navigation
    func sortCategories() {
        guard let existedViewModel: CategoryListViewModel = viewModel else {
            return
        }
        alphabet = existedViewModel.getCategoryLetters()

        existedViewModel.categories.sort(by: {
            guard let validTitle1 = $0.title, let validTitle2 = $1.title else {
                return false
            }
            return validTitle1.lowercased() < validTitle2.lowercased()
        })

        self.sortedCategories = Dictionary<String, [PoqCategory]>()
        // Create the dictionary object for stores
        for letter: String in alphabet {
            self.sortedCategories?[letter] = []
        }

        for category: PoqCategory in existedViewModel.categories {

            if let title = category.title {

                let letter = title[0] as String
                self.sortedCategories?[letter.lowercased()]?.append(category)
            }
        }

        reloadTableView()
    }
    
    /// Shws a subcategory screen based on a selected category
    ///
    /// - Parameter selectedCategory: The selected category that will be opened
    func presentSubcategoriesViewController(_ selectedCategory: PoqCategory) {

        let categoryList = CategoryListViewController(nibName: nil, bundle: nil)
        categoryList.selectedCategoryTitle = selectedCategory.title ?? ""
        categoryList.source = selectedCategory.title ?? ""

        if let categoryId = selectedCategory.categoryId {
            categoryList.selectedCategoryId = categoryId
        } else {
            // Category id couldn't be resolved
            Log.warning("Category id couldn't be resolved. Main category is going to be loaded")
            categoryList.selectedCategoryId = 0
        }
        self.navigationController?.pushViewController(categoryList, animated: true)
    }
    
    /// Shows a PLP screen based on a selected product category
    ///
    /// - Parameter selectedCategory: The selected category
    func presentProductListViewController(_ selectedCategory: PoqCategory) {
        let page = PoqPage()

        guard let validCategoryId = selectedCategory.categoryId, let validTitle = selectedCategory.title else {
            return
        }

        page.pageParameter = String(validCategoryId)
        page.title = validTitle
        page.brandId = selectedCategory.brandId
        page.brandName = selectedCategory.brandName
        page.pageType = poqNavigationController?.brandStory == nil ? PoqPageType.Category : PoqPageType.BrandedCategory
        page.parentID = selectedCategory.parentCategoryId

        PageHelper.openPage(page, optionalViewController: self)
    }
    
    // MARK: - TitleView
    
    /// Updates the title view styling
    open func updateTitleView() {

        guard let _ = poqNavigationController?.brandStory,
            selectedCategoryTitle.count > 0 else {

                return
        }

        let titleLabel = UILabel()

        titleLabel.font = AppTheme.sharedInstance.brandedPageTitleFont
        titleLabel.text = selectedCategoryTitle.uppercased()
        titleLabel.textColor = AppTheme.sharedInstance.brandedPageTitleColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.sizeToFit()

        navigationItem.titleView = titleLabel
    }
    
    // MARK: - CategoryViewController
    
    /// Setups a CategoryListViewController to be pushed to the Navigation Bar with the subcategories elements. The method allows any subclass to override it and instanciate a bespoke ViewController.
    ///
    /// - Parameter category: the selected category to show in the CategoryListViewController.
    /// - Returns: an instance of CategoryListViewController.
    open func setupCategoryViewController(category: PoqCategory?) -> CategoryListViewController {

        let categoryListViewController = CategoryListViewController(nibName: "CategoryListView",
                                                                    bundle: nil)

        guard let selectedCategory = category else {

            return categoryListViewController
        }

        if let title = selectedCategory.title {

            categoryListViewController.selectedCategoryTitle = title
            categoryListViewController.source = title
        }

        if let categoryId = selectedCategory.categoryId {

            categoryListViewController.selectedCategoryId = categoryId
        } else {

            // Category id couldn't be resolved
            Log.warning(" Category id couldn't be resolved. Main category is going to be loaded")
            categoryListViewController.selectedCategoryId = 0
            categoryListViewController.selectedCategoryTitle = ""
        }

        return categoryListViewController
    }
}

// MARK: - TableView Data Source

// MARK: - Category list view controller data source
extension CategoryListViewController: UITableViewDataSource {
    
    /// Returns the number of sections in the category list view
    ///
    /// - Parameter tableView: The category list table view
    /// - Returns: The number of sections in the category list view
    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if  sort {
            return alphabet.count
        } else {
            return 1
        }
    }

    /// Returns the number of rows in a given section
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - section: The section for which category objects will be rendered
    /// - Returns: Number of rows in the given section
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if sort {
            let letter = self.alphabet[section] as String
            if let categories: [PoqCategory] = self.sortedCategories?[letter] {
                return categories.count
            } else {
                return 0
            }
        } else {
            // Return the number of rows in the section.
            return viewModel?.categories.count ?? 0
        }
    }

    /// Returns the letter array for the right hand quick navigation
    ///
    /// - Parameter tableView: The category list table view
    /// - Returns: The letter array for the right hand quick navigation
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if sort {
            return alphabet
        } else {
            return []
        }
    }
    
    /// Generates a category list cell instance based on the indexpath needed
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - indexPath: The indexpath of the table view cell that is going to be rendered
    /// - Returns: An instance of the list cell based on the indexpath needed
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var category: PoqCategory?

        if sort {
            let letter = alphabet[indexPath.section] as String
            var categories: [PoqCategory] = self.sortedCategories?[letter] ?? []
            if indexPath.row < categories.count {
                category = categories[indexPath.row]
            } else {
                Log.error("We should have sorted categories for letter \(letter)")
            }

        } else {
            category = viewModel?.categories[indexPath.row]
        }

        // Special case for category header
        guard category?.title != ShopViewTableHeaderCell.poqReuseIdentifier else {

            let cell: ShopViewTableHeaderCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

            cell.setUp(DeviceType.IS_IPAD ? AppSettings.sharedInstance.shopHeaderImageURL_iPad : AppSettings.sharedInstance.shopHeaderImageURL_iPhone)
            return cell
        }

        guard let cell: CategoryListViewCell = tableView.dequeueReusablePoqCell(),
            let existedCategory: PoqCategory = category else {
                return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "StrangeCell")
        }

        let branded: Bool = poqNavigationController?.brandStory?.findBrandedHeader() != nil

        cell.updateUI(existedCategory, branded: branded)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    
    /// Returns the height of the cell at a given indexpath
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - indexPath: The indexpath for the cell
    /// - Returns: The height of the cell for the given indexpath
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        // we assume branded categories don't have header, since thi is only for case when categories appears in Shop Tab
        if let _ = poqNavigationController?.brandStory?.findBrandedHeader() {
            return UITableViewAutomaticDimension
        }

        if let category = viewModel?.categories[indexPath.row],
            category.title == ShopViewTableHeaderCell.poqReuseIdentifier {

            return DeviceType.IS_IPAD ? CGFloat(AppSettings.sharedInstance.iPadShopHeaderViewHeight) : CGFloat(AppSettings.sharedInstance.shopHeaderViewHeight)
        }

        guard !sort else {
            return defaultHeight
        }

        return defaultHeight
    }
    
    /// Triggered when a cell in the table view has been selected
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - indexPath: The indexpath that was tapped
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        var selectedCategory: PoqCategory?

        if sort {
            let letter = self.alphabet[indexPath.section] as String
            var categories: [PoqCategory]? = self.sortedCategories?[letter]
            let category: PoqCategory? = categories?[indexPath.row]
            selectedCategory = category
        } else {
            selectedCategory = viewModel?.categories[indexPath.row]
        }

        if let deeplink: String = selectedCategory?.deeplinkUrl, deeplink.count > 0 {

            if let navController = navigationController,
                let _ = navController.popoverPresentationController {
                navController.dismiss(animated: true, completion: {
                    NavigationHelper.sharedInstance.openURL(deeplink)
                })
            } else {
                NavigationHelper.sharedInstance.openURL(deeplink)
            }

            return
        }

        if selectedCategory?.hasSubCategory == true {

            let categoryListViewController: CategoryListViewController = setupCategoryViewController(category: selectedCategory)

            self.navigationController?.pushViewController(categoryListViewController,
                                                          animated: true)
        } else {

            guard let validSelectedCategory = selectedCategory else {
                return
            }

            presentProductListViewController(validSelectedCategory)
        }
    }
    
    /// Returns a instance of the header for the category list viewcontroller
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - section: The section for the list header
    /// - Returns: An instance of the header for a given section
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let contentBlock: PoqBlock = poqNavigationController?.brandStory?.findBrandedHeader() else {
            return nil
        }
        let brandHeader = BrandedHeaderView(headerBlock: contentBlock)

        return brandHeader
    }
    
    /// Returns the height for the header in a section
    ///
    /// - Parameters:
    ///   - tableView: The category list table view
    ///   - section: The given section
    /// - Returns: The height of a header in a given section
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let contentBlock: PoqBlock = poqNavigationController?.brandStory?.findBrandedHeader() else {
            return 0.0
        }
        return BrandedHeaderView.calculateSize(contentBlock).height
    }
}

// MARK: - CategoryListViewController functionality extension
extension CategoryListViewController {
    
    /// Reloads the table view and sets up the table view visuals. 
    fileprivate func reloadTableView() {

        var dataExists: Bool = false

        if sort {
            dataExists = alphabet.count > 0
        } else {
            if let categories: [PoqCategory] = viewModel?.categories, categories.count > 0 {
                dataExists = true
            }
        }

        if (dataExists) {
            if let _ = poqNavigationController?.brandStory {
                categoryTable?.separatorColor = AppTheme.sharedInstance.shopTabBrandedCategorySeparatorColor
            } else {
                categoryTable?.separatorColor = AppTheme.sharedInstance.shopTabCategorySeparatorColor
            }
        }

        categoryTable?.reloadData()
    }
}
