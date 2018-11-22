//
//  SearchController.swift
//  PoqPlatform
//
//  Created by Nikolay Dzhulay on 26/01/2017.
//
//

import Foundation
import PoqUtilities

private let appearanceAnimationTime: TimeInterval = 0.3
private let disappearanceAnimationTime: TimeInterval = 0.25

public protocol SearchResultsUpdating: AnyObject {
    func updateSearchResults(for query: String?)
    func searchButtonClicked(for query: String?)
}

/// Search view controller, resposible for presentation
/// Parent controller should path status bar ownership to it, if search controller on it
/// We create custom navigation animation, to put search in navigation stack
open class SearchController: UIViewController, SearchBarDelegate, UIViewControllerAnimatedTransitioning {

    var searchResultsController: UIViewController
    weak var containerViewController: UIViewController?
    weak var searchBarScanButton: UIButton?
    
    weak open var searchResultsUpdater: SearchResultsUpdating?
    
    // While we animating and changing state we apply constraints which we should later remove
    private var viewAppliedConstraints = [NSLayoutConstraint]()
    private var searchBarAppliedConstraints = [NSLayoutConstraint]()
    
    public let searchBar: SearchBar?
    
    var searchContainerView: SearchContainerView? {
        return view as? SearchContainerView
    }
    
    public init(searchResultsController: UIViewController, containerViewController: UIViewController) {
        self.searchResultsController = searchResultsController
        self.searchBar = NibInjectionResolver.loadViewFromNib()
        self.containerViewController = containerViewController

        super.init(nibName: nil, bundle: nil)
        
        searchBar?.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override UIViewController
    open override func loadView() {
        view = SearchContainerView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var isPush = false
        if let index = navigationController?.viewControllers.index(of: self) {
            isPush = transitionCoordinator?.viewController(forKey: .from) == navigationController?.viewControllers[index - 1]
        }

        if !isPush, let searchBarContentView = searchBar?.containerView {
            // Looks like this is pop operation, we should back search bar in proper state
            
            view.addSubview(searchBarContentView)
            searchBarContentView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.deactivate(searchBarAppliedConstraints)
            
            let searchBarConstraints = createSearchBarContainerTopPlacedConstraints()
            NSLayoutConstraint.activate(searchBarConstraints)
            searchBarAppliedConstraints = searchBarConstraints
             
            searchBar?.setState(.editing, animated: false)
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        searchBar?.textField?.becomeFirstResponder()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar?.textField?.resignFirstResponder()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        moveContentViewToSearchBar()
        searchBar?.setState(.idle, animated: false)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    public func removeScanButton() {
        self.searchBar?.removeScanButton()
    }

    // MARK: - Status bar
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - SearchBarDelegate
    func serchBarDidStartEditing() {
        guard parent == nil else {
            return
        }

        let navigationBarTintColor = containerViewController?.navigationController?.navigationBar.barTintColor

        containerViewController?.navigationController?.pushViewController(self, animated: true)
        searchResultsUpdater?.updateSearchResults(for: searchBar?.textField?.text)

        containerViewController?.navigationController?.navigationBar.barTintColor = navigationBarTintColor
    }

    func searchBarDidUpdateText(query: String?) {
        searchResultsUpdater?.updateSearchResults(for: query)
    }

    func cancelButtonPressed() {
        guard parent != nil else {
            return
        }

        navigationController?.popViewController(animated: true)
    }

    func searchButtonPressed() {
        searchResultsUpdater?.searchButtonClicked(for: searchBar?.textField?.text)
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let existedTransition = transitionContext, existedTransition.isAnimated else {
            return 0
        }

        return existedTransition.isSearchPresentingTransition ? appearanceAnimationTime : disappearanceAnimationTime
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isSearchPresentingTransition {
            presentSearchController(using: transitionContext)
        } else {
            dismissSearchController(using: transitionContext)
        }
    }
    
    // MARK: - Private
    private final func presentSearchController(using transitionContext: UIViewControllerContextTransitioning) {
        guard let searchBarContentView = searchBar?.containerView else {
            Log.error("We can't present search results view controller or can't find content view in search bar")
            return
        }

        addSearchResultControllerIfNeeded()
        
        beginAppearanceTransition(true, animated: true)
        
        transitionContext.containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBarContentView)
        searchBarContentView.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.performWithoutAnimation {
            apply(onView: createPreAppearenceAnimationViewContraints(for: transitionContext.containerView),
                  onSearchBar: createPreAppearenceAnimationSearchBarContraints())

            transitionContext.containerView.layoutIfNeeded()
        }

        UIView.animate(withDuration: appearanceAnimationTime, animations: {
            self.apply(onView: self.createAppearenceAnimationViewContraints(for: transitionContext.containerView),
                       onSearchBar: self.createSearchBarContainerTopPlacedConstraints())
            
            self.searchBar?.setState(.editing, animated: false)
            
            transitionContext.containerView.layoutIfNeeded()
        }, completion: { _ in
            self.endAppearanceTransition()
            transitionContext.completeTransition(true)
            
            self.view.translatesAutoresizingMaskIntoConstraints = true
            searchBarContentView.translatesAutoresizingMaskIntoConstraints = true
            
            self.apply(onView: [], onSearchBar: [])
        })
    }
    
    private final func dismissSearchController(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to), let searchBarContentView = searchBar?.containerView else {
            Log.error("We can't present search results view controller or can't find content view in search bar")
            return
        }
        
        beginAppearanceTransition(false, animated: true)
        
        toViewController.beginAppearanceTransition(true, animated: true)
        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: view)
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        searchBarContentView.translatesAutoresizingMaskIntoConstraints = false
        apply(onView: createDisappearanceAnimationViewContraints(for: transitionContext.containerView), onSearchBar: createDissppearenceAnimationSearchBarContraints())
        
        UIView.animate(withDuration: disappearanceAnimationTime, animations: {
            self.searchBar?.setState(.idle, animated: false)
            transitionContext.containerView.layoutIfNeeded()
        }, completion: { _ in
            self.endAppearanceTransition()
            toViewController.endAppearanceTransition()
            self.view.removeFromSuperview()
            
            self.moveContentViewToSearchBar()
            transitionContext.completeTransition(true)
        })
    }
    
