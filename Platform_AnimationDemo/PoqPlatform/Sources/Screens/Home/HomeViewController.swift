//
//  HomeViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/// This presenter defines the design of the home view screen so other components (like the ViewModel) can see what this presenter has
public protocol HomeViewPresenter: PoqPresenter {
    var storyCarouselType: StoryCarouselType { get set }
}

/**
 Describe common API funcs for all cells. Update UI of cell according to bannerItem
 
 **Note:** have to pass delegate as 'HomeViewController' to accumulate all needed protocols/delegates
 */
public protocol HomeBannerCell: SkeletonViewCell {
    /**
     Updates the UI of the cell that implements the protocol.
     - Parameter bannerItem: This parameter stores the information about the type of cell and the information that the view needs to update
     - Parameter delegate: This parameter is passed to the cell mainly for communication purposes. Therefore, the cell could talk to the controller if needed. (e.g. A User interacts with a Banner Cell and this Cell wants to pass back the user's action to the controller)
     
     **Note:** This method is normally implemented in a UICollectionViewCell and it's called from the UICollectionView `cellForItemAt` method delegate whilst setting up the UICollectionViewCell.
     */
    func updateUI(_ bannerItem: HomeBannerItem, delegate: HomeViewController)
}

/**
 HomeViewController is one of the main View Controllers in Poq Applications which normally has its own Tab in the main App.
 Its architecture is MVVM and its model is lazy loaded which means that clients can provide their own implementation of the model.
 ## Usage Example: ##
 ````
 let viewController = HomeViewController(nibName: "HomeView", bundle: nil)
 viewController.viewModel = HomeViewModel(presenter: viewController)
 ````
 
 The main UI controllers are:
 - **SearchController:** The search can be enabled and disabled with the AppSettings flag `AppSettings.enableSearchBarOnHome`.
 It also has 2 different types of search that can be toggled with the AppSettings flag `AppSettings.searchType` and it is gathered from `SearchType.currentSearchType`
     - `SearchType.classic`: Search when user press "Search" and directly open PLP with keyword
     - `SearchType.predictive`: While user typing we show suggestions
 - **BannersCollectionView:** This collectionview has `BannerCell` and `GifBannerCell` as cells and they can be set from the CMS
 
 This Controller is also subscribed to UIApplicationWillEnterForeground notifications so it will reload the BannersCollectionView data and the App Settings when the App comes to the foreground.

 */
open class HomeViewController: PoqBaseViewController, HomeViewPresenter, SearchScanButtonDelegate, SearchBarPresenter, UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource {
    
    // This feature enables/disables the skeleton views that are shown whilst doing networking operations
    public static var isSkeletonsEnabled: Bool = true
    let paddingBannerSkeletons = UIEdgeInsets(top: CGFloat(8), left: CGFloat(15), bottom: CGFloat(8), right: CGFloat(15))

    @IBOutlet public weak var bannersCollectionView: UICollectionView?
    var refreshControl: UIRefreshControl?
    
    // Decides if Story Cells are Card type or Circular Type
    public var storyCarouselType: StoryCarouselType = .card
    
    lazy public var viewModel: HomeViewModel = { [unowned self] in
        return HomeViewModel(presenter: self)
        }()
    
    public var searchController: SearchController?
    
    private var willShowOnboarding = OnboardingViewController.shouldShowOnboarding

    // Used to present search when view appearence has completed
    fileprivate var appearenceCompletion: (() -> Void)?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    // MARK: - UIViewController overrides
    
    open func registerCells() {
        
        bannersCollectionView?.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.poqReuseIdentifier)
        bannersCollectionView?.register(GifBannerCell.self, forCellWithReuseIdentifier: GifBannerCell.poqReuseIdentifier)

