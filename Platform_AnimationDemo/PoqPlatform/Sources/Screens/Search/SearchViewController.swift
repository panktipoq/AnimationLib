//
//  SearchViewController.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/23/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit
import PoqAnalytics

open class SearchViewController: PoqBaseViewController, SearchPresenter,
                                             UICollectionViewDataSource, UICollectionViewDelegate,
                                             KeyboardEventsListener {
    
    @IBOutlet public weak var collectionView: UICollectionView?
    
    @IBOutlet weak public var headerview: SearchHeaderView?
    
    @IBOutlet weak public var collectionViewBottomConstraint: NSLayoutConstraint?
    
    lazy public var viewModel: SearchService = {
        [unowned self] in 
        let res = ClassicSearchViewModel()
        res.presenter = self
        return res
    }()
    
    open var cellType: UICollectionViewCell.Type {
        switch SearchType.currentSearchType {
        case .classic:
            return ClassicSearchResultCell.self
        case .predictive:
            return PredictiveSearchResultCell.self
        }
    }
    
    public func registerCells() {
        collectionView?.registerPoqCells(cellClasses: [cellType.self])
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        isPresentedNavigationBarRequired = false
        
        KeyboardHelper.addKeyboardNotification(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        KeyboardHelper.removeKeyboardNotification(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let constraint = headerview?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        constraint?.isActive = true
        setupCollectionView()
        setupClearButton()
    }

    // MARK: - Status bar
    override open var preferredStatusBarStyle: UIStatusBarStyle {

        return UIStatusBarStyle.default
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }
    // MARK: - PoqPresenter
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        // Lets do here nothing for now
        // Reload action should be in 'contents' assigning in view model
    }
    
    // MARK: - Actions
    
    @IBAction func clearButtonAction() {
        viewModel.clearSearchHistory()
    }
    
    // MARK: - PredictiveSearchPresenter
    
    private var prevQuiery: String?
    
    // MARK: - SearchResultsUpdating
    public func updateSearchResults(for query: String?) {

        Log.verbose("Updating search results with \(query.debugDescription)")
        
        if let text = query, !text.isEmpty {
            
            // This event can be sent also on ative app state change (aka Alert)
            // So lets this by not sending suplicated request with teh same query
            
            if prevQuiery == nil || prevQuiery != text {
                viewModel.fetchSuggestions(for: text)
                prevQuiery = text
            }

        } else {
            prevQuiery = nil
            viewModel.cancelFetch()
            viewModel.generateEmptyQueryContents()
        }

        view.isHidden = false
    }
    
    public func searchButtonClicked(for query: String?) {
        
        guard let text = query, !text.isEmpty else {
            Log.error("Search button was pressed without")
            return
        }
        
        let historyItem = viewModel.save(query: text)
        let newContent = SearchContent(historyItem: historyItem, type: .typedSearch)
        openDetails(for: newContent)
    }

    // MARK: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.contents.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let contentItem = viewModel.contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.poqReuseIdentifier, for: indexPath)
        
        if let searchCell = cell as? SearchCell {
            searchCell.update(using: contentItem)
        }

        return cell
    }
    
    // MARK: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchContent = viewModel.contents[indexPath.row]
        viewModel.save(searchContent: searchContent)
        openDetails(for: searchContent)
    }
    
    // MARK: KeyboardEventsListener
    public func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let keyboardOffset = frameValue.cgRectValue.size.height

        collectionViewBottomConstraint?.constant = keyboardOffset
        
        UIView.animate(withDuration: animationDuration) {
            self.collectionView?.layoutIfNeeded()
        }
    }

    public func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let animationDurationNumber = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return
        }

        collectionViewBottomConstraint?.constant = 0
        
        let animationDuration: TimeInterval = animationDurationNumber.doubleValue
        
        UIView.animate(withDuration: animationDuration, animations: {
            () -> Void in
            self.collectionView?.layoutIfNeeded()
        })

    }
    
    func openSearchHistory(_ searchContent: SearchContent) {
        if let unwrappedCategoryTitle = searchContent.historyItem?.title, let parentCategoryTitle = searchContent.historyItem?.parentCategoryTitle {
            PoqTrackerHelper.trackSearchAction(PoqTrackerActionType.SearchHistory, label: String(format: "%@ in %@", unwrappedCategoryTitle, parentCategoryTitle))
        }
    }
    
    func openSuggestedSearch(_ searchContent: SearchContent) -> (categoryTitle: String?, parentCategoryId: Int?, categoryId: Int?) {
        let categoryTitle = searchContent.result?.title
        let parentCategoryIdOrNil = searchContent.result?.parentCategoryId
        var categoryIdOrNil: Int?
        
        if let categoryIdString = searchContent.result?.categoryId, let categoryId = Int(categoryIdString) {
            categoryIdOrNil = categoryId
        }
        
        if let unwrappedCategoryTitle = categoryTitle {
            var trackingLabel = unwrappedCategoryTitle
            if let parentCategoryTitle = searchContent.result?.parentCategoryTitle {
                trackingLabel += "in \(parentCategoryTitle)"
            }
            PoqTrackerHelper.trackSearchAction(PoqTrackerActionType.PredictiveSearch, label: trackingLabel)
            PoqTrackerV2.shared.viewSearchResults(keyword: unwrappedCategoryTitle, type: SearchResultType.predictive.rawValue, result: ActionResultType.successful.rawValue)
        }
        return (categoryTitle: categoryTitle, parentCategoryId: parentCategoryIdOrNil, categoryId: categoryIdOrNil)
    }
    
    func openTypedSearch(_ searchContent: SearchContent) {
        if let query = searchContent.historyItem?.keyword {
            PoqTrackerHelper.trackSearchAction(PoqTrackerActionType.Search, label: query)
            NavigationHelper.sharedInstance.loadProductsBySearch(query, searchType: SearchResultType.search.rawValue)
        }
    }
    
    open func openDetails(for searchContent: SearchContent) {
        
        var categoryIdOrNil: Int?
        var categoryTitle: String?
        var parentCategoryIdOrNil: Int?
        
        switch searchContent.type {
        case .searchHistory:
            openSearchHistory(searchContent)
            categoryTitle = searchContent.historyItem?.title
            categoryIdOrNil = searchContent.historyItem?.categoryId
            parentCategoryIdOrNil = searchContent.historyItem?.parentCategoryId
            
        case .suggestedSearch:
            let categorySuggested = openSuggestedSearch(searchContent)
            categoryTitle = categorySuggested.categoryTitle
            parentCategoryIdOrNil = categorySuggested.parentCategoryId
            categoryIdOrNil = categorySuggested.categoryId
            
        case .typedSearch:
            openTypedSearch(searchContent)
            return
        }
        
        if let deeplinkUrl = searchContent.result?.deeplinkUrl {
            NavigationHelper.sharedInstance.openURL(deeplinkUrl)
            return
        }
        
        if let categoryId = categoryIdOrNil {
            NavigationHelper.sharedInstance.loadProductsInCategory(categoryId, categoryTitle: categoryTitle ?? "", parentCategoryId: parentCategoryIdOrNil)
            return
        }
        
        // Check query
        if let query = searchContent.historyItem?.keyword {
            PoqTrackerHelper.trackSearchAction(PoqTrackerActionType.SearchHistory, label: query)
            NavigationHelper.sharedInstance.loadProductsBySearch(query, searchType: SearchResultType.history.rawValue)
            return
        }
        Log.error("We unable to present details for search content. No keyword, not category id")
    }

}