    private final func addSearchResultControllerIfNeeded() {
        guard searchResultsController.parent == nil else {
            return
        }

        addChildViewController(searchResultsController)
        
        view.addSubview(searchResultsController.view)
        searchResultsController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = searchContainerView?.contentLayoutGuide
        layoutGuide?.leadingAnchor.constraint(equalTo: searchResultsController.view.leadingAnchor).isActive = true
        layoutGuide?.topAnchor.constraint(equalTo: searchResultsController.view.topAnchor).isActive = true
        layoutGuide?.trailingAnchor.constraint(equalTo: searchResultsController.view.trailingAnchor).isActive = true

        /// We can't set height 0, as it will before animation, so reduce priority
        let bottomConstraint = layoutGuide?.bottomAnchor.constraint(equalTo: searchResultsController.view.bottomAnchor)
        bottomConstraint?.priority = UILayoutPriority(rawValue: 999.0)
        bottomConstraint?.isActive = true

        searchResultsController.didMove(toParentViewController: self)
    }
    
    /// In the end of dismissing animation we will move cont view back to search bar
    private final func moveContentViewToSearchBar() {
        guard let searchBarContentView = searchBar?.containerView else {
            Log.error("Search bar cont view not found")
            return
        }
        
        NSLayoutConstraint.deactivate(searchBarAppliedConstraints)
        searchBarContentView.translatesAutoresizingMaskIntoConstraints = false
        searchBar?.addSubview(searchBarContentView)
        
        let topConstraint = searchBar?.topAnchor.constraint(equalTo: searchBarContentView.topAnchor)
        let trailingConstraints = searchBar?.trailingAnchor.constraint(equalTo: searchBarContentView.trailingAnchor)
        let bottomConstraints = searchBar?.bottomAnchor.constraint(equalTo: searchBarContentView.bottomAnchor)
        let leadingConstraints = searchBar?.leadingAnchor.constraint(equalTo: searchBarContentView.leadingAnchor)
        
        searchBarAppliedConstraints = [topConstraint, trailingConstraints, bottomConstraints, leadingConstraints].compactMap({ $0 })
        NSLayoutConstraint.activate(searchBarAppliedConstraints)
    }
    
    // Navigation bar + status bar
    private var fullNavigationBarHeight: CGFloat {
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        return navigationBarHeight + statusBarHeight
    }
    
    /// We will activate these constraints while we do non animation initial view positioning
    private final func createPreAppearenceAnimationViewContraints(for contextContainerView: UIView) -> [NSLayoutConstraint] {
        var searchBarMinY: CGFloat = 0
        if let searchBarUnwrapped = searchBar, let window = searchBar?.window {
            let globalRect = searchBarUnwrapped.convert(searchBarUnwrapped.bounds, to: window)
            searchBarMinY = globalRect.minY 
        }
        
        let viewLeadingConstraint = view.leadingAnchor.constraint(equalTo: contextContainerView.leadingAnchor)
        let viewTopConstraint = view.topAnchor.constraint(equalTo: contextContainerView.topAnchor, constant: searchBarMinY)
        let viewTrailingConstraint = view.trailingAnchor.constraint(equalTo: contextContainerView.trailingAnchor)
        let viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: SearchBar.height)