        bannersCollectionView?.registerPoqCells(cellClasses: [MyProfileLoginViewCell.self, MyProfilePlatformLoginViewCell.self, AppStoriesCarouselCell.self])
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        initPullToRefresh()
        setupSearchBar()
        fetchHomeData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        // Setup skeletons
        if HomeViewController.isSkeletonsEnabled {
            setupSkeletons()
        }
    }
    
    func setupSkeletons() {
        if HomeViewController.isSkeletonsEnabled {
            // If skeletons are shown, remove the spinner
            removeSpinnerView()
            // Disable the interaction whilst we are presenting the skeletons and fetching the data
            bannersCollectionView?.isScrollEnabled = false
            // Add the skeletons
            if AppSettings.sharedInstance.isStoriesCarouselOnHomeEnabled && !DeviceType.IS_IPAD {
                viewModel.addAppStorySkeletons()
            }
            if !viewModel.shouldHideSignIn {
                viewModel.addSingIn()
            }
            viewModel.addBannerSkeletons()
        }
    }
    
    func fetchHomeData() {
        if AppSettings.sharedInstance.isStoriesCarouselOnHomeEnabled {
            viewModel.fetchAppStories()
        }
        viewModel.fetchBanners()
    }
    
    func setupSearchBar() {
        guard AppSettings.sharedInstance.enableSearchBarOnHome else {
            return
        }
        setupSearch()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        
        // Handle home view navigation header disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        
        searchController?.searchBar?.resetState()
        
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBarController = NavigationHelper.sharedInstance.defaultTabBar {
            
            tabBarController.setMiddleButtonUnselected()
            tabBarController.showMiddleButton()
        }
        
        appearenceCompletion?()
        appearenceCompletion = nil
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Hide first time banner as soon as the Home disappears,
        // Unless this event was triggered by the onboarding
        // In such case this call should be ignored in order to keep the banner
        // It is only supposed to be visible once
        // And whenever user interacts with the app just hide it
        
        if willShowOnboarding == false, viewModel.hasSignInBanner {
            self.dismissLogin()
        }
        
        // Change to false after the first time the Home had disappeared
        willShowOnboarding = false
    }
    
    open func initPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl?.addTarget(self, action: #selector(HomeViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        if let refreshControlUnwrapped = refreshControl {
            bannersCollectionView?.addSubview(refreshControlUnwrapped)
        }
    }
    
    // MARK: - API
    
    /**
     Reloads HomeView Banners data and all the App settings
     - Parameter isRefresh: This parameter is `false` by default and it should only be true when this method is called form Pull To Refresh since this flag will kill the cache in the backend. All other usage of this method should avoid cache invalidation. Especially sending a push notification triggers this and puts so much pressure on DB
     
     **Note:** Make sure that you only set `isRefresh` to true if you want to invalidate the cache.
     */
    @objc func reloadData(_ isRefresh: Bool = false) {
        fetchHomeData()
        viewModel.getSettings(isRefresh)
    }
    
    /**
     This method is the action selector that gets trigger from the Refresh Control
     - Parameter refreshControl: The receiver
     
     **Note:** This is the only place where we can call `HomeViewController.reloadData(true)` since this will kill the caching
     */
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        reloadData(true)
        refreshControl.endRefreshing()
    }
    
    /**
     When app is opened with force touch, deeplink resolving happens before controller appears on screen so need to wait until view has appeared before presenting search
     */
    public func prepareToPresentSearch() {
        appearenceCompletion = {
            [weak self] in
            self?.presentSearch()
        }
    }
    
    /**
     Controller might have different searches use this method to present the right one
     */
    public func presentSearch() {
        if !isViewLoaded {
            prepareToPresentSearch()
            return
        }
        _ = searchController?.searchBar?.becomeFirstResponder()
    }
    
    // MARK: - PoqPresenter
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        bannersCollectionView?.isScrollEnabled = true
        bannersCollectionView?.reloadData()
    }
    
    public func error(_ networkError: NSError?) {
        bannersCollectionView?.isScrollEnabled = true
        showErrorMessage(networkError)
        bannersCollectionView?.reloadData()
    }
    
    public func searchScanButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchScanButtonClicked(self)
    }

    // MARK: - SearchVisualButtonDelegate
    @objc public func searchVisualButtonClicked(_ sender: Any?) {
        SearchBarHelper.searchVisualButtonClicked(self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.homeContentItems.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let bannerContent = viewModel.homeContentItems[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerContent.identifier, for: indexPath)
        
        guard let homeBannerCell = cell as? HomeBannerCell else {
            Log.error("Cell is not of type HomeBannerCell")
            return UICollectionViewCell()
        }
        
        if let bannerItem = bannerContent.bannerItem {
            homeBannerCell.disableSkeleton(padding: UIEdgeInsets.zero, contentMode: .scaleAspectFit, cornerRadius: 0)
            homeBannerCell.updateUI(bannerItem, delegate: self)
            if let identifier: Int = bannerItem.poqHomeBanner?.id {
                cell.isAccessibilityElement = true
                let accessibilityIdentifier = "Banner_\(identifier)"
                cell.accessibilityIdentifier = accessibilityIdentifier
                cell.accessibilityLabel = accessibilityIdentifier
            }
        } else {
            guard let skeletonImage = ImageInjectionResolver.loadImage(named: "loadingFrame") else {
                Log.error("Couldn't unwrap skeletonImage")
                return UICollectionViewCell()
            }
            // Check if it is the stories because we need to pass the type of app stories
            if bannerContent.identifier == AppStoriesCarouselCell.poqReuseIdentifier, let appStoriesCell = homeBannerCell as? AppStoriesCarouselCell {
                appStoriesCell.updateLayout(withStoryCarouselType: storyCarouselType)
            }
            homeBannerCell.setupSkeleton(image: skeletonImage, padding: paddingBannerSkeletons, contentMode: .scaleToFill, cornerRadius: 5)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bannerContent = viewModel.homeContentItems[indexPath.row]
        switch bannerContent.identifier {
        case BannerCell.poqReuseIdentifier,
             GifBannerCell.poqReuseIdentifier:
            if let bannerItem = bannerContent.bannerItem {
                if let homeBannerHeight = bannerItem.poqHomeBanner?.height, let homeBannerWidth = bannerItem.poqHomeBanner?.width {
                    let imageSize = ImageResizerHelper().resizeHomeBannerImage(CGFloat(homeBannerWidth), homeBannerHeight: CGFloat(homeBannerHeight), isFeatured: bannerItem.poqHomeBanner?.isFeatured ?? false)
                    let topAndBottomPaddings = CGFloat((bannerItem.poqHomeBanner?.paddingTop ?? 0) + (bannerItem.poqHomeBanner?.paddingBottom ?? 0))
                    
                    return CGSize(width: imageSize.width, height: (imageSize.height + topAndBottomPaddings))
                }
            }
            // Skeleton size
            return CGSize(width: self.view.frame.size.width, height: 416)

        case MyProfilePlatformLoginViewCell.poqReuseIdentifier,
             MyProfileLoginViewCell.poqReuseIdentifier:
            // Calculate the collection view window
            let safeAreaTopInsetHeight = view.safeAreaInsets.top
            let searchBarHeight = searchController?.searchBar?.bounds.size.height ?? 0
            let appStoriesHeight: CGFloat = {
                guard !viewModel.appStories.isEmpty else {
                    return 0
                }
                
                switch storyCarouselType {
                case .card:
                    return AppStoriesCarouselCell.cardTypeCarouselSize.height
                case .circular:
                    return AppStoriesCarouselCell.circleTypeCarouselSize.height
                }
            }()
            let bannersCollectionViewHeight: CGFloat = bannersCollectionView?.bounds.size.height ?? CGFloat(MyProfileSettings.myProfileLoginHeight)
            
            let height = bannersCollectionViewHeight - safeAreaTopInsetHeight - searchBarHeight - appStoriesHeight
            
            return CGSize(width: view.frame.size.width, height: height)

        case AppStoriesCarouselCell.poqReuseIdentifier:
            switch storyCarouselType {
            case .card:
                return AppStoriesCarouselCell.cardTypeCarouselSize
            case .circular:
                return AppStoriesCarouselCell.circleTypeCarouselSize
            }
            
        default:
            return CGSize(width: self.view.frame.size.width, height: 200)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    // Item selected
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bannerContent = viewModel.homeContentItems[indexPath.row]
        guard let bannerItem = bannerContent.bannerItem,
            let homeBanner: PoqHomeBanner = bannerItem.poqHomeBanner else {
                Log.error("Coudn't bannerItem or homeBanner in didSelectItemAt")
            return
        }
        PageHelper.openBanner(homeBanner, viewController: self)
        PoqTrackerV2.shared.bannerTap(
            bannerTitle: homeBanner.title ?? "",
            bannerType: bannerItem.poqHomeBanner?.actionType?.rawValue ?? "")
    }
    
    /// MARK: - Set up Search layout
    open func setupAdditionalSearchLayout() {
        let searchBar = searchController?.searchBar
        bannersCollectionView?.contentInset = UIEdgeInsets(top: searchBar?.frame.height ?? 0, left: 0, bottom: 0, right: 0)
        searchBar?.visualSearchButton?.addTarget(self, action: #selector(searchVisualButtonClicked), for: .touchUpInside)
        searchBar?.scannerButton?.addTarget(self, action: #selector(searchScanButtonClicked), for: .touchUpInside)
    }
}

// MARK: - Delegate for login/signup

extension HomeViewController: MyProfileLoginViewCellDelegate {
    
    public func dismissLogin() {
        viewModel.updateDisplaySignIn(true)
        viewModel.removeSignInBanner()
        bannersCollectionView?.reloadData()
    }
    
    public func signUp() {
        NavigationHelper.sharedInstance.loadSignUp()
    }
    
    public func logIn(withType type: AuthetificationType) {
        switch type {
        case .loginPassword:
            NavigationHelper.sharedInstance.loadLogin(isModal: true, isViewAnimated: true)
        case .facebook: 
            break
        }
    }
}
