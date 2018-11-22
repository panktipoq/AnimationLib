//
//  MyProfileViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit
import PoqAnalytics

public protocol MyProfileViewCellActionDelegate {
    
    func triggerAction(_ type: MyProfileCellAction)
}

open class MyProfileViewController: PoqBaseViewController, PoqMyProfileListPresenter, MyProfileViewCellActionDelegate, SignUpDelegate, MyProfileLoginViewCellDelegate, PoqActionButtonBlock, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet open weak var collectionView: UICollectionView!
    
    open lazy var service: PoqMyProfileListService = self.getService()

    let tabbarHeight: CGFloat = CGFloat(60)
    
    open func getService() -> PoqMyProfileListService {
        let service = MyProfileViewModel()
        service.presenter = self
        return service
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPullToRefresh()
        service.getContent()

        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.reloadData), name: NSNotification.Name(rawValue: PoqUserDidLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.reloadData), name: NSNotification.Name(rawValue: PoqUserDidLogoutNotification), object: nil)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        if service.favoriteStoreId != StoreHelper.getFavoriteStoreId() {
            // Reload the collection view if there is a new favourite and update the ID
            service.favoriteStoreId = StoreHelper.getFavoriteStoreId()
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    @objc open func reloadData() {
        service.getContent()
        WishlistController.shared.fetchProductIds()
    }
    
    open func setupCollectionView() {
        
        collectionView.alwaysBounceVertical = true
        collectionView.scrollsToTop = true
        
        collectionView?.registerPoqCell(VersionInfoCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)

        collectionView?.registerPoqCells(cellClasses: [MyProfilePlatformLoginViewCell.self, MyProfileActionButtonViewCell.self,
                                                       MyProfileLinkViewCell.self, MyProfileSeperatorViewCell.self,
                                                       MyProfileWelcomeViewCell.self, MyProfileBannerBlockCell.self,
                                                       MyProfileTitleViewCell.self, MyProfileStoreViewCell.self])

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func setupPullToRefresh() {

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor=AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(MyProfileViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        refreshControl.endRefreshing()
        service.getContent( true )
    }

    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        if networkTaskType == .getCheckoutDetails {
            updateRightButton(animated: false)
        }
    }
    
    open func triggerAction(_ type: MyProfileCellAction) {
        
        switch type {
            
        case .selectStore:
            Log.verbose("Select/Change store")
            NavigationHelper.sharedInstance.openURL(NavigationHelper.sharedInstance.storeListFavoriteURL)
            
        default:
            Log.warning("Undefined action from cell")
        }
    }
    
    open func logout() {
        
        let title = "ARE_YOU_SURE".localizedPoqString
        let message = "DO_YOU_WANT_TO_LOG_OUT".localizedPoqString
        let cancel = "CANCEL".localizedPoqString
        let logout = "LOGOUT".localizedPoqString
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: cancel, style: UIAlertActionStyle.cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: logout, style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
            
            self.service.logout()
            PoqTrackerHelper.trackUserLogout()
            PoqTrackerV2.shared.logout(userId: User.getUserId())
            LoginHelper.clear()
            BagHelper.resetBag()
            CookiesHelper.clearCookies()
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }))
        
        present(alertView, animated: true, completion: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if LoginHelper.isLoggedIn() {
            
            return service.loggedInContent.count
        } else {
            
            return service.loggedOutContent.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return service.getCellForIndex(collectionView, indexPath: indexPath)
    }    
    
    // Set footer
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Show the footer only if we have content and the flag allows us
        guard (!service.loggedOutContent.isEmpty || !service.loggedInContent.isEmpty) && AppSettings.sharedInstance.shouldShowVersionInfo else {
            return UICollectionReusableView()
        }

        let footer: VersionInfoCell = collectionView.dequeueReusablePoqSupplementaryViewOfKind(UICollectionElementKindSectionFooter, forIndexPath: indexPath)
        return footer
    }
    
    func didSignUp() {
        service.getContent()
    }
    
    public func dismissLogin() {
        
    }
    
    open func logIn(withType type: AuthetificationType) {
        switch type {
        case .loginPassword:
            NavigationHelper.sharedInstance.loadLogin()
            
        case .facebook:
            service.authenticateWithFacebook( fromViewController: self )
        }
    }
    
    open func signUp() {
        
        NavigationHelper.sharedInstance.loadSignUp()
        
    }
}

// MARK: - FullWidthAutoresizedCellFlowLayoutDelegate

extension MyProfileViewController: FullWidthAutoresizedCellFlowLayoutDelegate {
    
    public func supplementaryViewClass(at indexPath: IndexPath) -> UICollectionViewCell.Type? {
        
        guard AppSettings.sharedInstance.shouldShowVersionInfo else {
            return nil
        }
        
        // Make sure there is content otherwise disable version cell.
        guard !(service.loggedOutContent.isEmpty && service.loggedInContent.isEmpty) else {
            return nil
        }

        return VersionInfoCell.self
    }
    
    public func setup(cell: UICollectionViewCell, at indexPath: IndexPath) {
        
        let contentItem = service.getContentAtIndexPath(indexPath)
        
        if let reusableCell = cell as? PoqMyProfileListReusableView {
            reusableCell.setup(using: contentItem, cellPresenter: self)
        }
    }
    
    public func cellClass(at indexPath: IndexPath) -> UICollectionViewCell.Type? {
        
        if LoginHelper.isLoggedIn() {
            return service.loggedInContent[indexPath.item].cellClass
        } else {
            return service.loggedOutContent[indexPath.item].cellClass
        }
    }
    
}