        return [viewLeadingConstraint, viewTopConstraint, viewTrailingConstraint, viewHeightConstraint]
    }
    
    /// Constrants will complress SearchViewController to size of searchBar container
    private final func createPreAppearenceAnimationSearchBarContraints() -> [NSLayoutConstraint] {
        guard let searchBarContentView = searchBar?.containerView else {
            Log.error("We can't present search results view controller or can't find content view in search bar")
            return []
        }

        let leadingConstraint = view.leadingAnchor.constraint(equalTo: searchBarContentView.leadingAnchor)
        let topConstraint = view.topAnchor.constraint(equalTo: searchBarContentView.topAnchor)
        let trailingConstraint = view.trailingAnchor.constraint(equalTo: searchBarContentView.trailingAnchor)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: searchBarContentView.bottomAnchor)
        
        return [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
    }
    
    /// We will activate these constraints during animation to final position
    private final func createAppearenceAnimationViewContraints(for contextContainerView: UIView) -> [NSLayoutConstraint] {
        let viewLeadingConstraint = view.leadingAnchor.constraint(equalTo: contextContainerView.leadingAnchor)
        let viewTopConstraint = view.topAnchor.constraint(equalTo: contextContainerView.topAnchor)
        let viewTrailingConstraint = view.trailingAnchor.constraint(equalTo: contextContainerView.trailingAnchor)
        let viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height)
        
        return [viewLeadingConstraint, viewTopConstraint, viewTrailingConstraint, viewHeightConstraint]
    }
    
    /// We will activate these constraints during animation to final position
    private final func createDisappearanceAnimationViewContraints(for contextContainerView: UIView) -> [NSLayoutConstraint] {
        var searchBarMinY: CGFloat = 0
        if let searchBarUnwrapped = searchBar, let window = searchBar?.window {
            let globalRect = searchBarUnwrapped.convert(searchBarUnwrapped.bounds, to: window)
            searchBarMinY = globalRect.minY 
        }

        let viewLeadingConstraint = view.leadingAnchor.constraint(equalTo: contextContainerView.leadingAnchor)
        let viewTopConstraint = view.topAnchor.constraint(equalTo: contextContainerView.topAnchor, constant: searchBarMinY)
        let viewTrailingConstraint = view.trailingAnchor.constraint(equalTo: contextContainerView.trailingAnchor)
        let viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: SearchBar.height)

        return [viewLeadingConstraint, viewTopConstraint, viewTrailingConstraint, viewHeightConstraint]
    }
    
    /// We will activate these constraints during animation to final position
    private final func createDissppearenceAnimationSearchBarContraints() -> [NSLayoutConstraint] {
        guard let searchBarContentView = searchBar?.containerView else {
            Log.error("We can't present search results view controller or can't find content view in search bar")
            return []
        }
        
        let leadingConstraint = view.leadingAnchor.constraint(equalTo: searchBarContentView.leadingAnchor)
        let topConstraint = view.topAnchor.constraint(equalTo: searchBarContentView.topAnchor)
        let trailingConstraint = view.trailingAnchor.constraint(equalTo: searchBarContentView.trailingAnchor)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: searchBarContentView.bottomAnchor)
        
        return [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
    }
    
    private final func createSearchBarContainerTopPlacedConstraints() -> [NSLayoutConstraint] {
        guard let searchBarContentView = searchBar?.containerView, let containerView = searchContainerView else {
            Log.error("We can't present search results view controller or can't find content view in search bar")
            return []
        }

        let layoutGuide = containerView.topLayoutGuide
        let leadingConstraint = layoutGuide.leadingAnchor.constraint(equalTo: searchBarContentView.leadingAnchor)
        let topConstraint = layoutGuide.topAnchor.constraint(equalTo: searchBarContentView.topAnchor)
        let trailingConstraint = layoutGuide.trailingAnchor.constraint(equalTo: searchBarContentView.trailingAnchor)
        let bottomConstraint = layoutGuide.bottomAnchor.constraint(equalTo: searchBarContentView.bottomAnchor)
        
        return [leadingConstraint, topConstraint, trailingConstraint, bottomConstraint]
    }
    
    /// Remove existed constraints and apply new one
    private final func apply(onView viewContraints: [NSLayoutConstraint], onSearchBar searchBarConstraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.deactivate(viewAppliedConstraints)
        NSLayoutConstraint.deactivate(searchBarAppliedConstraints)
        
        searchBarAppliedConstraints = viewContraints
        viewAppliedConstraints = searchBarConstraints
        
        NSLayoutConstraint.activate(searchBarAppliedConstraints)
        NSLayoutConstraint.activate(viewAppliedConstraints)
    }
}
