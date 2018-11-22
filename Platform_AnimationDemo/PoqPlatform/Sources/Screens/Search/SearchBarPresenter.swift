//
//  SearchBarPresenter.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/23/17.
//
//

import Foundation
import PoqUtilities

/**
 Adds predictive/classic search functionality when implemnted by a viewcontroller.
 Handles most of the UI setup.
 Depending on requirements, a dev should add logic to setupAdditionalSearchLayout in order to adjust for their own implementation's needs
 
 ## Usage Example: ##
 Make the viewcontroller implement the protocol
 ````
 open class CategoryListViewController: PoqBaseViewController, SearchBarPresenter
 ````
 
 Use setupAdditionalSearchLayout to add aditional logic after the search has been setup
 ````
 public func setupAdditionalSearchLayout() {
    let searchBar = searchController?.searchBar
    pageListTable?.contentInset = UIEdgeInsets(top: searchBar?.frame.height ?? 0, left: 0, bottom: 0, right: 0)
    searchBar?.visualSearchButton?.addTarget(self, action: #selector(searchVisualButtonClicked), for: .touchUpInside)
    searchBar?.scannerButton?.addTarget(self, action: #selector(searchScanButtonClicked), for: .touchUpInside)
 }
 ````
 */

public protocol SearchBarPresenter: class {
    
    var searchController: SearchController? { get set }
    var searchResultPresenter: SearchPresenter? { get }
    
    /// Create UISearchBar, as well as 'searchController' and 'searchResultPresenter'.
    /// You just need put search bar in view heirarhy and search will start working
    /// - Returns: search bar which should be placed in proper place
    func setupSearch()
   
    /// Sets up the search bar constraints to the top of the screen
    ///
    /// - Parameter horizontalInset: Pass this as != 0 if side inset (padding is needed for the search view)
    func setupSearchConstraints(for horizontalInsetValue: CGFloat)
    
    /// Used by dev to implement additional logic/functionality if needed by implementation. Called after the search view has been setup
    func setupAdditionalSearchLayout()
}

public extension SearchBarPresenter where Self: PoqBaseViewController {

    public var searchResultPresenter: SearchPresenter? {
        
        let searchResultPresenter = SearchViewController(nibName: SearchViewController.XibName, bundle: nil)
        
        switch SearchType.currentSearchType {
        case .predictive:
            let viewModel = PredictiveSearchViewModel(presenter: searchResultPresenter)
            viewModel.presenter = searchResultPresenter
            searchResultPresenter.viewModel = viewModel
        case .classic:
            let viewModel = ClassicSearchViewModel(presenter: searchResultPresenter)
            viewModel.presenter = searchResultPresenter
            searchResultPresenter.viewModel = viewModel
        }

        return searchResultPresenter
    }
    
    public func setupSearchConstraints(for horizontalInsetValue: CGFloat = 0) {
        
        guard let searchBarView = self.searchController?.searchBar else {
            Log.debug("The search bar view is not there!")
            return
        }
        view.addSubview(searchBarView)
        
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBarView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalInsetValue).isActive = true
        searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalInsetValue).isActive = true
    }
    
    public func setupAdditionalSearchLayout() {
        // Nothing to do here. Logic can be added here in in case of additional layout operations
    }
    
    public func addVisualSearchOverlay() {
        guard let visualSearchOverlay: VisualSearchOverlayView = NibInjectionResolver.loadViewFromNib(),
            VisualSearchViewController.shouldShowOverlay else {
                Log.error("Unable to load the visual search overlay")
                return
        }
        
        visualSearchOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualSearchOverlay)
        
        visualSearchOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        visualSearchOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualSearchOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualSearchOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public func setupSearch() {
        
        guard let validSearchResultViewController = searchResultPresenter as? (UIViewController & SearchPresenter) else {
            Log.error("searchResultPresenter is not a view controller or a search presenter")
            return
        }
        
        let searchController = SearchController(searchResultsController: validSearchResultViewController, containerViewController: self)

        searchController.searchResultsUpdater = validSearchResultViewController
        self.searchController = searchController
        
        addVisualSearchOverlay()
        setupSearchConstraints()
        setupAdditionalSearchLayout()
    }
}
